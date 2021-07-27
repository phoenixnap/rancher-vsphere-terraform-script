###################################
##      Terraform resources       ##
###################################


# Random unique naming identifier ID
resource "random_id" "instance_id" {
  byte_length = 3
}

# Rancher cloud credentials for vSphere
# https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cloud_credential#vsphere_credential_config
resource "rancher2_cloud_credential" "credential_cfg" {
  name = "${var.name}-auth-${random_id.instance_id.hex}"
  vsphere_credential_config {
    vcenter = var.vcenter_server
    username = var.vcenter_user
    password = var.vcenter_password
  }
}

# Rancher node template
# https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/node_template#vsphere_config
resource "rancher2_node_template" "template_cfg" {
  name = "${var.name}-node-${random_id.instance_id.hex}"
  cloud_credential_id = rancher2_cloud_credential.credential_cfg.id
  engine_install_url = var.rancher_dockerurl
  vsphere_config {
    clone_from = var.rancher_template
    cpu_count = var.cpucount
    creation_type = "template"
    datacenter = var.rancher_datacenter
    datastore = var.rancher_datastore
    disk_size = var.disksize
    folder = var.rancher_folder
    memory_size = var.memory
    network = [ var.rancher_network ]
    pool = var.rancher_pool
    cloud_config = file("files/cloud.cfg")
    vapp_property = [ 
        "guestinfo.interface.0.ip.0.address=ip:K8SRKENETWORK",
        "guestinfo.interface.0.ip.0.netmask=$${netmask:K8SRKENETWORK}",
        "guestinfo.interface.0.route.0.gateway=$${gateway:K8SRKENETWORK}",
        "guestinfo.dns.servers=$${dns:K8SRKENETWORK}"]
    vapp_transport = "com.vmware.guestInfo"
    vapp_ip_allocation_policy = "fixedAllocated" 
    vapp_ip_protocol = "IPv4"

  }

  depends_on = [rancher2_cloud_credential.credential_cfg]
}

# Rancher cluster template 
resource "rancher2_cluster_template" "template_cfg" {
  name = "${var.name}-cluster-${random_id.instance_id.hex}"
  template_revisions {
    name = "v1"
    default = true
    cluster_config {
      cluster_auth_endpoint {
        enabled = true
      }
      rke_config {
        kubernetes_version = var.rancher_k8version
        ignore_docker_version = false
        network {
          plugin = "canal"
        }
        ingress {
          provider = "nginx"
        }
        services {
          etcd {
            creation = "6h"
            retention = "24h"
          }
          kube_api {
            audit_log {
              enabled = true
              configuration {
                max_age = 5
                max_backup = 5
                max_size = 100
                path = "-"
                format = "json"
                policy = file("files/auditlog_policy.yaml")
              }
            }
          }
        }
        cloud_provider {
          vsphere_cloud_provider {
            global {
              insecure_flag = true
            }
            virtual_center {
              datacenters = var.rancher_datacenter
              name        = var.vcenter_server
              user        = var.vcenter_user
              password    = var.vcenter_password
            }
            workspace {
              server            = var.vcenter_server
              datacenter        = var.rancher_datacenter
              folder            = "/vols"
              default_datastore = var.rancher_datastore
            }
          }
        }
      }
      scheduled_cluster_scan {
        enabled = true
        scan_config {
          cis_scan_config {
            debug_master = true
            debug_worker = true
          }
        }
        schedule_config {
          cron_schedule = "30 * * * *"
          retention = 5
        }
      }
    }
  }
  depends_on = [rancher2_node_template.template_cfg]
}

# k8s cluster
resource "rancher2_cluster" "cluster_cfg" {
  name         = "${var.name}-cluster-${random_id.instance_id.hex}"
  description  = "Terraform cluster"
  cluster_template_id = rancher2_cluster_template.template_cfg.id
  cluster_template_revision_id = rancher2_cluster_template.template_cfg.default_revision_id

  depends_on = [rancher2_cluster_template.template_cfg]
}

 # Rancher control_plane node pool
resource "rancher2_node_pool" "nodepool_control_plane" {
  cluster_id = rancher2_cluster.cluster_cfg.id
  name = "${var.name}-control-plane"
  hostname_prefix = "${var.name}-control-plane-${random_id.instance_id.hex}-"
  node_template_id = rancher2_node_template.template_cfg.id
  quantity = var.master_count
  control_plane = true
  etcd = true
  worker = false

  depends_on = [rancher2_cluster_template.template_cfg]
}
resource "rancher2_node_pool" "nodepool_worker" {
  cluster_id = rancher2_cluster.cluster_cfg.id
  name = "${var.name}-worker"
  hostname_prefix = "${var.name}-worker-${random_id.instance_id.hex}-"
  node_template_id = rancher2_node_template.template_cfg.id
  quantity = var.worker_count
  control_plane = false
  etcd = false
  worker = true

  depends_on = [rancher2_cluster_template.template_cfg]
}

# Delay 
resource "null_resource" "before" {
  depends_on = [rancher2_cluster.cluster_cfg]
}
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep ${var.delaysec}"
  }

  triggers = {
    "before" = "null_resource.before.id"
  }
}

# Kubeconfig file
resource "local_file" "kubeconfig" {
  filename = "${path.module}/.kube/config-dev"
  content = rancher2_cluster.cluster_cfg.kube_config
  file_permission = "0600"

  depends_on = [null_resource.delay]
}

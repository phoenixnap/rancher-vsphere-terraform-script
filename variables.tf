########################################
##             Variables              ##
########################################

## Rancher provider vars defined encrypted in Hashicorp Vault
variable "rancher_api_url" { 
	default = "https://rancher.glimpse.me"
}

variable "rancher_token_key" { }

# General
variable "name" {
	default = "demo"
}


# vCenter
variable "vcenter_server" {
	default = "10.100.2.20"
}
variable "vcenter_user" { 
    default = "glmadmin"
}

variable "vcenter_password" {
  default = ""
}

## Rancher node template
variable "cpucount" {
        default = 4
}

variable "memory" {
        default = 4096
}

variable "disksize" {
        default = 100000
}
variable "master_count" {
        default = 3
}

variable "worker_count" {
        default = 1
}

variable "rancher_datacenter" {
	default = "/PHX-GLM"
}

variable "rancher_datastore" {
	default = "/PHX-GLM/datastore/PHX-GLM-DS-01"
}

variable "rancher_network" {
	default = "/PHX-GLM/network/K8SRKENETWORK"
}

variable "rancher_template" {
    default = "/PHX-GLM/vm/rke2_20042_pnap"
}
variable "rancher_folder" {
	default = "/PHX-GLM/vm/g-rke-cluster-dev"
}
variable "rancher_pool" {
	default = "Compute-01/Resources/g-rke-cluster-dev"
}

variable "rancher_k8version" {
	default = "v1.20.5-rancher1-1"
}

variable "rancher_dockerurl" {
	default = "https://releases.rancher.com/install-docker/20.10.sh"
}

variable "delaysec" {
	default = 780
}

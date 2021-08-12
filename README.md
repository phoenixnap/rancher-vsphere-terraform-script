<h1 align="center">
  <br>
  <a href="https://phoenixnap.com/private"><img src="https://user-images.githubusercontent.com/81640346/123400365-fa43ce80-d5a5-11eb-89c8-5a65a02a8cac.png" alt="phoenixnap Logo" width="300"></a>

  <br>
Creating a Rancher Cluster Template
  <br>
</h1>

<p align="center">
The code below can be used to create a Rancher cluster tempalte to be used for managing a Kubernetes cluster. 
</p>

<p align="center">
  <a href="https://phoenixnap.com/private">Managed Private Cloud</a> •
  <a href="https://developers.phoenixnap.com/">Developers Portal</a> •
  <a href="http://phoenixnap.com/kb">Knowledge Base</a>
</p>

## This repo includes code that lets you:

1. Enable cluster_auth_endpont to extract the kubeconfig for this particular cluster instead of using Rancher kubeconfig to access all of them at once.
2. Specify the Kubernetes version you would like to run. 
3. Customize network settings. 
4. Create Audit Log policie using a classic Kubernetes manifest file. 

The full guide to deploying Kubernetes clusters on phoenixNAP's MPC using Rancher and Terraform is available on phoenixNAP's website <a href= "https://phoenixnap.com/wp-content/uploads/2021/08/2021-phoenixNAP-Rancher-Guide-by-Glimpse.pdf">here</a>. 

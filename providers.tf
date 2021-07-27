provider "rancher2" {

  api_url = var.rancher_api_url
  token_key = var.rancher_token_key
  insecure = true
}

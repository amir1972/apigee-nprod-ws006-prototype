module "apigee-x-mtls-mig" {
  for_each      = var.apigee_instances
  source        = "github.com/apigee/terraform-modules//modules/apigee-x-mtls-mig"
  project_id    = var.project_id
  endpoint_ip   = module.apigee-x-instance.endpoint[each.key]
  ca_cert_path  = var.apigee_mtls_ca_cert_path
  tls_cert_path = var.apigee_mtls_tls_cert_path
  tls_key_path  = var.apigee_mtls_tls_key_path
  network       = var.apigee_mtls_network # network to be passed statically via variables
  network_tags  = ["apigee-mtls-proxy"]
  subnet        = var.apigee_mtls_subnet # subnet to be passed statically via variables
  region        = each.value.region
}

module "ilb" {
  for_each      = var.apigee_instances
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-ilb?ref=v15.0.0"
  project_id    = var.project_id
  region        = each.value.region
  name          = "apigee-mtls-${each.key}"
  service_label = "apigee-mtls-${each.key}"
  network       = var.apigee_mtls_network
  subnetwork    = var.apigee_mtls_subnet
  ports         = [443]
  backends = [
    {
      group          = module.apigee-x-mtls-mig[each.key].instance_group,
      failover       = false
      balancing_mode = "CONNECTION"
    }
  ]
  health_check_config = {
    type    = "tcp"
    check   = { port = 443 }
    config  = {}
    logging = true
  }
}
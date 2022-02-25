module "gcp_apigee_foundation" {
  #source = "git::ssh://git@git.gwl.bz:7999/ecs/tflib-gcp-apigee-foundation.git"
  source = "git::https://git.gwl.bz/scm/ecs/tflib-gcp-apigee-foundation.git"

  project_id                    = var.project_id
  deploy_region                 = var.deploy_region

  ip_range                      = var.ip_range
  network                       = var.network
  analytics_region              = var.analytics_region
  runtime_region                = var.runtime_region
  apigee_environments           = var.apigee_environments
  apigee_envgroups              = var.apigee_envgroups
  cicd_cred_file                = var.cicd_cred_file
  terraform_service_account     = var.terraform_service_account
}

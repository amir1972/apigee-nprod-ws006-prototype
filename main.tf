locals {
  tf_sa = var.terraform_service_account
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.7.0"
    }
  }
}
provider "google" {
  credentials = file(var.cicd_cred_file)
  alias = "impersonate"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}
data "google_service_account_access_token" "default" {
  provider               = google.impersonate
  target_service_account = local.tf_sa
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "3600s" # 60mins
}

/******************************************
  Provider credential configuration
 *****************************************/
provider "google" {
  access_token = data.google_service_account_access_token.default.access_token
  project = var.project_id
}
provider "google-beta" {
  access_token = data.google_service_account_access_token.default.access_token
  project = var.project_id
}
# module "gcp_apigee_foundation" {
#   #source = "git::ssh://git@git.gwl.bz:7999/ecs/tflib-gcp-apigee-foundation.git"
#   source = "git::https://git.gwl.bz/scm/ecs/tflib-gcp-apigee-foundation.git"

#   project_id                    = var.project_id
#   deploy_region                 = var.deploy_region

#   ip_range                      = var.ip_range
#   network                       = var.network
#   analytics_region              = var.analytics_region
#   runtime_region                = var.runtime_region
#   apigee_environments           = var.apigee_environments
#   apigee_envgroups              = var.apigee_envgroups
#   cicd_cred_file                = var.cicd_cred_file
#   terraform_service_account     = var.terraform_service_account
# }

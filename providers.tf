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
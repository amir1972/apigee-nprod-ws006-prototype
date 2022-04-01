locals {
  tf_sa = var.terraform_service_account
}

provider "google" {
  credentials = file(var.cicd_cred_file)
  access_token = data.google_service_account_access_token.default.access_token
  alias       = "impersonate"
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

provider "google-beta" {
  credentials  = file(var.cicd_cred_file)
  access_token = data.google_service_account_access_token.default.access_token
  alias        = "impersonate"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

# Project Information

provider "google" {
  project     = var.project_id
  region      = var.runtime_region
  zone        = var.runtime_zone
}
provider "google-beta" {
  project     = var.project_id
  region      = var.runtime_region
}

module "kms-org-db" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v14.0.0"
  project_id     = var.project_id
  keyring_create = true
  key_iam = {
    org-db = {
      "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
    }
  }
  keyring = {
    location = var.analytics_region
    name     = var.kms_key_db_ring_name
  }
  keys = {
    org-db = null
  }
}

module "apigee" {
  source                  = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-organization?ref=v14.0.0"
  project_id              = var.project_id
  analytics_region        = var.analytics_region
  runtime_type            = "CLOUD"
  authorized_network      = var.authorized_network
  database_encryption_key = module.kms-org-db.key_ids["org-db"]
  apigee_environments     = var.environments
  apigee_envgroups        = var.apigee_envgroups
  depends_on = [
    google_project_service_identity.apigee_sa,
    module.kms-org-db.id
  ]
}

module "kms-inst-disk" {
  for_each   = var.apigee_instances
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v14.0.0"
  project_id = var.project_id
  keyring_create = true
  key_iam = {
    inst-disk = {
      "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
    }
  }
  keyring = {
    location = each.value.region
    name     = "apigee-${each.key}"
  }
  keys = {
    inst-disk = null
  }
}

module "myproject-default-service-accounts" {
  source       = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account"
  project_id   = var.project_id
  name         = var.service_name
  generate_key = true
  # authoritative roles granted *on* the service accounts to other identities
  iam = {
    "roles/iam.serviceAccountUser" = [var.service_account_usr]
  }
  # non-authoritative roles granted *to* the service accounts on other resources
  iam_project_roles = {
    (var.project_id) = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
    ]
  }
}

module "apigee-x-instance" {
  for_each            = var.apigee_instances
  source              = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-x-instance?ref=v14.0.0"
  apigee_org_id       = module.apigee.org_id
  name                = each.key
  region              = each.value.region
  ip_range            = each.value.ip_range
  apigee_environments = each.value.environments
  disk_encryption_key = module.kms-inst-disk[each.key].key_ids["inst-disk"]
  depends_on = [
    google_project_service_identity.apigee_sa,
    module.kms-inst-disk.self_link
  ]
}


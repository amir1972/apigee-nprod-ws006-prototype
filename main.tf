// main.tf
terraform {
required_version = ">= 1.0.0"
required_providers {
google = {
source = "hashicorp/google"
version = ">= 4.0.0"
}
google-beta = {
source = "hashicorp/google-beta"
version = ">= 4.7.0"
}
}
}

provider "google" {
  credentials = file("c:/[service account key filename].json")
  project = "[Project ID for Proto Org]"
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {
  credentials = file("c:/[service account key filename].json")
  project = "[Project ID for Proto Org]"
  region  = "us-central1"
  zone    = "us-central1-c"
}

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/net-vpc"
  project_id = var.project_id
  name       = var.network
  psn_ranges = var.psn_ranges
}

module "apigee" {
  source              = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/apigee-organization"
  project_id          = var.project_id
  analytics_region    = var.analytics_region
  runtime_type        = "CLOUD"
  authorized_network  = module.vpc.network.id
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
}

module "apigee-x-instance" {
  source              = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/apigee-x-instance"
  apigee_org_id       = module.apigee.org_id
  name                = "[Project ID for Proto Org]"
  region              = var.runtime_region
  cidr_mask           = 20
  apigee_environments = var.apigee_environments
}

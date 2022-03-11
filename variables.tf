// variables.tf

variable "project_id" {
  description = "Project ID to host this Apigee organization (will also become the Apigee Org name)."
  type        = string
}

variable "ax_region" {
  description = "Analytics Region for the Apigee Organization (immutable). See https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli."
  type = string
}

variable "network" {
  description = "Name of the VPC network to be created."
  type        = string
}

variable "deploy_region" {
  description = "Deploy Region for the Apigee Organization (immutable). See https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli."
  type = string
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    environments = list(string)
    hostnames    = list(string)
  }))
  default = {}
}

variable "apigee_environments" {
  description = "Apigee Environment Names."
  type        = list(string)
  default     = []
}

variable "apigee_instances" {
  description = "Apigee Instances (only one instance for EVAL)."
  type = map(object({
    region       = string
    ip_range     = string
    environments = list(string)
  }))
  default = {}
}

variable "terraform_service_account" {
  description = "Impersonation account"
  type = string
}

variable "cicd_cred_file" {
  description = "Impersonation key"
  type = string
}
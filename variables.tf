// variables.tf

variable "analytics_region" {
  description = "Analytics Region for the Apigee Organization (immutable). See https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli."
  type = string
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

variable "network" {
  description = "Name of the VPC network to be created."
  type        = string
}

variable "project_id" {
  description = "Project ID to host this Apigee organization (will also become the Apigee Org name)."
  type        = string
}

variable "psn_ranges" {
  description = "CIDR ranges used for Google services that support Private Service Networking."
  type = list(string)
  default = null
  validation {
  condition = alltrue([
  for r in(var.psn_ranges == null ? [] : var.psn_ranges) :
  can(cidrnetmask(r))
  ])
  error_message = "Specify a valid RFC1918 CIDR range for Private Service Networking."
  }
}
 
variable "cidr_mask" {
  description = "CIDR mask to use for the size of each range."
  type = number
  default = 20
}

variable "runtime_region" {
  description = "Apigee Runtime Instance Region."
  type        = string
}

variable "terraform_service_account" {
  description = "Impersonation account"
  type = string
}

variable "cicd_cred_file" {
  description = "Impersonation key"
  type = string
}


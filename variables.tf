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

  # variable "ip_range" {
  #   description = "Customer-provided CIDR block of length 22 for the Apigee instance."
  #   type = string
  #   validation {
  #     condition = try(cidrnetmask(var.ip_range), null) == "255.255.252.0"
  #     error_message = "Invalid CIDR block provided; Allowed pattern for ip_range: X.X.X.X/22."
  #   }
  # }

variable "ip_range" {
  description = "CIDR ranges used for Google services that support Private Service Networking."
  type        = map(string)
  default     = null
  validation {
    condition = alltrue([
      for k, v in(var.ip_range == null ? {} : var.ip_range) :
      can(cidrnetmask(v))
    ])
    error_message = "Specify valid RFC1918 CIDR ranges for Private Service Networking."
  }
}
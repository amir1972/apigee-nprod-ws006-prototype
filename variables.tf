// variables.tf

variable "analytics_region" {
  description = "Analytics Region for the Apigee Organization (immutable). See https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli."
  type        = string
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    environments = list(string)
    hostnames    = list(string)
  }))
  default = {}
}

variable "environments" {
  description = "Apigee Environment Names."
  type        = list(string)
  default     = []
}

variable "project_id" {
  description = "Project ID to host this Apigee organization (will also become the Apigee Org name)."
  type        = string
}

variable "runtime_region" {
  description = "Apigee Runtime Instance Region."
  type        = string
}


variable "ip_range" {
  description = "Customer-provided CIDR block of length 22 for the Apigee instance."
  type        = string
  validation {
    condition = try(cidrnetmask(var.ip_range), null) == "255.255.252.0" || try(cidrnetmask(var.ip_range), null) == "255.255.255.240"

    error_message = "Invalid CIDR block provided; Allowed pattern for ip_range: X.X.X.X/22."
  }
}

variable "ip_range_support" {
  description = "Customer-provided CIDR block of length 22 for the Apigee instance."
  type        = string
  validation {
    condition     = try(cidrnetmask(var.ip_range_support), null) == "255.255.255.240"
    error_message = "Invalid CIDR block provided; Allowed pattern for ip_range: X.X.X.X/28."
  }
}

# Project Variables

#Required Variables 

variable "credentials_file" {
  description = "Location of Credentials File"
  type        = string
}

variable "runtime_zone" {
  description = "Zone of an existing project or of the new project"
  type        = string
}

# APIGEE Organization Variables

#Required Variables

variable "apigee_org_id" {
  description = "Apigee Organization ID."
  type        = string
}

variable "runtime_type" {
  description = "Apigee runtime type. Must be `CLOUD` or `HYBRID`."
  type        = string
  validation {
    condition     = contains(["CLOUD", "HYBRID"], var.runtime_type)
    error_message = "Allowed values for runtime_type \"CLOUD\" or \"HYBRID\"."
  }
}

variable "organization_description" {
  description = "Description of the Apigee Organization."
  type        = string
  default     = "Apigee Organization created by tf module"
}

variable "database_encryption_key" {
  description = "Cloud KMS key self link (e.g. `projects/foo/locations/us/keyRings/bar/cryptoKeys/baz`) used for encrypting the data that is stored and replicated across runtime instances (immutable, used in Apigee X only)."
  type        = string
  default     = null
}

variable "hostnames" {
  description = "Apigee hostnames."
  type        = list(string)
  default     = []
}

variable "authorized_network" {
  description = "VPC network self link (requires service network peering enabled (Used in Apigee X only)."
  type        = string
  default     = null
}

variable "display_name" {
  description = "Display Name of the Apigee Organization."
  type        = string
  default     = null
}

variable "disk_encryption_key" {
  description = "Customer Managed Encryption Key (CMEK) self link (e.g. `projects/foo/locations/us/keyRings/bar/cryptoKeys/baz`) used for disk and volume encryption (required for PAID Apigee Orgs only)."
  type        = string
  default     = null
}


variable "kms_key_ring_name" {
  description = "Google Kms Key Ring Name"
  type        = string
  default     = "apigee-keyring"
}

variable "kms_key_db_ring_name" {
  description = "Google Kms Key Ring Name"
  type        = string
  default     = "apigee-keyring"
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

// VPC

variable "auto_create_subnetworks" {
  description = "Set to true to create an auto mode subnet, defaults to custom mode."
  type        = bool
  default     = false
}

variable "data_folder" {
  description = "An optional folder containing the subnet configurations in YaML format."
  type        = string
  default     = null
}

variable "delete_default_routes_on_create" {
  description = "Set to true to delete the default routes at creation time."
  type        = bool
  default     = false
}

variable "vpc_description" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
  default     = "Terraform-managed."
}

variable "dns_policy" {
  description = "DNS policy setup for the VPC."
  type = object({
    inbound = bool
    logging = bool
    outbound = object({
      private_ns = list(string)
      public_ns  = list(string)
    })
  })
  default = null
}

variable "iam" {
  description = "Subnet IAM bindings in {REGION/NAME => {ROLE => [MEMBERS]} format."
  type        = map(map(list(string)))
  default     = {}
}

variable "log_config_defaults" {
  description = "Default configuration for flow logs when enabled."
  type = object({
    aggregation_interval = string
    flow_sampling        = number
    metadata             = string
  })
  default = {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

variable "log_configs" {
  description = "Map keyed by subnet 'region/name' of optional configurations for flow logs when enabled."
  type        = map(map(string))
  default     = {}
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes. The minimum value for this field is 1460 and the maximum value is 1500 bytes."
  default     = null
}

variable "peering_config" {
  description = "VPC peering configuration."
  type = object({
    peer_vpc_self_link = string
    export_routes      = bool
    import_routes      = bool
  })
  default = null
}

variable "peering_create_remote_end" {
  description = "Skip creation of peering on the remote end when using peering_config."
  type        = bool
  default     = true
}

variable "psa_config" {
  description = "The Private Service Access configuration."
  type = map(object({
    ranges = list(string) # CIDRs in the format x.x.x.x/yy
    routes = object({
      export = bool
      import = bool
    })
  }))
  default = null
}

variable "routes" {
  description = "Network routes, keyed by name."
  type = map(object({
    dest_range    = string
    priority      = number
    tags          = list(string)
    next_hop_type = string # gateway, instance, ip, vpn_tunnel, ilb
    next_hop      = string
  }))
  default = {}
}

variable "routing_mode" {
  description = "The network routing mode (default 'GLOBAL')."
  type        = string
  default     = "GLOBAL"
  validation {
    condition     = var.routing_mode == "GLOBAL" || var.routing_mode == "REGIONAL"
    error_message = "Routing type must be GLOBAL or REGIONAL."
  }
}

variable "shared_vpc_host" {
  description = "Enable shared VPC for this project."
  type        = bool
  default     = false
}

variable "shared_vpc_service_projects" {
  description = "Shared VPC service projects to register with this host."
  type        = list(string)
  default     = []
}

variable "subnet_descriptions" {
  description = "Optional map of subnet descriptions, keyed by subnet 'region/name'."
  type        = map(string)
  default     = {}
}

variable "subnet_flow_logs" {
  description = "Optional map of boolean to control flow logs (default is disabled), keyed by subnet 'region/name'."
  type        = map(bool)
  default     = {}
}

variable "subnet_private_access" {
  description = "Optional map of boolean to control private Google access (default is enabled), keyed by subnet 'region/name'."
  type        = map(bool)
  default     = {}
}

variable "subnets" {
  description = "List of subnets being created."
  type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
    secondary_ip_range = map(string)
  }))
  default = []
}

variable "subnets_l7ilb" {
  description = "List of subnets for private HTTPS load balancer."
  type = list(object({
    active        = bool
    name          = string
    ip_cidr_range = string
    region        = string
  }))
  default = []
}

variable "vpc_create" {
  description = "Create VPC. When set to false, uses a data source to reference existing VPC."
  type        = bool
  default     = true
}

variable "service_description" {
  description = "Optional description."
  type        = string
  default     = null
}

variable "service_display_name" {
  description = "Display name of the service account to create."
  type        = string
  default     = "Terraform-managed."
}

variable "generate_key" {
  description = "Generate a key for service account."
  type        = bool
  default     = false
}


variable "iam_billing_roles" {
  description = "Billing account roles granted to the service account, by billing account id. Non-authoritative."
  type        = map(list(string))
  default     = {}
//  nullable    = false
}

variable "iam_folder_roles" {
  description = "Folder roles granted to the service account, by folder id. Non-authoritative."
  type        = map(list(string))
  default     = {}
//  nullable    = false
}

variable "iam_organization_roles" {
  description = "Organization roles granted to the service account, by organization id. Non-authoritative."
  type        = map(list(string))
  default     = {}
//  nullable    = false
}

variable "iam_project_roles" {
  description = "Project roles granted to the service account, by project id."
  type        = map(list(string))
  default     = {}
//  nullable    = false
}

variable "iam_storage_roles" {
  description = "Storage roles granted to the service account, by bucket name."
  type        = map(list(string))
  default     = {}
//  nullable    = false
}

variable "service_name" {
  description = "Name of the service account to create."
  type        = string
}

variable "prefix" {
  description = "Prefix applied to service account names."
  type        = string
  default     = null
}

variable "public_keys_directory" {
  description = "Path to public keys data files to upload to the service account (should have `.pem` extension)."
  type        = string
  default     = ""
}

variable "service_account_create" {
  description = "Create service account. When set to false, uses a data source to reference an existing service account."
  type        = bool
  default     = true
}

# authoritative roles granted *on* the service accounts to other identities
variable "service_account_usr" {
  description = "authoritative roles granted *on* the service accounts to other identities"
  type        = string
}



variable "contacts" {
  description = "List of essential contacts for this resource. Must be in the form EMAIL -> [NOTIFICATION_TYPES]. Valid notification types are ALL, SUSPENSION, SECURITY, TECHNICAL, BILLING, LEGAL, PRODUCT_UPDATES."
  type        = map(list(string))
  default     = {}
  //nullable    = false
}

variable "custom_roles" {
  description = "Map of role name => list of permissions to create in this project."
  type        = map(list(string))
  default     = {}
  //nullable    = false
}

variable "firewall_policies" {
  description = "Hierarchical firewall policy rules created in the organization."
  type = map(map(object({
    action                  = string
    description             = string
    direction               = string
    logging                 = bool
    ports                   = map(list(string))
    priority                = number
    ranges                  = list(string)
    target_resources        = list(string)
    target_service_accounts = list(string)
    # preview                 = bool
  })))
  default = {}
}

variable "firewall_policy_association" {
  description = "The hierarchical firewall policy to associate to this folder. Must be either a key in the `firewall_policies` map or the id of a policy defined somewhere else."
  type        = map(string)
  default     = {}
  //nullable    = false
}

variable "firewall_policy_factory" {
  description = "Configuration for the firewall policy factory."
  type = object({
    cidr_file   = string
    policy_name = string
    rules_file  = string
  })
  default = null
}

variable "group_iam" {
  description = "Authoritative IAM binding for organization groups, in {GROUP_EMAIL => [ROLES]} format. Group emails need to be static. Can be used in combination with the `iam` variable."
  type        = map(list(string))
  default     = {}
  //nullable    = false
}

variable "iam_additive" {
  description = "Non authoritative IAM bindings, in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
  //nullable    = false
}

variable "iam_additive_members" {
  description = "IAM additive bindings in {MEMBERS => [ROLE]} format. This might break if members are dynamic values."
  type        = map(list(string))
  default     = {}
  //nullable    = false
}

variable "iam_audit_config" {
  description = "Service audit logging configuration. Service as key, map of log permission (eg DATA_READ) and excluded members as value for each service."
  type        = map(map(list(string)))
  default     = {}
  //nullable    = false
  # default = {
  #   allServices = {
  #     DATA_READ = ["user:me@example.org"]
  #   }
  # }
}

variable "iam_audit_config_authoritative" {
  description = "IAM Authoritative service audit logging configuration. Service as key, map of log permission (eg DATA_READ) and excluded members as value for each service. Audit config should also be authoritative when using authoritative bindings. Use with caution."
  type        = map(map(list(string)))
  default     = null
  # default = {
  #   allServices = {
  #     DATA_READ = ["user:me@example.org"]
  #   }
  # }
}

variable "iam_bindings_authoritative" {
  description = "IAM authoritative bindings, in {ROLE => [MEMBERS]} format. Roles and members not explicitly listed will be cleared. Bindings should also be authoritative when using authoritative audit config. Use with caution."
  type        = map(list(string))
  default     = null
}

variable "logging_exclusions" {
  description = "Logging exclusions for this organization in the form {NAME -> FILTER}."
  type        = map(string)
  default     = {}
  //nullable    = false
}

variable "logging_sinks" {
  description = "Logging sinks to create for this organization."
  type = map(object({
    destination          = string
    type                 = string
    filter               = string
    include_children     = bool
    bq_partitioned_table = bool
    # TODO exclusions also support description and disabled
    exclusions = map(string)
  }))
  validation {
    condition = alltrue([
      for k, v in(var.logging_sinks == null ? {} : var.logging_sinks) :
      contains(["bigquery", "logging", "pubsub", "storage"], v.type)
    ])
    error_message = "Type must be one of 'bigquery', 'logging', 'pubsub', 'storage'."
  }
  default  = {}
  //nullable = false
}

variable "organization_id" {
  description = "Organization id in organizations/nnnnnn format."
  type        = string
  validation {
    condition     = can(regex("^organizations/[0-9]+", var.organization_id))
    error_message = "The organization_id must in the form organizations/nnn."
  }
}

variable "policy_boolean" {
  description = "Map of boolean org policies and enforcement value, set value to null for policy restore."
  type        = map(bool)
  default     = {}
  //nullable    = false
}

variable "policy_list" {
  description = "Map of list org policies, status is true for allow, false for deny, null for restore. Values can only be used for allow or deny."
  type = map(object({
    inherit_from_parent = bool
    suggested_value     = string
    status              = bool
    values              = list(string)
  }))
  default  = {}
  //nullable = false
}

variable "tag_bindings" {
  description = "Tag bindings for this organization, in key => tag value id format."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags by key name. The `iam` attribute behaves like the similarly named one at module level."
  type = map(object({
    description = string
    iam         = map(list(string))
    values = map(object({
      description = string
      iam         = map(list(string))
    }))
  }))
  default = null
}
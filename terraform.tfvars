
# Terraform Variables
#The CICD id will impersonate this id when applying changes
terraform_service_account  = "apigee-nprod-ws006-tf-prod@cantech-terraformers.iam.gserviceaccount.com"
cicd_cred_file             = "apigee-nprod-ws006-prototype.json"


# Project Details

# Project ID to host this Apigee organization (will also become the Apigee Org name).
#type        = string
project_id = "apigee-nprod-ws006-prototype"

# Location of Credentials File
#type        = string // is a json file download and stored in teh same folder of Terrafomr script once you create the Service and then a Key
#credentials_file = "papigee-nprod-ws006-prototype.json"  #Injected by Jenkins, see Main.tf

# Apigee Runtime Instance Region.
#type        = string
runtime_region = "northamerica-northeast1"

# Zone of an existing project or of the new project
#type        = string
runtime_zone = "northamerica-northeast1-a"

# Analytics Region for the Apigee Organization (immutable). See https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli.
analytics_region = "us-east1"
#type        = string

# Apigee runtime type. Must be `CLOUD` or `HYBRID`.
#type        = string
#condition     = contains(["CLOUD", "HYBRID"], var.runtime_type)
runtime_type = "CLOUD" //"HYBRID" 

# Organization id in organizations/nnnnnn format. -- If you don't have GCP Orgaization see the bottom of the Readme file for  the lines that need to be commented out.
#type        = string
# you can get the number in gcloud using: gcloud organizations list
organization_id = "organizations/166307584217"   #Required


# Apigee Org Details


# Apigee Organization ID Name - Same as Project Id
#type        = string
apigee_org_id = "apigee-nprod-ws006-prototype" // Must be the same as Same as Project Id

# Display Name of the Apigee Organization.
#type        = string
display_name = "apigee-nprod-ws006-prototype"

# Description of the Apigee OrganizationDescription of the Apigee Organization
#type        = string
organization_description = "Apigee Organization created by Terraform"

# Apigee Environment Names.
environments = ["proto1", "proto2"]
/*type = map(object({
    environments = list(string)
    hostnames    = list(string)
  }))
*/

# Apigee hostnames.
#type        = list(string)
hostnames = ["prototype-api.canadalife.com","prototype-apix.canadalife.com"]

# Apigee Environment Groups.
/*type = map(object({
    environments = list(string)
    hostnames    = list(string)
  }))
*/
apigee_envgroups = {
  proto-env-grp = {
    environments = ["proto1", "proto2"]
    hostnames    = ["prototype-api.canadalife.com","prototype-apix.canadalife.com"]
  }
}

# Apigee Instances 
/*type = map(object({
    runtime_region = string
    ip_range       = string
    environments   = list(string)
  }))
*/
apigee_instances  = {}

#   #IP Ranges documented at https://spaces.gwl.ca/display/ECS/GCP+Projects+and+CIDR+Implementation
#   na-ne1-instance = {
#     region        = "northamerica-northeast1"
#     ip_range      = "10.58.24.0/22"
#     environments  = ["proto1", "proto2"]
#   }
# }

#Set to false to manage keys and IAM bindings in an existing keyring.
db_keyring_create = false
disk_keyring_create = false

#Customer Managed Encryption Key (CMEK) self link (e.g. `projects/foo/locations/us/keyRings/bar/cryptoKeys/baz`) used for disk and volume encryption (required for PAID Apigee Orgs only).
#type        = string
disk_encryption_key = "diskkey-2022-03-31"

#Google Kms Key Ring Name
#type        = string
kms_key_ring_name = "apigee-disk-keyring-02"  #Cannot be used again, must create new names

#Cloud KMS key self link (e.g. `projects/foo/locations/us/keyRings/bar/cryptoKeys/baz`) used for encrypting the data that is stored and replicated across runtime instances (immutable, used in Apigee X only).
#type        = string
database_encryption_key = "dbkey-2022-03-31"

# Google Kms Key DB Ring Name
#type        = string
kms_key_db_ring_name = "apigee-db-keyring-01" #Cannot be reused, must create new names if a destroy is done


#VPC Networks
# Create VPC. When set to false, uses a data source to reference existing VPC.
#type        = bool
vpc_create = false

#VPC network self link (requires service network peering enabled (Used in Apigee X only).
# type        = string
authorized_network_fqn = "projects/net-hub-infra/global/networks/int-cl-apigee-prototype-shared-vpc-1"
authorized_network = "not-being-used"

#Customer-provided CIDR block of length 22 for the Apigee instance.
#type        = string
#condition = try(cidrnetmask(var.ip_range), null) == "255.255.252.0" || try(cidrnetmask(var.ip_range), null) == "255.255.255.240"
ip_range = "10.58.24.0/22"

#Customer-provided CIDR block of length 28 for the Apigee instance.
#type        = string
#condition     = try(cidrnetmask(var.ip_range_support), null) == "255.255.255.240"
ip_range_support = "10.58.28.96/28"

# Set to true to create an auto mode subnet, defaults to custom mode.
#type        = bool
auto_create_subnetworks = false

#An optional folder containing the subnet configurations in YaML format.
#type        = string
# current example config/subnets
data_folder = null

# Set to true to delete the default routes at creation time.
#type        = bool
delete_default_routes_on_create = false

# An optional description of this resource (triggers recreation on change).
# type        = string
vpc_description = "Provided."

# DNS policy setup for the VPC.
/* type = object({
    inbound = bool
    logging = bool
    outbound = object({
      private_ns = list(string)
      public_ns  = list(string)
    })
  })
  */
dns_policy = null

# Default configuration for flow logs when enabled.
/* type = object({
    aggregation_interval = string
    flow_sampling        = number
    metadata             = string
  })
  default = {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
*/
log_config_defaults = {
  aggregation_interval = "INTERVAL_5_SEC"
  flow_sampling        = 0.5
  metadata             = "INCLUDE_ALL_METADATA"
}

#Map keyed by subnet 'region/name' of optional configurations for flow logs when enabled.
#type        = map(map(string))
log_configs = {}

# Maximum Transmission Unit in bytes. The minimum value for this field is 1460 and the maximum value is 1500 bytes.
#type = number
mtu = null

#VPC peering configuration.
/*type = object({
    peer_vpc_self_link = string
    export_routes      = bool
    import_routes      = bool
  })
  default = null
}
*/
peering_config = null

# Skip creation of peering on the remote end when using peering_config.
#type        = bool
peering_create_remote_end = true

#The Private Service Access configuration.
/* type = map(object({
    ranges = list(string) # CIDRs in the format x.x.x.x/yy
    routes = object({
      export = bool
      import = bool
    })
  }))
  */
psa_config = null


# Network routes, keyed by name.
/*type = map(object({
    dest_range    = string
    priority      = number
    tags          = list(string)
    next_hop_type = string # gateway, instance, ip, vpn_tunnel, ilb
    next_hop      = string
  }))
  */
routes = {}

# The network routing mode (default 'GLOBAL').
#type        = string
#condition     = var.routing_mode == "GLOBAL" || var.routing_mode == "REGIONAL"
routing_mode = "GLOBAL"

# Enable shared VPC for this project.
#type        = bool
shared_vpc_host = false

# Shared VPC service projects to register with this host.
# type = list(string)
shared_vpc_service_projects = []

# Optional map of subnet descriptions, keyed by subnet 'region/name'.
#type        = map(string)
subnet_descriptions = {}

# Optional map of boolean to control flow logs (default is disabled), keyed by subnet 'region/name'.
# type        = map(bool)
subnet_flow_logs = {}

#Optional map of boolean to control private Google access (default is enabled), keyed by subnet 'region/name'.
# type        = map(bool)
subnet_private_access = {}

#"List of subnets being created.
/*type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
    secondary_ip_range = map(string)
  }))
  */
subnets = []

# List of subnets for private HTTPS load balancer.
/*type = list(object({
    active        = bool
    name          = string
    ip_cidr_range = string
    region        = string
  }))
  */
subnets_l7ilb = []


# Service Account Creation


# Authoritative roles granted *on* the service accounts to other identities
#type        = string
service_account_usr = "serviceAccount:apigee-nprod-ws006-tf-prod@cantech-terraformers.iam.gserviceaccount.com" # ADD Service Account Email you created in the setup with the prefix serviceAccount:

# Name of the service account to create.
#type        = string
service_name = "apigeenprodws006service"

# Display name of the service account to create.
#type        = string
service_display_name = "Terraform-managed."

# Optional description.
#type        = string
service_description = null

# Prefix applied to service account names.
#type        = string
prefix = "srv"

# Path to public keys data files to upload to the service account (should have `.pem` extension).
#type        = string
public_keys_directory = ""

# Authoritative roles granted *on* the service accounts to other identities
#type        = string
service_account_create = true

# Generate a key for service account.
#type        = bool
generate_key = true


# IAM


# Subnet IAM bindings in {REGION/NAME => {ROLE => [MEMBERS]} format.
#type        = map(list(string))
iam = {}

# Billing account roles granted to the service account, by billing account id. Non-authoritative.
#type        = map(list(string))
iam_billing_roles = {}

# Folder roles granted to the service account, by folder id. Non-authoritative.
#type        = map(list(string))
iam_folder_roles = {}

# Organization roles granted to the service account, by organization id. Non-authoritative.
#type        = map(list(string))
iam_organization_roles = {}

# Project roles granted to the service account, by project id.
#type        = map(list(string))
iam_project_roles = {}

# Storage roles granted to the service account, by bucket name.
#type        = map(list(string))
iam_storage_roles = {}

# List of essential contacts for this resource. Must be in the form EMAIL -> [NOTIFICATION_TYPES]. Valid notification types are ALL, SUSPENSION, SECURITY, TECHNICAL, BILLING, LEGAL, PRODUCT_UPDATES.
#type        = map(list(string))
contacts = {}

# Map of role name => list of permissions to create in this project.
#type        = map(list(string))
custom_roles = {}

# Authoritative IAM binding for organization groups, in {GROUP_EMAIL => [ROLES]} format. Group emails need to be static. Can be used in combination with the `iam` variable.
#type        = map(list(string))
group_iam = {}

# Non authoritative IAM bindings, in {ROLE => [MEMBERS]} format.
#type        = map(list(string))
iam_additive = {}

# IAM additive bindings in {MEMBERS => [ROLE]} format. This might break if members are dynamic values.
#type        = map(list(string))
iam_additive_members = {}

# Service audit logging configuration. Service as key, map of log permission (eg DATA_READ) and excluded members as value for each service.
#type        = map(map(list(string)))
# default = {
#   allServices = {
#     DATA_READ = ["user:me@example.org"]
#   }
# }
iam_audit_config = {}

# IAM Authoritative service audit logging configuration. Service as key, map of log permission (eg DATA_READ) and excluded members as value for each service. Audit config should also be authoritative when using authoritative bindings. Use with caution.
#type        = map(map(list(string)))
# default = {
#   allServices = {
#     DATA_READ = ["user:me@example.org"]
#   }
# }
iam_audit_config_authoritative = null


# IAM authoritative bindings, in {ROLE => [MEMBERS]} format. Roles and members not explicitly listed will be cleared. Bindings should also be authoritative when using authoritative audit config. Use with caution.
#type        = map(list(string))
iam_bindings_authoritative = null



#Firewall Policies


# Hierarchical firewall policy rules created in the organization.
/*type = map(map(object({
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
*/
firewall_policies = {}


# The hierarchical firewall policy to associate to this folder. Must be either a key in the `firewall_policies` map or the id of a policy defined somewhere else.
#type        = map(string)
firewall_policy_association = {}

# Configuration for the firewall policy factory.
/*type = object({
    cidr_file   = string
    policy_name = string
    rules_file  = string
  })
*/
firewall_policy_factory = null

# Logging exclusions for this organization in the form {NAME -> FILTER}.
#type        = map(string)
logging_exclusions = {}


# Logging sinks to create for this organization.
/*type = map(object({
    destination          = string
    type                 = string // "bigquery", "logging", "pubsub", "storage"
    filter               = string
    include_children     = bool
    bq_partitioned_table = bool
    # TODO exclusions also support description and disabled
    exclusions = map(string)
  }))
*/
logging_sinks = {}



# Organizational Policies



# Map of boolean org policies and enforcement value, set value to null for policy restore.
#type        = map(bool)
policy_boolean = {}

# Map of list org policies, status is true for allow, false for deny, null for restore. Values can only be used for allow or deny.
/*type = map(object({
    inherit_from_parent = bool
    suggested_value     = string
    status              = bool
    values              = list(string)
  }))
*/
policy_list = {}

# Tag bindings for this organization, in key => tag value id format.
#type        = map(string)
tag_bindings = null

# Tags by key name. The `iam` attribute behaves like the similarly named one at module level.
/*type = map(object({
    description = string
    iam         = map(list(string))
    values = map(object({
      description = string
      iam         = map(list(string))
    }))
  }))
*/
tags = null

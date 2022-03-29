
# Terraform Script to create GCP infrastructure

The modules described below can also be used to provision paid Apigee X organizations. To create a paid organization you will have Create a network IP range with a CIDR length of /22, a google-managed-services-support-1 a network IP range with a CIDR length of /28, and add your KMS keys as described in the module documentation references located a the bottom of this document.

This is what this script can create:

1. Apigee Core Setup:
  * Setup Apigee
  * Create a Apigee instance
* Create a Key Rings (DB and Disk)
* Create a keys (DB and Disk)
* Create the Apigee service identity with permissions
* Create an organization
* Create an environments
* Create an environment groups
* Configure service networking

VPC module
    VPC network setup and configuration
    Peering Network setup and configuration
    Gateway configuration
    Level 4 Load balancer configuration
    Level 7 Load balancer configuration
    Routing setup and configuration
    VPN Tunnel setup and configuration
    Shared VPC Network setup and configuration
    Private Service Networking setup and configuration
    Private Service Networking with peering routes setup and configuration
    DNS Policies setup and configuration
    Subnet Factory using configuration file
      IAM Roles and Member Setup


Google Service Account Module and Organization Module -- Reguires GCP Orgainiztion Id -- -- If you don't have GCP Orgaization see the bottom of the Readme file for  the lines that need to be commented out.



Organization Module - See documentation for specifs about defining INGRESS
    IAM bindings, both authoritative and additive
    Custom IAM roles
    Audit logging configuration for services
    Organization policies


Google Service Account Module
    Create the Apigee service identity with IAM bindings
    Add Roles and Members to Service Account
        Create IAM billing Roles
        Create IAM Folder Roles
        Create IAM Organization Roles
        Create IAM Project Roles
        Create IAM Storage Roles
        Create Public Keys Directory






**Script variables going into the file terraform.tfvars





**Prerequisites:
Install Terraform for Windows
https://www.terraform.io/downloads.html


Org needs to be created

Project needs to be created

Compute Engine has to be enabled

Kuberentes Engine has to be enabled

Identity and Access Management (IAM) API has to be enabled

Cloud DNS API has to be enabled

Cloud Resource Manager API has to be enabled

Cloud Key Management Service (KMS) API has to be enabled

Cloud Billing API has to be enabled


Enable Service Network APIs

gcloud services enable compute.googleapis.com apigee.googleapis.com servicenetworking.googleapis.com --project $PROJECT_ID


Project IAM Admin permission has to be added

gcloud projects add-iam-policy-binding <YOUR GCLOUD PROJECT ID> \
--member=serviceAccount:<YOUR SERVICE ACCOUNT> \
--role=roles/resourcemanager.projectIamAdmin

Additonal permissions to add:
roles/servicenetworking.networksAdmin
roles/serviceaccount.serviceaccountadmin
roles/cloudkms.cloudkmsadmin




GCP

**To start with you need to run these commands in the CLI

PROJECT_ID=my-project-id

gcloud services enable compute.googleapis.com apigee.googleapis.com servicenetworking.googleapis.com --project $PROJECT_ID

gcloud projects add-iam-policy-binding <YOUR GCLOUD PROJECT ID> \
--member=serviceAccount:<YOUR SERVICE ACCOUNT> \
--role=roles/resourcemanager.projectIamAdmin

To get token call"

gcloud auth application-default print-access-token


You will need to go to API credentials and create a sevrvice Account for this script and add editor under projects for role

Then Go to the service you created and go to Keys and add a JSON key and download to the directory where you have your Terraform script.


Terraform Commands:

terraform init - Initial Process - after intial run use  flag: -upgrade

terraform fmt - Formats all the files for processing

terraform validate - Looks for errors in the script

terraform plan - Optional shows Plan before Applying

terraform apply - Create and modify deployment

terraform show - Show everything that was deployed

terraform output - Show Outputs

terraform destroy - Remove all services created by the script





Additional Terraform commands you might need:

terraform providers

terraform import google_project_service.my_project <your project id>/iam.googleapis.com   //Run only once








Reference for Modules:  

https://github.com/GoogleCloudPlatform/cloud-foundation-fabric

Apigee Core Setup
https://github.com/apigee/terraform-modules/tree/main/modules/apigee-x-core

Organization Module
https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/organization

VPC module
https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-vpc

Google Service Account Module
https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/iam-service-account










***** If not using a project with a GCP orgainization  comment out the following lines of code:



firewall-policies.tf:

   Comment entire code resource out






logging.tf:

    Comment entire code resource out




organization-policies.tf:

    Comment entire code resource out





locals.tf:
  
  Commenmt out Lines: 177 - 300
  
*
  organization_id_numeric = split("/", var.organization_id)[1]
  _group_iam_roles        = distinct(flatten(values(var.group_iam)))
  _group_iam = {
    for r in local._group_iam_roles : r => [
      for k, v in var.group_iam : "group:${k}" if try(index(v, r), null) != null
    ]
  }
  _iam_additive_pairs = flatten([
    for role, members in var.iam_additive : [
      for member in members : { role = role, member = member }
    ]
  ])


  _iam_additive_member_pairs = flatten([
    for member, roles in var.iam_additive_members : [
      for role in roles : { role = role, member = member }
    ]
  ])
  iam = {
    for role in distinct(concat(keys(var.iam), keys(local._group_iam))) :
    role => concat(
      try(var.iam[role], []),
      try(local._group_iam[role], [])
    )
  }
  iam_additive = {
    for pair in concat(local._iam_additive_pairs, local._iam_additive_member_pairs) :
    "${pair.role}-${pair.member}" => pair
  }

  _factory_cidrs = try(
    yamldecode(file(var.firewall_policy_factory.cidr_file)), {}
  )
  _factory_name = (
    try(var.firewall_policy_factory.policy_name, null) == null
    ? "factory"
    : var.firewall_policy_factory.policy_name
  )
  _factory_rules = try(
    yamldecode(file(var.firewall_policy_factory.rules_file)), {}
  )
  _factory_rules_parsed = {
    for name, rule in local._factory_rules : name => merge(rule, {
      ranges = flatten([
        for r in(rule.ranges == null ? [] : rule.ranges) :
        lookup(local._factory_cidrs, trimprefix(r, "$"), r)
      ])
    })
  }
  _merged_rules = flatten([
    for policy, rules in local.firewall_policies : [
      for name, rule in rules : merge(rule, {
        policy = policy
        name   = name
      })
    ]
  ])
  firewall_policies = merge(var.firewall_policies, (
    length(local._factory_rules) == 0
    ? {}
    : { (local._factory_name) = local._factory_rules_parsed }
  ))
  firewall_rules = {
    for r in local._merged_rules : "${r.policy}-${r.name}" => r
  }

  sink_bindings = {
    for type in ["bigquery", "logging", "pubsub", "storage"] :
    type => {
      for name, sink in var.logging_sinks :
      name => sink if sink.type == type
    }
  }

  _tag_values = flatten([
    for tag, attrs in local.tags : [
      for value, value_attrs in coalesce(attrs.values, {}) : {
        description = coalesce(
          value_attrs == null ? null : value_attrs.description,
          "Managed by the Terraform organization module."
        )
        key  = "${tag}/${value}"
        name = value
        roles = keys(coalesce(
          value_attrs == null ? null : value_attrs.iam, {}
        ))
        tag = tag
      }
    ]
  ])
  _tag_values_iam = flatten([
    for key, value_attrs in local.tag_values : [
      for role in value_attrs.roles : {
        key  = value_attrs.key
        name = value_attrs.name
        role = role
        tag  = value_attrs.tag
      }
    ]
  ])
  _tags_iam = flatten([
    for tag, attrs in local.tags : [
      for role in keys(coalesce(attrs.iam, {})) : {
        role = role
        tag  = tag
      }
    ]
  ])
  tag_values = {
    for t in local._tag_values : t.key => t
  }
  tag_values_iam = {
    for t in local._tag_values_iam : "${t.key}:${t.role}" => t
  }
  tags = {
    for k, v in coalesce(var.tags, {}) :
    k => v == null ? { description = null, iam = {}, values = null } : v
  }
  tags_iam = {
    for t in local._tags_iam : "${t.tag}:${t.role}" => t
  }
}
*/






outputs.tf:

Commenmt out Lines: 135 - 203

*
output "custom_role_id" {
  description = "Map of custom role IDs created in the organization."
  value = {
    for role_id, role in google_organization_iam_custom_role.roles :
    # build the string manually so that role IDs can be used as map
    # keys (useful for folder/organization/project-level iam bindings)
    (role_id) => "${var.organization_id}/roles/${role_id}"
  }
  depends_on = [
    google_organization_iam_custom_role.roles
  ]
}

output "custom_roles" {
  description = "Map of custom roles resources created in the organization."
  value       = google_organization_iam_custom_role.roles
}

output "firewall_policies" {
  description = "Map of firewall policy resources created in the organization."
  value       = { for k, v in google_compute_firewall_policy.policy : k => v }
}

output "firewall_policy_id" {
  description = "Map of firewall policy ids created in the organization."
  value       = { for k, v in google_compute_firewall_policy.policy : k => v.id }
}

output "organization_id" {
  description = "Organization id dependent on module resources."
  value       = var.organization_id
  depends_on = [
    google_organization_iam_audit_config.config,
    google_organization_iam_binding.authoritative,
    google_organization_iam_custom_role.roles,
    google_organization_iam_member.additive,
    google_organization_iam_policy.authoritative,
    google_organization_policy.boolean,
    google_organization_policy.list,
    google_tags_tag_key.default,
    google_tags_tag_key_iam_binding.default,
    google_tags_tag_value.default,
    google_tags_tag_value_iam_binding.default,
  ]
}

output "sink_writer_identities" {
  description = "Writer identities created for each sink."
  value = {
    for name, sink in google_logging_organization_sink.sink :
    name => sink.writer_identity
  }
}

output "tag_keys" {
  description = "Tag key resources."
  value = {
    for k, v in google_tags_tag_key.default : k => v
  }
}

output "tag_values" {
  description = "Tag value resources."
  value = {
    for k, v in google_tags_tag_value.default : k => v
  }
}
*/




resources.tf:
  
  Commenmt out Lines: 125 - 134

  /*
resource "google_essential_contacts_contact" "contact" {
  provider                            = google-beta
  for_each                            = var.contacts
  parent                              = var.organization_id
  email                               = each.key
  language_tag                        = "en"
  notification_category_subscriptions = each.value
}
*/




tags.tf:

  Comment entire code resource out





variables.tf:

Commenmt out Lines: 534 - 543

  /*
variable "organization_id" {
  description = "Organization id in organizations/nnnnnn format."
  type        = string
  validation {
    condition     = can(regex("^organizations/[0-9]+", var.organization_id))
    error_message = "The organization_id must in the form organizations/nnn."
  }
}
*/




  iam.tf

  Commenmt out Lines: 59 -131

  /*
resource "google_organization_iam_custom_role" "roles" {
  for_each    = var.custom_roles
  org_id      = local.organization_id_numeric
  role_id     = each.key
  title       = "Custom role ${each.key}"
  description = "Terraform-managed."
  permissions = each.value
}

resource "google_organization_iam_binding" "authoritative" {
  for_each = local.iam
  org_id   = local.organization_id_numeric
  role     = each.key
  members  = each.value
}

resource "google_organization_iam_member" "additive" {
  for_each = (
    length(var.iam_additive) + length(var.iam_additive_members) > 0
    ? local.iam_additive
    : {}
  )
  org_id = local.organization_id_numeric
  role   = each.value.role
  member = each.value.member
}


resource "google_organization_iam_policy" "authoritative" {
  count       = var.iam_bindings_authoritative != null || var.iam_audit_config_authoritative != null ? 1 : 0
  org_id      = local.organization_id_numeric
  policy_data = data.google_iam_policy.authoritative.policy_data
}

data "google_iam_policy" "authoritative" {
  dynamic "binding" {
    for_each = var.iam_bindings_authoritative != null ? var.iam_bindings_authoritative : {}
    content {
      role    = binding.key
      members = binding.value
    }
  }

  dynamic "audit_config" {
    for_each = var.iam_audit_config_authoritative != null ? var.iam_audit_config_authoritative : {}
    content {
      service = audit_config.key
      dynamic "audit_log_configs" {
        for_each = audit_config.value
        iterator = config
        content {
          log_type         = config.key
          exempted_members = config.value
        }
      }
    }
  }
}

resource "google_organization_iam_audit_config" "config" {
  for_each = var.iam_audit_config
  org_id   = local.organization_id_numeric
  service  = each.key
  dynamic "audit_log_config" {
    for_each = each.value
    iterator = config
    content {
      log_type         = config.key
      exempted_members = config.value
    }
  }
*/



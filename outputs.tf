output "instance_endpoints" {
  description = "Map of instance name -> internal runtime endpoint IP address"
  value = tomap({
    for name, instance in module.apigee-x-instance : name => instance.endpoint
  })
}
output "bindings" {
  description = "Subnet IAM bindings."
  value       = { for k, v in google_compute_subnetwork_iam_binding.binding : k => v }
}

# output "name" {
#   description = "The name of the VPC being created."
#   value       = local.network.name
#   depends_on = [
#     google_compute_network_peering.local,
#     google_compute_network_peering.remote,
#     google_compute_shared_vpc_host_project.shared_vpc_host,
#     google_compute_shared_vpc_service_project.service_projects,
#     google_service_networking_connection.psa_connection
#   ]
# }

output "network" {
  description = "Network resource."
  value       = local.network
  depends_on = [
    google_compute_network_peering.local,
    google_compute_network_peering.remote,
    google_compute_shared_vpc_host_project.shared_vpc_host,
    google_compute_shared_vpc_service_project.service_projects,
    google_service_networking_connection.psa_connection
  ]
}

output "project_id" {
  description = "Project ID containing the network. Use this when you need to create resources *after* the VPC is fully set up (e.g. subnets created, shared VPC service projects attached, Private Service Networking configured)."
  value       = var.project_id
  depends_on = [
    google_compute_subnetwork.subnetwork,
    google_compute_network_peering.local,
    google_compute_network_peering.remote,
    google_compute_shared_vpc_host_project.shared_vpc_host,
    google_compute_shared_vpc_service_project.service_projects,
    google_service_networking_connection.psa_connection
  ]
}

# output "self_link" {
#   description = "The URI of the VPC being created."
#   value       = local.network.self_link
#   depends_on = [
#     google_compute_network_peering.local,
#     google_compute_network_peering.remote,
#     google_compute_shared_vpc_host_project.shared_vpc_host,
#     google_compute_shared_vpc_service_project.service_projects,
#     google_service_networking_connection.psa_connection
#   ]
# }

output "subnet_ips" {
  description = "Map of subnet address ranges keyed by name."
  value = {
    for k, v in google_compute_subnetwork.subnetwork : k => v.ip_cidr_range
  }
}

output "subnet_regions" {
  description = "Map of subnet regions keyed by name."
  value = {
    for k, v in google_compute_subnetwork.subnetwork : k => v.region
  }
}

output "subnet_secondary_ranges" {
  description = "Map of subnet secondary ranges keyed by name."
  value = {
    for k, v in google_compute_subnetwork.subnetwork :
    k => {
      for range in v.secondary_ip_range :
      range.range_name => range.ip_cidr_range
    }
  }
}

output "subnet_self_links" {
  description = "Map of subnet self links keyed by name."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.self_link }
}

# TODO(ludoo): use input names as keys
output "subnets" {
  description = "Subnet resources."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v }
}

output "subnets_l7ilb" {
  description = "L7 ILB subnet resources."
  value       = { for k, v in google_compute_subnetwork.l7ilb : k => v }
}

output "email" {
  description = "Service account email."
  value       = local.resource_email_static
  depends_on = [
    local.service_account
  ]
}

output "iam_email" {
  description = "IAM-format service account email."
  value       = local.resource_iam_email_static
  depends_on = [
    local.service_account
  ]
}

output "key" {
  description = "Service account key."
  sensitive   = true
  value       = local.key
}

output "service_account" {
  description = "Service account resource."
  value       = local.service_account
}

output "service_account_credentials" {
  description = "Service account json credential templates for uploaded public keys data."
  value       = local.service_account_credential_templates
}



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

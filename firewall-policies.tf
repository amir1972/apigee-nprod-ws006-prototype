

resource "google_compute_firewall_policy" "policy" {
  for_each   = local.firewall_policies
  short_name = each.key
  parent     = var.organization_id
  depends_on = [
    google_organization_iam_audit_config.config,
    google_organization_iam_binding.authoritative,
    google_organization_iam_custom_role.roles,
    google_organization_iam_member.additive,
    google_organization_iam_policy.authoritative,
  ]
}


resource "google_compute_firewall_policy_rule" "rule" {
  for_each                = local.firewall_rules
  firewall_policy         = google_compute_firewall_policy.policy[each.value.policy].id
  action                  = each.value.action
  direction               = each.value.direction
  priority                = try(each.value.priority, null)
  target_resources        = try(each.value.target_resources, null)
  target_service_accounts = try(each.value.target_service_accounts, null)
  enable_logging          = try(each.value.logging, null)
  # preview                 = each.value.preview
  description = each.value.description
  match {
    src_ip_ranges  = each.value.direction == "INGRESS" ? each.value.ranges : null
    dest_ip_ranges = each.value.direction == "EGRESS" ? each.value.ranges : null
    dynamic "layer4_configs" {
      for_each = each.value.ports
      iterator = port
      content {
        ip_protocol = port.key
        ports       = port.value
      }
    }
  }
}
resource "google_compute_firewall_policy_association" "association" {
  for_each          = var.firewall_policy_association
  name              = replace(var.organization_id, "/", "-")
  attachment_target = var.organization_id
  firewall_policy   = try(google_compute_firewall_policy.policy[each.value].id, each.value)
}

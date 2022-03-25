

resource "google_organization_policy" "boolean" {
  for_each   = var.policy_boolean
  org_id     = local.organization_id_numeric
  constraint = each.key

  dynamic "boolean_policy" {
    for_each = each.value == null ? [] : [each.value]
    iterator = policy
    content {
      enforced = policy.value
    }
  }

  dynamic "restore_policy" {
    for_each = each.value == null ? [""] : []
    content {
      default = true
    }
  }

  depends_on = [
    google_organization_iam_audit_config.config,
    google_organization_iam_binding.authoritative,
    google_organization_iam_custom_role.roles,
    google_organization_iam_member.additive,
    google_organization_iam_policy.authoritative,
  ]
}

resource "google_organization_policy" "list" {
  for_each   = var.policy_list
  org_id     = local.organization_id_numeric
  constraint = each.key

  dynamic "list_policy" {
    for_each = each.value.status == null ? [] : [each.value]
    iterator = policy
    content {
      inherit_from_parent = policy.value.inherit_from_parent
      suggested_value     = policy.value.suggested_value
      dynamic "allow" {
        for_each = policy.value.status ? [""] : []
        content {
          values = (
            try(length(policy.value.values) > 0, false)
            ? policy.value.values
            : null
          )
          all = (
            try(length(policy.value.values) > 0, false)
            ? null
            : true
          )
        }
      }
      dynamic "deny" {
        for_each = policy.value.status ? [] : [""]
        content {
          values = (
            try(length(policy.value.values) > 0, false)
            ? policy.value.values
            : null
          )
          all = (
            try(length(policy.value.values) > 0, false)
            ? null
            : true
          )
        }
      }
    }
  }

  dynamic "restore_policy" {
    for_each = each.value.status == null ? [true] : []
    content {
      default = true
    }
  }

  depends_on = [
    google_organization_iam_audit_config.config,
    google_organization_iam_binding.authoritative,
    google_organization_iam_custom_role.roles,
    google_organization_iam_member.additive,
    google_organization_iam_policy.authoritative,
  ]
}

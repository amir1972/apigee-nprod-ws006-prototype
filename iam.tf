
resource "google_service_account_iam_binding" "roles" {
  for_each           = var.iam
  service_account_id = local.service_account.name
  role               = each.key
  members            = each.value
}

resource "google_project_iam_member" "project-roles" {
  for_each = {
    for pair in local.iam_project_pairs :
    "${pair.entity}-${pair.role}" => pair
  }
  project = each.value.entity
  role    = each.value.role
  member  = local.resource_iam_email
}

/*
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
*/

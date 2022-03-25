
resource "google_service_account_iam_binding" "roles" {
  for_each           = var.iam
  service_account_id = local.service_account.name
  role               = each.key
  members            = each.value
}

resource "google_billing_account_iam_member" "billing-roles" {
  for_each = {
    for pair in local.iam_billing_pairs :
    "${pair.entity}-${pair.role}" => pair
  }
  billing_account_id = each.value.entity
  role               = each.value.role
  member             = local.resource_iam_email
}

resource "google_folder_iam_member" "folder-roles" {
  for_each = {
    for pair in local.iam_folder_pairs :
    "${pair.entity}-${pair.role}" => pair
  }
  folder = each.value.entity
  role   = each.value.role
  member = local.resource_iam_email
}

resource "google_organization_iam_member" "organization-roles" {
  for_each = {
    for pair in local.iam_organization_pairs :
    "${pair.entity}-${pair.role}" => pair
  }
  org_id = each.value.entity
  role   = each.value.role
  member = local.resource_iam_email
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

resource "google_storage_bucket_iam_member" "bucket-roles" {
  for_each = {
    for pair in local.iam_storage_pairs :
    "${pair.entity}-${pair.role}" => pair
  }
  bucket = each.value.entity
  role   = each.value.role
  member = local.resource_iam_email
}

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
}
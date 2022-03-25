
# keys

resource "google_tags_tag_key" "default" {
  for_each   = local.tags
  parent     = var.organization_id
  short_name = each.key
  description = coalesce(
    each.value.description,
    "Managed by the Terraform organization module."
  )
  depends_on = [
    google_organization_iam_binding.authoritative,
    google_organization_iam_member.additive,
    google_organization_iam_policy.authoritative,
  ]
}


resource "google_tags_tag_key_iam_binding" "default" {
  for_each = local.tags_iam
  tag_key  = google_tags_tag_key.default[each.value.tag].id
  role     = each.value.role
  members = coalesce(
    local.tags[each.value.tag]["iam"][each.value.role], []
  )
}

# values

resource "google_tags_tag_value" "default" {
  for_each   = local.tag_values
  parent     = google_tags_tag_key.default[each.value.tag].id
  short_name = each.value.name
  description = coalesce(
    each.value.description,
    "Managed by the Terraform organization module."
  )
}

resource "google_tags_tag_value_iam_binding" "default" {
  for_each  = local.tag_values_iam
  tag_value = google_tags_tag_value.default[each.value.key].id
  role      = each.value.role
  members = coalesce(
    local.tags[each.value.tag]["values"][each.value.name]["iam"][each.value.role],
    []
  )
}

# bindings

resource "google_tags_tag_binding" "binding" {
  for_each  = coalesce(var.tag_bindings, {})
  parent    = "//cloudresourcemanager.googleapis.com/${var.organization_id}"
  tag_value = each.value
}

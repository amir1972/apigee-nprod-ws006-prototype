resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}

data "google_service_account" "service_account" {
  count      = var.service_account_create ? 0 : 1
  project    = var.project_id
  account_id = "${local.prefix}${var.service_name}"
}

resource "google_service_account" "service_account" {
  count        = var.service_account_create ? 1 : 0
  project      = var.project_id
  account_id   = "${local.prefix}${var.service_name}"
  display_name = var.service_display_name
  description  = var.service_description
}

resource "google_service_account_key" "key" {
  for_each           = var.generate_key ? { 1 = 1 } : {}
  service_account_id = local.service_account.email
}

resource "google_service_account_key" "upload_key" {
  for_each           = local.public_keys_data
  service_account_id = local.service_account.email
  public_key_data    = each.value
}

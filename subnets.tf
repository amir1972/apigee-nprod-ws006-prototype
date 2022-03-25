
resource "google_compute_subnetwork" "subnetwork" {
  for_each      = local.subnets
  project       = var.project_id
  network       = local.network.name
  region        = each.value.region
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  secondary_ip_range = each.value.secondary_ip_range == null ? [] : [
    for name, range in each.value.secondary_ip_range :
    { range_name = name, ip_cidr_range = range }
  ]
  description = lookup(
    local.subnet_descriptions, each.key, "Terraform-managed."
  )
  private_ip_google_access = lookup(
    local.subnet_private_access, each.key, true
  )
  dynamic "log_config" {
    for_each = toset(
      try(local.subnet_flow_logs[each.key], {}) != {}
      ? [local.subnet_flow_logs[each.key]]
      : []
    )
    iterator = config
    content {
      aggregation_interval = config.value.aggregation_interval
      flow_sampling        = config.value.flow_sampling
      metadata             = config.value.metadata
    }
  }
}
resource "google_compute_subnetwork" "l7ilb" {
  provider      = google-beta
  for_each      = local.subnets_l7ilb
  project       = var.project_id
  network       = local.network.name
  region        = each.value.region
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role = (
    each.value.active || each.value.active == null ? "ACTIVE" : "BACKUP"
  )
  description = lookup(
    local.subnet_descriptions,
    "${each.value.region}/${each.value.name}",
    "Terraform-managed."
  )
}

resource "google_compute_subnetwork_iam_binding" "binding" {
  for_each = {
    for binding in local.subnet_iam_members :
    "${binding.subnet}.${binding.role}" => binding
  }
  project    = var.project_id
  subnetwork = google_compute_subnetwork.subnetwork[each.value.subnet].name
  region     = google_compute_subnetwork.subnetwork[each.value.subnet].region
  role       = each.value.role
  members    = each.value.members
}


resource "google_compute_global_address" "psa_ranges" {
  for_each      = local.psa_config.ranges
  project       = var.project_id
  name          = each.key
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", each.value)[0]
  prefix_length = split("/", each.value)[1]
  network       = local.network.id
}

resource "google_service_networking_connection" "psa_connection" {
  for_each = var.psa_config == null ? {} : { 1 = 1 }
  network  = local.network.id
  service  = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    for k, v in google_compute_global_address.psa_ranges : v.name
  ]
}

resource "google_compute_network_peering_routes_config" "psa_routes" {
  for_each             = var.psa_config == null ? {} : { 1 = 1 }
  project              = var.project_id
  peering              = google_service_networking_connection.psa_connection["1"].peering
  network              = local.network.name
  export_custom_routes = try(var.psa_config.routes.export, false)
  import_custom_routes = try(var.psa_config.routes.import, false)
}
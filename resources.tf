
#data "google_compute_network" "network" {
#  count   = var.vpc_create ? 0 : 1
#  project = var.project_id
#  name    = var.authorized_network
#}
resource "google_compute_network" "network" {
  count                           = var.vpc_create ? 1 : 0
  project                         = var.project_id
  name                            = var.authorized_network
  description                     = var.vpc_description
  auto_create_subnetworks         = var.auto_create_subnetworks
  delete_default_routes_on_create = var.delete_default_routes_on_create
  mtu                             = var.mtu
  routing_mode                    = var.routing_mode
}
resource "google_compute_network_peering" "local" {
  provider             = google-beta
  count                = var.peering_config == null ? 0 : 1
  name                 = "${var.authorized_network}-${local.peer_network}"
  network              = local.network.self_link
  peer_network         = var.peering_config.peer_vpc_self_link
  export_custom_routes = var.peering_config.export_routes
  import_custom_routes = var.peering_config.import_routes
}
resource "google_compute_network_peering" "remote" {
  provider             = google-beta
  count                = var.peering_config != null && var.peering_create_remote_end ? 1 : 0
  name                 = "${local.peer_network}-${var.authorized_network}"
  network              = var.peering_config.peer_vpc_self_link
  peer_network         = local.network.self_link
  export_custom_routes = var.peering_config.import_routes
  import_custom_routes = var.peering_config.export_routes
  depends_on           = [google_compute_network_peering.local]
}
resource "google_compute_shared_vpc_host_project" "shared_vpc_host" {
  provider   = google-beta
  count      = var.shared_vpc_host ? 1 : 0
  project    = var.project_id
  depends_on = [local.network]
}
resource "google_compute_shared_vpc_service_project" "service_projects" {
  provider = google-beta
  for_each = (
    var.shared_vpc_host && var.shared_vpc_service_projects != null
    ? toset(var.shared_vpc_service_projects)
    : toset([])
  )
  host_project    = var.project_id
  service_project = each.value
  depends_on      = [google_compute_shared_vpc_host_project.shared_vpc_host]
}

resource "google_dns_policy" "default" {
  count                     = var.dns_policy == null ? 0 : 1
  enable_inbound_forwarding = var.dns_policy.inbound
  enable_logging            = var.dns_policy.logging
  name                      = var.authorized_network
  project                   = var.project_id
  networks {
    network_url = local.network.id
  }

  dynamic "alternative_name_server_config" {
    for_each = toset(var.dns_policy.outbound == null ? [] : [""])
    content {
      dynamic "target_name_servers" {
        for_each = toset(var.dns_policy.outbound.private_ns)
        iterator = ns
        content {
          ipv4_address    = ns.key
          forwarding_path = "private"
        }
      }
      dynamic "target_name_servers" {
        for_each = toset(var.dns_policy.outbound.public_ns)
        iterator = ns
        content {
          ipv4_address = ns.key
        }
      }
    }
  }
}

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


resource "google_essential_contacts_contact" "contact" {
  provider                            = google-beta
  for_each                            = var.contacts
  parent                              = var.organization_id
  email                               = each.key
  language_tag                        = "en"
  notification_category_subscriptions = each.value
}


resource "google_compute_route" "gateway" {
  for_each         = local.routes.gateway
  project          = var.project_id
  network          = local.network.name
  name             = "${var.authorized_network}-${each.key}"
  description      = "Terraform-managed."
  dest_range       = each.value.dest_range
  priority         = each.value.priority
  tags             = each.value.tags
  next_hop_gateway = each.value.next_hop
}

resource "google_compute_route" "ilb" {
  for_each     = local.routes.ilb
  project      = var.project_id
  network      = local.network.name
  name         = "${var.authorized_network}-${each.key}"
  description  = "Terraform-managed."
  dest_range   = each.value.dest_range
  priority     = each.value.priority
  tags         = each.value.tags
  next_hop_ilb = each.value.next_hop
}

resource "google_compute_route" "instance" {
  for_each          = local.routes.instance
  project           = var.project_id
  network           = local.network.name
  name              = "${var.authorized_network}-${each.key}"
  description       = "Terraform-managed."
  dest_range        = each.value.dest_range
  priority          = each.value.priority
  tags              = each.value.tags
  next_hop_instance = each.value.next_hop
  # not setting the instance zone will trigger a refresh
  next_hop_instance_zone = regex("zones/([^/]+)/", each.value.next_hop)[0]
}

resource "google_compute_route" "ip" {
  for_each    = local.routes.ip
  project     = var.project_id
  network     = local.network.name
  name        = "${var.authorized_network}-${each.key}"
  description = "Terraform-managed."
  dest_range  = each.value.dest_range
  priority    = each.value.priority
  tags        = each.value.tags
  next_hop_ip = each.value.next_hop
}

resource "google_compute_route" "vpn_tunnel" {
  for_each            = local.routes.vpn_tunnel
  project             = var.project_id
  network             = local.network.name
  name                = "${var.authorized_network}-${each.key}"
  description         = "Terraform-managed."
  dest_range          = each.value.dest_range
  priority            = each.value.priority
  tags                = each.value.tags
  next_hop_vpn_tunnel = each.value.next_hop
}
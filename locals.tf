
locals {

  peer_network = (
    var.peering_config == null
    ? null
    : element(reverse(split("/", var.peering_config.peer_vpc_self_link)), 0)
  )
  #psa_ranges = { for e in local._psa_ranges : e.name => e }

  # https://github.com/hashicorp/terraform/issues/22405#issuecomment-591917758
  key = try(
    var.generate_key
    ? google_service_account_key.key["1"]
    : map("", null)
  , {})
  prefix                    = var.prefix != null ? "${var.prefix}-" : ""
  resource_email_static     = "${local.prefix}${var.service_name}@${var.project_id}.iam.gserviceaccount.com"
  resource_iam_email_static = "serviceAccount:${local.resource_email_static}"
  resource_iam_email        = local.service_account != null ? "serviceAccount:${local.service_account.email}" : local.resource_iam_email_static
  service_account = (
    var.service_account_create
    ? try(google_service_account.service_account.0, null)
    : try(data.google_service_account.service_account.0, null)
  )
  service_account_credential_templates = {
    for file, _ in local.public_keys_data : file => jsonencode(
      {
        type : "service_account",
        project_id : var.project_id,
        private_key_id : split("/", google_service_account_key.upload_key[file].id)[5]
        private_key : "REPLACE_ME_WITH_PRIVATE_KEY_DATA"
        client_email : local.resource_email_static
        client_id : local.service_account.unique_id,
        auth_uri : "https://accounts.google.com/o/oauth2/auth",
        token_uri : "https://oauth2.googleapis.com/token",
        auth_provider_x509_cert_url : "https://www.googleapis.com/oauth2/v1/certs",
        client_x509_cert_url : "https://www.googleapis.com/robot/v1/metadata/x509/${urlencode(local.resource_email_static)}"
      }
    )
  }
  public_keys_data = (
    var.public_keys_directory != ""
    ? {
      for file in fileset("${path.root}/${var.public_keys_directory}", "*.pem")
    : file => filebase64("${path.root}/${var.public_keys_directory}/${file}") }
    : {}
  )

  iam_billing_pairs = flatten([
    for entity, roles in var.iam_billing_roles : [
      for role in roles : [
        { entity = entity, role = role }
      ]
    ]
  ])
  iam_folder_pairs = flatten([
    for entity, roles in var.iam_folder_roles : [
      for role in roles : [
        { entity = entity, role = role }
      ]
    ]
  ])
  iam_organization_pairs = flatten([
    for entity, roles in var.iam_organization_roles : [
      for role in roles : [
        { entity = entity, role = role }
      ]
    ]
  ])
  iam_project_pairs = flatten([
    for entity, roles in var.iam_project_roles : [
      for role in roles : [
        { entity = entity, role = role }
      ]
    ]
  ])
  iam_storage_pairs = flatten([
    for entity, roles in var.iam_storage_roles : [
      for role in roles : [
        { entity = entity, role = role }
      ]
    ]
  ])
  psa_config = (
    var.psa_config == null
    ? { ranges = {}, routes = null }
    : var.psa_config
  )

  _routes = var.routes == null ? {} : var.routes
  routes = {
    gateway    = { for k, v in local._routes : k => v if v.next_hop_type == "gateway" }
    ilb        = { for k, v in local._routes : k => v if v.next_hop_type == "ilb" }
    instance   = { for k, v in local._routes : k => v if v.next_hop_type == "instance" }
    ip         = { for k, v in local._routes : k => v if v.next_hop_type == "ip" }
    vpn_tunnel = { for k, v in local._routes : k => v if v.next_hop_type == "vpn_tunnel" }
  }

  _factory_data = var.data_folder == null ? tomap({}) : {
    for f in fileset(var.data_folder, "**/*.yaml") :
    trimsuffix(basename(f), ".yaml") => yamldecode(file("${var.data_folder}/${f}"))
  }
  _factory_descriptions = {
    for k, v in local._factory_data :
    "${v.region}/${k}" => try(v.description, null)
  }
  _factory_iam_members = [
    for k, v in local._factory_subnets : {
      subnet = k
      role   = "roles/compute.networkUser"
      members = concat(
        formatlist("group:%s", try(v.iam_groups, [])),
        formatlist("user:%s", try(v.iam_users, [])),
        formatlist("serviceAccount:%s", try(v.iam_service_accounts, []))
      )
    }
  ]
  _factory_flow_logs = {
    for k, v in local._factory_data : "${v.region}/${k}" => merge(
      var.log_config_defaults, try(v.flow_logs, {})
    ) if try(v.flow_logs, false)
  }
  _factory_private_access = {
    for k, v in local._factory_data : "${v.region}/${k}" => try(
      v.private_ip_google_access, true
    )
  }
  _factory_subnets = {
    for k, v in local._factory_data : "${v.region}/${k}" => {
      ip_cidr_range      = v.ip_cidr_range
      name               = k
      region             = v.region
      secondary_ip_range = try(v.secondary_ip_range, {})
    }
  }
  _iam = var.iam == null ? {} : var.iam
  _subnet_flow_logs = {
    for k, v in var.subnet_flow_logs : k => merge(
      var.log_config_defaults, try(var.log_configs[k], {})
    )
  }
  _subnet_iam_members = flatten([
    for subnet, roles in local._iam : [
      for role, members in roles : {
        members = members
        role    = role
        subnet  = subnet
      }
    ]
  ])
  subnet_descriptions = merge(
    local._factory_descriptions, var.subnet_descriptions
  )
  subnet_iam_members = concat(
    local._factory_iam_members, local._subnet_iam_members
  )
  subnet_flow_logs = merge(
    local._factory_flow_logs, local._subnet_flow_logs
  )
  subnet_private_access = merge(
    local._factory_private_access, var.subnet_private_access
  )
  subnets = merge(
    { for subnet in var.subnets : "${subnet.region}/${subnet.name}" => subnet },
    local._factory_subnets
  )
  subnets_l7ilb = {
    for subnet in var.subnets_l7ilb :
    "${subnet.region}/${subnet.name}" => subnet
  }

  organization_id_numeric = split("/", var.organization_id)[1]
  _group_iam_roles        = distinct(flatten(values(var.group_iam)))
  _group_iam = {
    for r in local._group_iam_roles : r => [
      for k, v in var.group_iam : "group:${k}" if try(index(v, r), null) != null
    ]
  }
  _iam_additive_pairs = flatten([
    for role, members in var.iam_additive : [
      for member in members : { role = role, member = member }
    ]
  ])


  _iam_additive_member_pairs = flatten([
    for member, roles in var.iam_additive_members : [
      for role in roles : { role = role, member = member }
    ]
  ])
  iam = {
    for role in distinct(concat(keys(var.iam), keys(local._group_iam))) :
    role => concat(
      try(var.iam[role], []),
      try(local._group_iam[role], [])
    )
  }
  iam_additive = {
    for pair in concat(local._iam_additive_pairs, local._iam_additive_member_pairs) :
    "${pair.role}-${pair.member}" => pair
  }

  _factory_cidrs = try(
    yamldecode(file(var.firewall_policy_factory.cidr_file)), {}
  )
  _factory_name = (
    try(var.firewall_policy_factory.policy_name, null) == null
    ? "factory"
    : var.firewall_policy_factory.policy_name
  )
  _factory_rules = try(
    yamldecode(file(var.firewall_policy_factory.rules_file)), {}
  )
  _factory_rules_parsed = {
    for name, rule in local._factory_rules : name => merge(rule, {
      ranges = flatten([
        for r in(rule.ranges == null ? [] : rule.ranges) :
        lookup(local._factory_cidrs, trimprefix(r, "$"), r)
      ])
    })
  }
  _merged_rules = flatten([
    for policy, rules in local.firewall_policies : [
      for name, rule in rules : merge(rule, {
        policy = policy
        name   = name
      })
    ]
  ])
  firewall_policies = merge(var.firewall_policies, (
    length(local._factory_rules) == 0
    ? {}
    : { (local._factory_name) = local._factory_rules_parsed }
  ))
  firewall_rules = {
    for r in local._merged_rules : "${r.policy}-${r.name}" => r
  }

  sink_bindings = {
    for type in ["bigquery", "logging", "pubsub", "storage"] :
    type => {
      for name, sink in var.logging_sinks :
      name => sink if sink.type == type
    }
  }

  _tag_values = flatten([
    for tag, attrs in local.tags : [
      for value, value_attrs in coalesce(attrs.values, {}) : {
        description = coalesce(
          value_attrs == null ? null : value_attrs.description,
          "Managed by the Terraform organization module."
        )
        key  = "${tag}/${value}"
        name = value
        roles = keys(coalesce(
          value_attrs == null ? null : value_attrs.iam, {}
        ))
        tag = tag
      }
    ]
  ])
  _tag_values_iam = flatten([
    for key, value_attrs in local.tag_values : [
      for role in value_attrs.roles : {
        key  = value_attrs.key
        name = value_attrs.name
        role = role
        tag  = value_attrs.tag
      }
    ]
  ])
  _tags_iam = flatten([
    for tag, attrs in local.tags : [
      for role in keys(coalesce(attrs.iam, {})) : {
        role = role
        tag  = tag
      }
    ]
  ])
  tag_values = {
    for t in local._tag_values : t.key => t
  }
  tag_values_iam = {
    for t in local._tag_values_iam : "${t.key}:${t.role}" => t
  }
  tags = {
    for k, v in coalesce(var.tags, {}) :
    k => v == null ? { description = null, iam = {}, values = null } : v
  }
  tags_iam = {
    for t in local._tags_iam : "${t.tag}:${t.role}" => t
  }
  
}


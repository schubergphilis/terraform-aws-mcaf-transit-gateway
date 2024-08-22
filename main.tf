locals {
  transit_gateway_peering_route_tables = flatten([
    for key, peer in var.transit_gateway_peering : [
      for route_table, routes in peer.peer_routes : {
        peer_name   = key
        route_table = route_table
        routes      = routes
      }
    ]
  ])

  transit_gateway_peering_routes = flatten([
    for peer in local.transit_gateway_peering_route_tables : [
      for route in peer.routes : {
        peer_name   = peer.peer_name
        route_table = peer.route_table
        route       = route
      }
    ]
  ])

  transit_gateway_sharing_route_table_propagation = flatten([
    for name in var.transit_gateway_sharing : [
      for route_table in name.route_table_propagation : {
        transit_gateway_attachment_id = name.transit_gateway_attachment_id
        route_table                   = route_table
      }
    ]
  ])

  vpn_connection_route_table_propagation = flatten([
    for key, vpn in var.vpn_connection : [
      for route_table in vpn.route_table_propagation : {
        name        = key
        route_table = route_table
      }
    ]
  ])
}

data "aws_caller_identity" "default" {}

data "aws_region" "default" {}

################################################################################
# Transit gateway
################################################################################

resource "aws_ec2_transit_gateway" "default" {
  amazon_side_asn                 = var.transit_gateway_asn
  auto_accept_shared_attachments  = var.transit_gateway_auto_accept_shared_attachments ? "enable" : "disable"
  default_route_table_association = var.transit_gateway_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.transit_gateway_default_route_table_propagation ? "enable" : "disable"
  description                     = var.description
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks
  tags                            = merge(var.tags, { Name = var.name })
}

resource "aws_ec2_transit_gateway_route_table" "default" {
  for_each = toset(var.route_tables)

  transit_gateway_id = aws_ec2_transit_gateway.default.id
  tags               = merge(var.tags, { Name = each.key })
}

################################################################################
# Transit gateway flow logs policy
################################################################################

resource "aws_iam_role" "transit_gateway_cloudwatch_flow_logs" {
  count = var.enable_cloudwatch_flow_logs ? 1 : 0

  name_prefix        = var.cloudwatch_flow_logs_configuration.iam_role_name_prefix
  assume_role_policy = data.aws_iam_policy_document.transit_gateway_cloudwatch_flow_logs_assume_role.json
}

data "aws_iam_policy_document" "transit_gateway_cloudwatch_flow_logs_assume_role" {
  statement {
    sid = "AWSTransitGatewayFlowLogsAssumeRole"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "transit_gateway_cloudwatch_flow_logs" {
  count = var.enable_cloudwatch_flow_logs ? 1 : 0

  role       = aws_iam_role.transit_gateway_cloudwatch_flow_logs[0].name
  policy_arn = aws_iam_policy.transit_gateway_cloudwatch_flow_logs[0].arn
}

resource "aws_iam_policy" "transit_gateway_cloudwatch_flow_logs" {
  count = var.enable_cloudwatch_flow_logs ? 1 : 0

  name_prefix = var.cloudwatch_flow_logs_configuration.iam_policy_name_prefix
  policy      = data.aws_iam_policy_document.transit_gateway_cloudwatch_flow_log.json
}

data "aws_iam_policy_document" "transit_gateway_cloudwatch_flow_log" {
  statement {
    sid    = "AWSTransitGatewayFlowLogsPushToCloudWatch"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:log-group:*:*"]
  }
}

################################################################################
# Transit gateway flow logs
################################################################################

resource "aws_cloudwatch_log_group" "transit_gateway_flow_logs" {
  count = var.enable_cloudwatch_flow_logs ? 1 : 0

  name              = var.cloudwatch_flow_logs_configuration.log_group_name
  kms_key_id        = var.cloudwatch_flow_logs_configuration.kms_key_arn
  retention_in_days = var.cloudwatch_flow_logs_configuration.retention_in_days
  tags              = var.tags
}

resource "aws_flow_log" "cloudwatch_transit_gateway" {
  count = var.enable_cloudwatch_flow_logs ? 1 : 0

  iam_role_arn             = aws_iam_role.transit_gateway_cloudwatch_flow_logs[0].arn
  log_destination          = aws_cloudwatch_log_group.transit_gateway_flow_logs[0].arn
  max_aggregation_interval = var.cloudwatch_flow_logs_configuration.max_aggregation_interval
  traffic_type             = var.cloudwatch_flow_logs_configuration.traffic_type
  transit_gateway_id       = aws_ec2_transit_gateway.default.id
}

resource "aws_flow_log" "s3_transit_gateway" {
  count = var.enable_s3_flow_logs ? 1 : 0

  log_destination          = var.s3_flow_logs_configuration.log_destination
  log_destination_type     = "s3"
  max_aggregation_interval = var.s3_flow_logs_configuration.max_aggregation_interval
  traffic_type             = var.s3_flow_logs_configuration.traffic_type
  transit_gateway_id       = aws_ec2_transit_gateway.default.id

  destination_options {
    file_format        = var.s3_flow_logs_configuration.file_format
    per_hour_partition = var.s3_flow_logs_configuration.per_hour_partition
  }
}

################################################################################
# Transit gateway peering
################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "default" {
  for_each = var.transit_gateway_peering

  peer_account_id         = each.value.peer_account_id
  peer_region             = each.value.peer_region
  peer_transit_gateway_id = each.value.peer_transit_gateway_id
  transit_gateway_id      = aws_ec2_transit_gateway.default.id
  tags                    = { "Name" = each.key }
}

resource "aws_ec2_transit_gateway_route_table_association" "peering" {
  for_each = { for name, peering_configuration in var.transit_gateway_peering : name => peering_configuration if peering_configuration.route_table_association != "" }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.default[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default[each.value.route_table_association].id
}

resource "aws_ec2_transit_gateway_route" "peering" {
  for_each = { for route in local.transit_gateway_peering_routes : "${route.peer_name}_${route.route_table}_${route.route}" => route }

  destination_cidr_block         = each.value.route
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.default[each.value.peer_name].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default[each.value.route_table].id
}

################################################################################
# Transit gateway sharing
################################################################################

resource "aws_ram_resource_share" "default" {
  count = length(var.transit_gateway_sharing) == 0 ? 0 : 1

  name                      = "${var.name}-share"
  allow_external_principals = true
  tags                      = var.tags
}

resource "aws_ram_resource_association" "default" {
  count = length(var.transit_gateway_sharing) == 0 ? 0 : 1

  resource_arn       = aws_ec2_transit_gateway.default.arn
  resource_share_arn = aws_ram_resource_share.default[0].arn
}

resource "aws_ram_principal_association" "default" {
  for_each = var.transit_gateway_sharing

  principal          = each.value.principal
  resource_share_arn = aws_ram_resource_share.default[0].arn
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "default" {
  for_each = { for name, sharing_configuration in var.transit_gateway_sharing : name => sharing_configuration if sharing_configuration.transit_gateway_attachment_id != "" }

  transit_gateway_attachment_id                   = each.value.transit_gateway_attachment_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags                                            = merge(var.tags, { Name = each.key })
}

resource "time_sleep" "ten_seconds" {
  for_each = { for name, sharing_configuration in var.transit_gateway_sharing : name => sharing_configuration if sharing_configuration.transit_gateway_attachment_id != "" }

  create_duration = "10s"
  depends_on      = [aws_ec2_transit_gateway_vpc_attachment_accepter.default]
}

resource "aws_ec2_transit_gateway_route_table_association" "sharing" {
  for_each = { for name, sharing_configuration in var.transit_gateway_sharing : name => sharing_configuration if sharing_configuration.transit_gateway_attachment_id != "" }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment_accepter.default[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default[each.value.route_table_association].id
  depends_on                     = [time_sleep.ten_seconds]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "sharing" {
  for_each = { for route_table in local.transit_gateway_sharing_route_table_propagation : route_table.route_table => route_table if route_table.transit_gateway_attachment_id != "" }

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default[each.value.route_table].id
  depends_on                     = [time_sleep.ten_seconds]
}

################################################################################
# Transit gateway VPN
################################################################################

resource "aws_customer_gateway" "default" {
  for_each = var.vpn_connection

  ip_address = each.value.customer_gateway_ip_address
  bgp_asn    = each.value.customer_gateway_bgp_asn
  type       = "ipsec.1"
  tags       = merge(var.tags, { Name = each.key })
}

resource "aws_vpn_connection" "default" {
  for_each = var.vpn_connection

  customer_gateway_id                     = aws_customer_gateway.default[each.key].id
  outside_ip_address_type                 = each.value.outside_ip_address_type
  transit_gateway_id                      = aws_ec2_transit_gateway.default.id
  transport_transit_gateway_attachment_id = each.value.outside_ip_address_type == "PrivateIpv4" ? data.aws_ec2_transit_gateway_dx_gateway_attachment.default[each.key].id : null
  type                                    = "ipsec.1"

  tunnel1_dpd_timeout_action           = each.value.tunnel1_options.dpd_timeout_action
  tunnel1_dpd_timeout_seconds          = each.value.tunnel1_options.dpd_timeout_seconds
  tunnel1_ike_versions                 = each.value.tunnel1_options.ike_versions
  tunnel1_inside_cidr                  = each.value.tunnel1_options.inside_cidr
  tunnel1_phase1_dh_group_numbers      = each.value.tunnel1_options.phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms = each.value.tunnel1_options.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = each.value.tunnel1_options.phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds      = each.value.tunnel1_options.phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers      = each.value.tunnel1_options.phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms = each.value.tunnel1_options.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = each.value.tunnel1_options.phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds      = each.value.tunnel1_options.phase2_lifetime_seconds
  tunnel1_rekey_fuzz_percentage        = each.value.tunnel1_options.rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds    = each.value.tunnel1_options.rekey_margin_time_seconds
  tunnel1_replay_window_size           = each.value.tunnel1_options.replay_window_size
  tunnel1_startup_action               = each.value.tunnel1_options.startup_action

  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled       = each.value.enable_logs
      log_group_arn     = each.value.enable_logs ? aws_cloudwatch_log_group.transit_gateway_vpn_logs[each.key].arn : ""
      log_output_format = each.value.log_output_format
    }
  }

  tunnel2_dpd_timeout_action           = each.value.tunnel2_options.dpd_timeout_action
  tunnel2_dpd_timeout_seconds          = each.value.tunnel2_options.dpd_timeout_seconds
  tunnel2_ike_versions                 = each.value.tunnel2_options.ike_versions
  tunnel2_inside_cidr                  = each.value.tunnel2_options.inside_cidr
  tunnel2_phase1_dh_group_numbers      = each.value.tunnel2_options.phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms = each.value.tunnel2_options.phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = each.value.tunnel2_options.phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds      = each.value.tunnel2_options.phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers      = each.value.tunnel2_options.phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms = each.value.tunnel2_options.phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms  = each.value.tunnel2_options.phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds      = each.value.tunnel2_options.phase2_lifetime_seconds
  tunnel2_rekey_fuzz_percentage        = each.value.tunnel2_options.rekey_fuzz_percentage
  tunnel2_rekey_margin_time_seconds    = each.value.tunnel2_options.rekey_margin_time_seconds
  tunnel2_replay_window_size           = each.value.tunnel2_options.replay_window_size
  tunnel2_startup_action               = each.value.tunnel2_options.startup_action

  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled       = each.value.enable_logs
      log_group_arn     = each.value.enable_logs ? aws_cloudwatch_log_group.transit_gateway_vpn_logs[each.key].arn : ""
      log_output_format = each.value.log_output_format
    }
  }

  tags = merge(var.tags, { Name = each.key })
}

resource "aws_ec2_transit_gateway_route_table_association" "vpn" {
  for_each = var.vpn_connection

  transit_gateway_attachment_id  = aws_vpn_connection.default[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default[each.value.route_table_association].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn" {
  for_each = { for vpn in local.vpn_connection_route_table_propagation : "${vpn.name}_${vpn.route_table}" => vpn }

  transit_gateway_attachment_id  = aws_vpn_connection.default[each.value.name].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default[each.value.route_table].id
}

resource "aws_ec2_tag" "vpn" {
  for_each = var.vpn_connection

  resource_id = aws_vpn_connection.default[each.key].transit_gateway_attachment_id
  key         = "Name"
  value       = each.key
}

################################################################################
# Transit gateway VPN logs
################################################################################

resource "aws_cloudwatch_log_group" "transit_gateway_vpn_logs" {
  for_each = { for name, vpn_configuration in var.vpn_connection : name => vpn_configuration if vpn_configuration.enable_logs }

  name              = "${each.value.log_group_name}-${each.key}"
  kms_key_id        = each.value.log_kms_key_arn
  retention_in_days = each.value.retention_in_days
  tags              = var.tags
}

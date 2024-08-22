data "aws_ec2_transit_gateway_dx_gateway_attachment" "default" {
  for_each = { for key, connection in var.vpn_connection : key => connection if connection.outside_ip_address_type == "PrivateIpv4" }

  transit_gateway_id = aws_ec2_transit_gateway.default.id
  dx_gateway_id      = each.value.dx_gateway_id
}

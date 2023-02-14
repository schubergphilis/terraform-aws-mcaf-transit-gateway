output "transit_gateway_id" {
  description = "Transit Gateway and route table ID"
  value       = aws_ec2_transit_gateway.default.id
}

output "transit_gateway_route_table_id" {
  description = "Transit Gateway Route Table identifier"
  value = {
    for rt in aws_ec2_transit_gateway_route_table.default : rt.tags_all["Name"] => rt.id
  }
}

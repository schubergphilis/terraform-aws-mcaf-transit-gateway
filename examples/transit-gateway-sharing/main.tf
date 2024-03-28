module "transit_gateway" {
  source = "../../"

  name        = "transit-gateway"
  description = "eu-west-1 production transit gateway"

  route_tables = ["shared", "vpc", "isolated"]

  transit_gateway_sharing = {
    sharing-1 = {
      principal                     = "222222222222"
      route_table_association       = "vpc"
      route_table_propagation       = ["shared", "vpc"]
      transit_gateway_attachment_id = "tgw-attach-0123456789abcdefg"
    }
  }

  tags = {
    env = "production"
  }
}

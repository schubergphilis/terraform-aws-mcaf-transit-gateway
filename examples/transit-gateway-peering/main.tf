module "transit_gateway" {
  source = "../../"

  name        = "transit-gateway"
  description = "eu-west-1 production transit gateway"

  route_tables = ["shared", "vpc", "isolated"]

  transit_gateway_peering = {
    peering-1 = {
      peer_account_id         = "111111111111",
      peer_region             = "eu-west-1",
      peer_transit_gateway_id = "tgw-0123456789abcdefg"
      route_table_association = "vpc"

      peer_routes = {
        shared = ["10.1.1.0/24", "192.168.10.0/24"]
        test   = ["10.2.2.0/24", "192.168.10.0/24"]
      }
    }
  }

  tags = {
    env = "production"
  }
}

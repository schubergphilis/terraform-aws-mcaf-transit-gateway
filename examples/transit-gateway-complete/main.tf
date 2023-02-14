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

  transit_gateway_sharing = {
    sharing-1 = {
      principal_account_id          = "222222222222"
      route_table_association       = "vpc"
      route_table_propagation       = ["shared", "vpc"]
      transit_gateway_attachment_id = "tgw-attach-0123456789abcdefg"
    }
  }

  vpn_connection = {
    vpn-1 = {
      customer_gateway_bgp_asn    = 64513
      customer_gateway_ip_address = "1.2.3.4"
      route_table_association     = "shared"
      route_table_propagation     = ["shared", "vpc"]
      tunnel1_options             = { inside_cidr = "169.254.10.0/30" }
      tunnel2_options             = { inside_cidr = "169.254.10.4/30" }
    }
  }

  tags = {
    env = "production"
  }
}

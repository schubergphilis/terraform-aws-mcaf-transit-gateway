module "transit_gateway" {
  source = "../../"

  name        = "transit-gateway"
  description = "eu-west-1 production transit gateway"

  route_tables = ["shared", "vpc", "isolated"]

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

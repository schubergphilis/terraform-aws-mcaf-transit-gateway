module "transit_gateway" {
  source = "../../"

  name        = "transit-gateway"
  description = "eu-west-1 production transit gateway"

  route_tables = ["shared", "vpc", "isolated"]

  cloudwatch_flow_logs_configuration = {
    kms_key_arn = module.kms_key.arn
  }

  tags = {
    env = "production"
  }
}

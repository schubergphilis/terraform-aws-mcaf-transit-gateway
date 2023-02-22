# terraform-aws-mcaf-transit-gateway
Terraform module to setup and manage a transit gateway

# Transit Gateway peering
Peering a Transit Gateway is done in two steps, first the peering invite is send to the specified account and transit gateway. Second when the peering invite has been accepted by the other party the peering attachment becomes ready and configuration like the route table association and routing can be done.

## 1) Sending the peering invite
Example sending the invite in the first Terraform run:
```terraform
transit_gateway_peering = {
  peering-1 = {
    peer_account_id         = "111111111111",
    peer_region             = "eu-west-1",
    peer_transit_gateway_id = "tgw-0123456789abcdefg"
    route_table_association = ""
    peer_routes             = {}
  }
}
```

## 2) Configuring the association and routing
Example setting the route table assocation and static routes from in route tables in the second Terraform run after the remote party has accepted the peering request:
```terraform
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
```

# Transit Gateway sharing
Sharing a Transit Gateway is done in two steps, first step is to share the Transit Gateway which makes it available in the remote account. Step two is accepting the attachment, configuring the route table association and propagation after a VPC has been attached to the Transit Gateway in the remote account.

## 1) Sharing the Transit Gateway with the specified account
Example sharing the Transit gateway in the first Terraform run:
```terraform
transit_gateway_sharing = {
  sharing-1 = {
    principal_account_id          = "222222222222"
    route_table_association       = ""
    route_table_propagation       = []
    transit_gateway_attachment_id = ""
  }
}
```

## 2) Configuring the association and propagation of the attached VPC
Example accepting the attachment, setting the route table assocation and propagation for the attached VPC in the remote account in the second Terraform run:
```terraform
transit_gateway_sharing = {
  sharing-1 = {
    principal_account_id          = "222222222222"
    route_table_association       = "vpc"
    route_table_propagation       = ["shared", "vpc"]
    transit_gateway_attachment_id = "tgw-attach-062000946f17af583"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.39.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.9.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_transit_gateway"></a> [transit\_gateway](#module\_transit\_gateway) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->

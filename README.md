# terraform-aws-mcaf-transit-gateway
Terraform module to setup and manage a Transit Gateway, it supports the following features:
 - Peering with another Transit Gateway
 - Sharing the Transit Gateway with other accounts
 - Creation and attachment of VPN connections

Please take note of the information below regarding the usage of the module. Complete code examples can be found in the [examples](/examples/) directory.

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

    blackhole_routes = {
      shared = ["10.3.3.0/24"]
    }
  }
}
```

# Transit Gateway sharing
Sharing a Transit Gateway is done in two steps, first is to share the Transit Gateway which makes it available in the specified account. Second, when the the other party has created the Transit Gateway attachment in the specified account, is accepting the attachment and configuring the route table association and propagation.

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

# Using KMS encryption for the logs
The module supports using a KMS key to encrypt the logfiles created by the Transit Gateway or the VPNs.
Please note that the [example provided](/examples/transit-gateway-complete) uses a [KMS key policy](/examples/transit-gateway-complete/kms.tf) that works out of the box but is not scoped down to least privilege.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.39.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.39.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.transit_gateway_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.transit_gateway_vpn_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_customer_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |
| [aws_ec2_tag.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_transit_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_peering_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_route.peering](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.peering](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.sharing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.sharing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment_accepter.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment_accepter) | resource |
| [aws_flow_log.cloudwatch_transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_flow_log.s3_transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_policy.transit_gateway_cloudwatch_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.transit_gateway_cloudwatch_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.transit_gateway_cloudwatch_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ram_principal_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_vpn_connection.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |
| [time_sleep.ten_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.transit_gateway_cloudwatch_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.transit_gateway_cloudwatch_flow_logs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the EC2 Transit Gateway | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the EC2 Transit Gateway | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to set on Terraform created resources | `map(string)` | n/a | yes |
| <a name="input_cloudwatch_flow_logs_configuration"></a> [cloudwatch\_flow\_logs\_configuration](#input\_cloudwatch\_flow\_logs\_configuration) | Cloudwatch flow logs configuration | <pre>object({<br>    iam_policy_name_prefix   = optional(string, "transit-gateway-flow-logs-to-cloudwatch-")<br>    iam_role_name_prefix     = optional(string, "transit-gateway-flow-logs-role-")<br>    kms_key_arn              = optional(string)<br>    log_group_name           = optional(string, "/platform/transit-gateway-flow-logs")<br>    max_aggregation_interval = optional(number, 60)<br>    retention_in_days        = optional(number, 90)<br>    traffic_type             = optional(string, "ALL")<br>  })</pre> | `{}` | no |
| <a name="input_enable_cloudwatch_flow_logs"></a> [enable\_cloudwatch\_flow\_logs](#input\_enable\_cloudwatch\_flow\_logs) | Set to true to enable Transit Gateway flow logs to be stored in Cloudwatch | `bool` | `true` | no |
| <a name="input_enable_s3_flow_logs"></a> [enable\_s3\_flow\_logs](#input\_enable\_s3\_flow\_logs) | Set to true to enable Transit Gateway flow logs to be stored in S3 | `bool` | `false` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Route Tables to create on the Transit Gateway | `list(any)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_s3_flow_logs_configuration"></a> [s3\_flow\_logs\_configuration](#input\_s3\_flow\_logs\_configuration) | S3 flow logs configuration | <pre>object({<br>    max_aggregation_interval = optional(number, 60)<br>    traffic_type             = optional(string, "ALL")<br>    file_format              = optional(string, "parquet")<br>    per_hour_partition       = optional(bool, true)<br>    log_destination          = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_transit_gateway_asn"></a> [transit\_gateway\_asn](#input\_transit\_gateway\_asn) | BGP ASN used on the Transit Gateway | `number` | `64512` | no |
| <a name="input_transit_gateway_default_route_table_association"></a> [transit\_gateway\_default\_route\_table\_association](#input\_transit\_gateway\_default\_route\_table\_association) | Whether resource attachments are automatically associated with the default association route table | `bool` | `false` | no |
| <a name="input_transit_gateway_default_route_table_propagation"></a> [transit\_gateway\_default\_route\_table\_propagation](#input\_transit\_gateway\_default\_route\_table\_propagation) | Whether resource attachments automatically propagate routes to the default propagation route table | `bool` | `false` | no |
| <a name="input_transit_gateway_peering"></a> [transit\_gateway\_peering](#input\_transit\_gateway\_peering) | Transit Gateway peering configuration | <pre>map(object({<br>    peer_account_id         = string<br>    peer_region             = string<br>    peer_transit_gateway_id = string<br>    route_table_association = string<br>    peer_routes             = map(list(string))<br>    blackhole_routes        = map(optional(list(string)))<br>  }))</pre> | `{}` | no |
| <a name="input_transit_gateway_sharing"></a> [transit\_gateway\_sharing](#input\_transit\_gateway\_sharing) | Transit Gateway sharing configuration | <pre>map(object({<br>    principal_account_id          = string<br>    route_table_association       = string<br>    route_table_propagation       = list(string)<br>    transit_gateway_attachment_id = string<br>  }))</pre> | `{}` | no |
| <a name="input_vpn_connection"></a> [vpn\_connection](#input\_vpn\_connection) | VPN connection configuration | <pre>map(object({<br>    customer_gateway_bgp_asn    = number<br>    customer_gateway_ip_address = string<br>    enable_logs                 = optional(bool, true)<br>    log_kms_key_arn             = optional(string)<br>    log_group_arn               = optional(string)<br>    log_group_name              = optional(string, "/platform/transit-gateway-vpn-logs")<br>    log_output_format           = optional(string, "json")<br>    retention_in_days           = optional(number, 90)<br>    route_table_association     = string<br>    route_table_propagation     = list(string)<br>    tunnel1_options = object({<br>      dpd_timeout_action           = optional(string, "clear")<br>      dpd_timeout_seconds          = optional(number, 30)<br>      ike_versions                 = optional(list(string), ["ikev2"])<br>      inside_cidr                  = string<br>      phase1_dh_group_numbers      = optional(list(number), [21])<br>      phase1_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])<br>      phase1_integrity_algorithms  = optional(list(string), ["SHA2-512"])<br>      phase1_lifetime_seconds      = optional(number, 28800)<br>      phase2_dh_group_numbers      = optional(list(number), [21])<br>      phase2_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])<br>      phase2_integrity_algorithms  = optional(list(string), ["SHA2-512"])<br>      phase2_lifetime_seconds      = optional(number, 3600)<br>      rekey_fuzz_percentage        = optional(number, 100)<br>      rekey_margin_time_seconds    = optional(number, 540)<br>      replay_window_size           = optional(number, 1024)<br>      startup_action               = optional(string, "add")<br>    })<br>    tunnel2_options = object({<br>      dpd_timeout_action           = optional(string, "clear")<br>      dpd_timeout_seconds          = optional(number, 30)<br>      ike_versions                 = optional(list(string), ["ikev2"])<br>      inside_cidr                  = string<br>      phase1_dh_group_numbers      = optional(list(number), [21])<br>      phase1_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])<br>      phase1_integrity_algorithms  = optional(list(string), ["SHA2-512"])<br>      phase1_lifetime_seconds      = optional(number, 28800)<br>      phase2_dh_group_numbers      = optional(list(number), [21])<br>      phase2_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])<br>      phase2_integrity_algorithms  = optional(list(string), ["SHA2-512"])<br>      phase2_lifetime_seconds      = optional(number, 3600)<br>      rekey_fuzz_percentage        = optional(number, 100)<br>      rekey_margin_time_seconds    = optional(number, 540)<br>      replay_window_size           = optional(number, 1024)<br>      startup_action               = optional(string, "add")<br>    })<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | Transit Gateway identifier |
| <a name="output_transit_gateway_route_table_id"></a> [transit\_gateway\_route\_table\_id](#output\_transit\_gateway\_route\_table\_id) | Transit Gateway Route Table and route table ID |
<!-- END_TF_DOCS -->

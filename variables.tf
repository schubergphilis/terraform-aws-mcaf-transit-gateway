variable "cloudwatch_flow_logs_configuration" {
  type = object({
    iam_policy_name_prefix   = optional(string, "transit-gateway-flow-logs-to-cloudwatch-")
    iam_role_name_prefix     = optional(string, "transit-gateway-flow-logs-role-")
    kms_key_arn              = optional(string)
    log_group_name           = optional(string, "/platform/transit-gateway-flow-logs")
    max_aggregation_interval = optional(number, 60)
    retention_in_days        = optional(number, 90)
    traffic_type             = optional(string, "ALL")
  })
  default     = {}
  description = "Cloudwatch flow logs configuration"
}

variable "description" {
  description = "Description of the EC2 Transit Gateway"
  type        = string
}

variable "enable_cloudwatch_flow_logs" {
  description = "Set to true to enable Transit Gateway flow logs to be stored in Cloudwatch"
  type        = bool
  default     = true
}

variable "enable_s3_flow_logs" {
  description = "Set to true to enable Transit Gateway flow logs to be stored in S3"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the EC2 Transit Gateway"
  type        = string
}

variable "route_tables" {
  description = "Route Tables to create on the Transit Gateway"
  type        = list(any)
  default     = ["default"]
}

variable "s3_flow_logs_configuration" {
  type = object({
    max_aggregation_interval = optional(number, 60)
    traffic_type             = optional(string, "ALL")
    file_format              = optional(string, "parquet")
    per_hour_partition       = optional(bool, true)
    log_destination          = optional(string)
  })
  default     = {}
  description = "S3 flow logs configuration"
}

variable "tags" {
  description = "Map of tags to set on Terraform created resources"
  type        = map(string)
}

variable "transit_gateway_asn" {
  description = "BGP ASN used on the Transit Gateway"
  type        = number
  default     = 64512
}

variable "transit_gateway_auto_accept_shared_attachments" {
  type        = bool
  default     = false
  description = "Whether resource attachment requests are automatically accepted"
}

variable "transit_gateway_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "One or more IPv4 or IPv6 CIDR blocks for the transit gateway. Must be a size /24 CIDR block or larger for IPv4, or a size /64 CIDR block or larger for IPv6."
}

variable "transit_gateway_default_route_table_association" {
  type        = bool
  default     = false
  description = "Whether resource attachments are automatically associated with the default association route table"
}

variable "transit_gateway_default_route_table_propagation" {
  type        = bool
  default     = false
  description = "Whether resource attachments automatically propagate routes to the default propagation route table"
}

variable "transit_gateway_peering" {
  type = map(object({
    peer_account_id         = string
    peer_region             = string
    peer_transit_gateway_id = string
    route_table_association = string
    peer_routes             = map(list(string))
  }))
  default     = {}
  description = "Transit Gateway peering configuration"
}

variable "transit_gateway_sharing" {
  type = map(object({
    principal                     = string
    route_table_association       = optional(string, "")
    route_table_propagation       = optional(list(string), [])
    transit_gateway_attachment_id = optional(string, "")
  }))
  default     = {}
  description = "Transit Gateway sharing configuration. Possible principal is an AWS account ID, an AWS Organizations Organization ARN, or an AWS Organizations Organization Unit ARN."
}

variable "vpn_connection" {
  type = map(object({
    customer_gateway_bgp_asn                = number
    customer_gateway_ip_address             = string
    enable_logs                             = optional(bool, true)
    log_group_arn                           = optional(string)
    log_group_name                          = optional(string, "/platform/transit-gateway-vpn-logs")
    log_kms_key_arn                         = optional(string)
    log_output_format                       = optional(string, "json")
    outside_ip_address_type                 = optional(string, "PublicIpv4")
    retention_in_days                       = optional(number, 90)
    route_table_association                 = string
    route_table_propagation                 = list(string)
    transport_transit_gateway_attachment_id = optional(string)
    tunnel1_options = object({
      dpd_timeout_action           = optional(string, "clear")
      dpd_timeout_seconds          = optional(number, 30)
      ike_versions                 = optional(list(string), ["ikev2"])
      inside_cidr                  = string
      phase1_dh_group_numbers      = optional(list(number), [21])
      phase1_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])
      phase1_integrity_algorithms  = optional(list(string), ["SHA2-512"])
      phase1_lifetime_seconds      = optional(number, 28800)
      phase2_dh_group_numbers      = optional(list(number), [21])
      phase2_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])
      phase2_integrity_algorithms  = optional(list(string), ["SHA2-512"])
      phase2_lifetime_seconds      = optional(number, 3600)
      rekey_fuzz_percentage        = optional(number, 100)
      rekey_margin_time_seconds    = optional(number, 540)
      replay_window_size           = optional(number, 1024)
      startup_action               = optional(string, "add")
    })
    tunnel2_options = object({
      dpd_timeout_action           = optional(string, "clear")
      dpd_timeout_seconds          = optional(number, 30)
      ike_versions                 = optional(list(string), ["ikev2"])
      inside_cidr                  = string
      phase1_dh_group_numbers      = optional(list(number), [21])
      phase1_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])
      phase1_integrity_algorithms  = optional(list(string), ["SHA2-512"])
      phase1_lifetime_seconds      = optional(number, 28800)
      phase2_dh_group_numbers      = optional(list(number), [21])
      phase2_encryption_algorithms = optional(list(string), ["AES256-GCM-16"])
      phase2_integrity_algorithms  = optional(list(string), ["SHA2-512"])
      phase2_lifetime_seconds      = optional(number, 3600)
      rekey_fuzz_percentage        = optional(number, 100)
      rekey_margin_time_seconds    = optional(number, 540)
      replay_window_size           = optional(number, 1024)
      startup_action               = optional(string, "add")
    })
  }))
  default     = {}
  description = "VPN connection configuration"


  validation {
    condition     = alltrue([for key, connection in var.vpn_connection : connection.outside_ip_address_type == "PrivateIpv4" ? connection.transport_transit_gateway_attachment_id != null : true])
    error_message = "If outside_ip_address_type is PrivateIpv4, transport_transit_gateway_attachment_id can not be null"
  }
}

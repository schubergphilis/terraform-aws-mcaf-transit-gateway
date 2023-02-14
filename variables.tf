variable "name" {
  type        = string
  description = "Name of the EC2 Transit Gateway"
}

variable "description" {
  type        = string
  description = "Description of the EC2 Transit Gateway"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to set on Terraform created resources"
}

variable "transit_gateway_asn" {
  type        = number
  default     = 64512
  description = "BGP ASN used on the Transit Gateway"
}

variable "transit_gateway_default_route_table_association" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments are automatically associated with the default association route table"
}

variable "transit_gateway_default_route_table_propagation" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table"
}

variable "enable_cloudwatch_flow_logs" {
  type        = bool
  default     = true
  description = "Set to true to enable Transit Gateway flow logs to be stored in Cloudwatch"
}

variable "enable_s3_flow_logs" {
  type        = bool
  default     = false
  description = "Set to true to enable Transit Gateway flow logs to be stored in S3"
}

variable "cloudwatch_flow_logs_configuration" {
  type = object({
    kms_key_arn              = optional(string)
    log_group_name           = optional(string, "/platform/transit-gateway-flow-logs")
    max_aggregation_interval = optional(number, 60)
    retention_in_days        = optional(number, 90)
    traffic_type             = optional(string, "ALL")
  })
  default     = {}
  description = "Cloudwatch flow logs configuration"
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

variable "route_tables" {
  type        = list(any)
  default     = ["default"]
  description = "Route Tables to create on the Transit Gateway"
}

variable "transit_gateway_sharing" {
  type = map(object({
    principal_account_id          = string
    route_table_association       = string
    route_table_propagation       = list(string)
    transit_gateway_attachment_id = string
  }))
  default     = {}
  description = "Transit Gateway sharing configuration"
}

variable "vpn_connection" {
  type = map(object({
    customer_gateway_bgp_asn    = number
    customer_gateway_ip_address = string
    enable_logs                 = optional(bool, true)
    log_kms_key_arn             = optional(string)
    log_group_arn               = optional(string)
    log_group_name              = optional(string, "/platform/transit-gateway-vpn-logs")
    log_output_format           = optional(string, "json")
    retention_in_days           = optional(number, 90)
    route_table_association     = string
    route_table_propagation     = list(string)
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
}

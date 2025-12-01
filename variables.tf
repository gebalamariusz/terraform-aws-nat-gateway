# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name prefix for all resources"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Name cannot be empty."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs where NAT Gateways will be created. These should be subnets with route to Internet Gateway."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID is required."
  }

  validation {
    condition = alltrue([
      for id in var.subnet_ids : can(regex("^subnet-", id))
    ])
    error_message = "All subnet IDs must start with 'subnet-'."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (used in naming/tagging if provided)"
  type        = string
  default     = ""
}

variable "single_nat_gateway" {
  description = "If true, creates only one NAT Gateway in the first subnet (cost savings for non-prod). If false, creates one NAT Gateway per subnet (HA for prod)."
  type        = bool
  default     = false
}

variable "reuse_eips" {
  description = "List of existing Elastic IP allocation IDs to reuse. Must match the number of NAT Gateways to be created."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.reuse_eips : can(regex("^eipalloc-", id))
    ])
    error_message = "All EIP allocation IDs must start with 'eipalloc-'."
  }
}

variable "private_route_table_ids" {
  description = "List of private route table IDs that need routes to NAT Gateway. If single_nat_gateway is true, all route tables will point to the same NAT. If false, routes are distributed across NAT Gateways (round-robin by AZ)."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.private_route_table_ids : can(regex("^rtb-", id))
    ])
    error_message = "All route table IDs must start with 'rtb-'."
  }
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

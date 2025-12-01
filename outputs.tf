# ------------------------------------------------------------------------------
# NAT GATEWAY OUTPUTS
# ------------------------------------------------------------------------------

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IP addresses associated with NAT Gateways"
  value       = aws_nat_gateway.this[*].public_ip
}

output "nat_gateway_private_ips" {
  description = "List of private IP addresses associated with NAT Gateways"
  value       = aws_nat_gateway.this[*].private_ip
}

# ------------------------------------------------------------------------------
# ELASTIC IP OUTPUTS
# ------------------------------------------------------------------------------

output "eip_ids" {
  description = "List of Elastic IP allocation IDs (empty if reusing existing EIPs)"
  value       = aws_eip.this[*].id
}

output "eip_public_ips" {
  description = "List of Elastic IP public addresses (empty if reusing existing EIPs)"
  value       = aws_eip.this[*].public_ip
}

# ------------------------------------------------------------------------------
# CONVENIENCE OUTPUTS
# ------------------------------------------------------------------------------

output "nat_gateway_count" {
  description = "Number of NAT Gateways created"
  value       = local.nat_gateway_count
}

output "is_single_nat" {
  description = "Whether a single NAT Gateway is used (true) or one per AZ (false)"
  value       = var.single_nat_gateway
}

# ------------------------------------------------------------------------------
# ROUTE OUTPUTS
# ------------------------------------------------------------------------------

output "route_ids" {
  description = "List of route IDs created for private route tables"
  value       = aws_route.nat[*].id
}

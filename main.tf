# ------------------------------------------------------------------------------
# LOCAL VALUES
# ------------------------------------------------------------------------------

locals {
  # Build resource name prefix
  name_prefix = var.environment != "" ? "${var.name}-${var.environment}" : var.name

  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "terraform"
      Module    = "terraform-aws-nat-gateway"
    }
  )

  # Determine how many NAT Gateways to create
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.public_subnet_ids)

  # Subnet IDs for NAT Gateways (first one if single, all if HA)
  nat_subnet_ids = var.single_nat_gateway ? [var.public_subnet_ids[0]] : var.public_subnet_ids

  # Whether to create new EIPs or reuse existing ones
  create_eips = length(var.reuse_eips) == 0
}

# ------------------------------------------------------------------------------
# ELASTIC IPs
# ------------------------------------------------------------------------------

resource "aws_eip" "this" {
  count = local.create_eips ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = local.nat_gateway_count > 1 ? "${local.name_prefix}-nat-${count.index + 1}" : "${local.name_prefix}-nat"
    }
  )
}

# ------------------------------------------------------------------------------
# NAT GATEWAYS
# ------------------------------------------------------------------------------

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = local.create_eips ? aws_eip.this[count.index].id : var.reuse_eips[count.index]
  subnet_id     = local.nat_subnet_ids[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = local.nat_gateway_count > 1 ? "${local.name_prefix}-nat-${count.index + 1}" : "${local.name_prefix}-nat"
    }
  )

  depends_on = [aws_eip.this]
}

# ------------------------------------------------------------------------------
# ROUTES (0.0.0.0/0 -> NAT Gateway for private subnets)
# ------------------------------------------------------------------------------

resource "aws_route" "private_nat" {
  count = length(var.private_route_table_ids)

  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"

  # If single NAT, all routes point to it. If HA, distribute routes across NAT Gateways.
  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index % local.nat_gateway_count].id
}

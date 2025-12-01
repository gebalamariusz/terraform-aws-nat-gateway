# terraform-aws-nat-gateway

Terraform module to create NAT Gateways with Elastic IPs.

This module is designed to work seamlessly with [terraform-aws-vpc](https://github.com/gebalamariusz/terraform-aws-vpc) and [terraform-aws-subnets](https://github.com/gebalamariusz/terraform-aws-subnets) modules.

## Architecture

```
terraform-aws-vpc          -> VPC, IGW
        |
terraform-aws-subnets      -> Subnets, Route Tables, IGW routes (public)
        |
terraform-aws-nat-gateway  -> NAT, EIP  <-- This module
        |
terraform-aws-routes       -> Routes (0.0.0.0/0 -> NAT, TGW, VPC Peering, VPN, etc.)
```

## Features

- Creates NAT Gateways with Elastic IPs
- Supports single NAT Gateway (cost savings) or one per AZ (high availability)
- Option to reuse existing Elastic IPs
- Consistent naming and tagging conventions

## Usage

### Basic usage with terraform-aws-subnets

```hcl
module "vpc" {
  source  = "gebalamariusz/vpc/aws"
  version = "~> 1.0"

  name        = "my-app"
  environment = "prod"
  cidr_block  = "10.0.0.0/16"
}

module "subnets" {
  source  = "gebalamariusz/subnets/aws"
  version = "~> 1.0"

  name   = "my-app"
  vpc_id = module.vpc.vpc_id

  subnets = {
    "10.0.1.0/24" = { az = "eu-west-1a", tier = "public",  public = true }
    "10.0.2.0/24" = { az = "eu-west-1b", tier = "public",  public = true }
    "10.0.3.0/24" = { az = "eu-west-1a", tier = "private", public = false }
    "10.0.4.0/24" = { az = "eu-west-1b", tier = "private", public = false }
  }
}

module "nat_gateway" {
  source  = "gebalamariusz/nat-gateway/aws"
  version = "~> 1.0"

  name        = "my-app"
  environment = "prod"

  subnet_ids         = module.subnets.subnet_ids_by_tier["public"]
  single_nat_gateway = false  # One NAT per AZ for HA
}

# Routes are added via terraform-aws-routes module (or manually)
```

### Single NAT Gateway (cost savings for non-prod)

```hcl
module "nat_gateway" {
  source  = "gebalamariusz/nat-gateway/aws"
  version = "~> 1.0"

  name        = "my-app"
  environment = "dev"

  subnet_ids         = module.subnets.subnet_ids_by_tier["public"]
  single_nat_gateway = true  # Save ~$32/month per NAT
}
```

### Reuse existing Elastic IPs

```hcl
module "nat_gateway" {
  source  = "gebalamariusz/nat-gateway/aws"
  version = "~> 1.0"

  name        = "my-app"
  environment = "prod"

  subnet_ids         = module.subnets.subnet_ids_by_tier["public"]
  single_nat_gateway = false
  reuse_eips         = ["eipalloc-abc123", "eipalloc-def456"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | n/a | yes |
| subnet_ids | List of subnet IDs where NAT Gateways will be created (must have route to IGW) | `list(string)` | n/a | yes |
| environment | Environment name (used in naming/tagging if provided) | `string` | `""` | no |
| single_nat_gateway | If true, creates only one NAT Gateway (cost savings). If false, creates one per subnet (HA). | `bool` | `false` | no |
| reuse_eips | List of existing Elastic IP allocation IDs to reuse | `list(string)` | `[]` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_gateway_public_ips | List of public IP addresses associated with NAT Gateways |
| nat_gateway_private_ips | List of private IP addresses associated with NAT Gateways |
| eip_ids | List of Elastic IP allocation IDs (empty if reusing existing EIPs) |
| eip_public_ips | List of Elastic IP public addresses (empty if reusing existing EIPs) |
| nat_gateway_count | Number of NAT Gateways created |
| is_single_nat | Whether a single NAT Gateway is used |

## Cost Considerations

NAT Gateway pricing (eu-west-1):
- $0.045/hour per NAT Gateway (~$32/month)
- $0.045/GB data processed

For non-production environments, use `single_nat_gateway = true` to save costs.

## License

MIT

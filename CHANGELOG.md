# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-28

### Added

- Initial release of AWS NAT Gateway Terraform module
- NAT Gateway creation with Elastic IPs
- Single NAT Gateway mode for cost savings (non-prod)
- High availability mode with one NAT per AZ (prod)
- Option to reuse existing Elastic IPs
- Consistent naming with name prefix and environment
- Consistent tagging with `ManagedBy`, `Module`, and optional `Environment` tags
- Comprehensive outputs including NAT Gateway IDs, public/private IPs, EIP IDs
- CI pipeline with terraform fmt, validate, tflint, and tfsec
- MIT License

[1.0.0]: https://github.com/gebalamariusz/terraform-aws-nat-gateway/releases/tag/v1.0.0

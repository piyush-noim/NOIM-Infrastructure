# NOIM Infrastructure

Infrastructure-as-code and operational automation for the NOIM platform.

## Repository layout

- `environments/` contains isolated root configurations for development, staging, and production.
- `modules/` contains reusable Terraform modules shared by environment configurations.
- `contracts/` contains versioned, provider-neutral NOIM core contracts.
- `scripts/` contains operational and deployment helper scripts.
- `docs/` contains infrastructure architecture and runbook documentation.
- `tests/` contains infrastructure validation and integration tests.
- `.github/workflows/` contains continuous-integration workflows.

## Getting started

1. Copy the relevant environment's `terraform.tfvars.example` file to `terraform.tfvars`.
2. Supply provider credentials through your environment or approved secret manager.
3. Run `make validate ENV=development` before planning. Run `make validate-all` to validate every environment without accessing a remote state backend.
4. Run `make init ENV=development`, then `make plan ENV=development`.
5. Review the generated plan before running `make apply ENV=development`.

Terraform state and environment-specific secrets must never be committed to this repository.

## Validation

`scripts/validate-terraform.sh` is the repository's portable validation boundary. It runs a recursive format check and initializes Terraform with `-backend=false` before validating configuration. It accepts `--environment <development|staging|production>` to validate one isolated root configuration; without an argument, it validates all supported environments.

This validation never provisions, changes, or destroys infrastructure and does not require provider credentials while the roots remain provider-independent. It is a configuration check, not a substitute for an approved plan review, policy evaluation, or deployment authorization. See [Terraform validation](docs/terraform-validation.md) for the interface, extension guidance, and safety considerations.

## NOIM core contracts

Versioned JSON Schema contracts establish the portable boundaries for identity, policy evaluation, resources, reusable block metadata, audit events, and configuration. They contain no credentials, providers, runtime implementation, or policy bypass. See [NOIM core contracts](docs/core-contracts.md) for usage and extension rules.

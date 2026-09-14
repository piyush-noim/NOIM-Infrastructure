# NOIM Infrastructure

Infrastructure-as-code and operational automation for the NOIM platform.

## Repository layout

- `environments/` contains isolated root configurations for development, staging, and production.
- `modules/` contains reusable Terraform modules shared by environment configurations.
- `scripts/` contains operational and deployment helper scripts.
- `docs/` contains infrastructure architecture and runbook documentation.
- `tests/` contains infrastructure validation and integration tests.
- `.github/workflows/` contains continuous-integration workflows.

## Getting started

1. Copy the relevant environment's `terraform.tfvars.example` file to `terraform.tfvars`.
2. Supply provider credentials through your environment or approved secret manager.
3. Run `make init ENV=development`, then `make plan ENV=development`.
4. Review the generated plan before running `make apply ENV=development`.

Terraform state and environment-specific secrets must never be committed to this repository.

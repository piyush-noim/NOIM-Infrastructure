# Terraform validation

## Purpose

`scripts/validate-terraform.sh` provides a single, local-first validation contract for every NOIM infrastructure environment. It checks Terraform formatting and validates root configuration without initializing a remote backend or applying infrastructure changes.

## Interface

```sh
./scripts/validate-terraform.sh
./scripts/validate-terraform.sh --environment development
make validate ENV=staging
make validate-all
make test
```

Supported environment names are `development`, `staging`, and `production`. The script exits non-zero for an unknown environment, malformed command line, missing Terraform binary, formatting error, initialization failure, or invalid configuration.

## How it works

For each selected environment the script runs:

1. `terraform fmt -check -recursive` from the repository root.
2. `terraform init -backend=false -input=false` in that environment root.
3. `terraform validate` in that environment root.

The accompanying shell contract test uses a fake `terraform` executable to verify the commands and scope of a single-environment invocation. This keeps the test runnable even where Terraform is not installed.

## Extension points

Add an environment by creating its isolated root under `environments/`, then add its name to the `environments` list in `scripts/validate-terraform.sh` and to the CI matrix. Reusable provider-specific infrastructure belongs behind modules in `modules/`; roots should compose those modules rather than duplicate resource definitions.

When a root starts using providers or modules that need downloaded dependencies, validation still remains non-destructive, but its initialization requirements may change. Update this document and CI configuration together when that happens.

## Security and deployment boundary

Validation deliberately disables remote backends, accepts no credentials, and never invokes `plan`, `apply`, or `destroy`. It is not deployment authorization and must not be used to bypass policy, approval, audit, or change-control requirements. Approved credentials and remote state access are only appropriate for explicit, reviewed operational commands.

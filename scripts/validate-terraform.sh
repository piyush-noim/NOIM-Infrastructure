#!/usr/bin/env bash
# Validate NOIM Terraform roots without initializing a remote state backend.
set -euo pipefail

readonly repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly environments=(development staging production)

usage() {
  cat <<'EOF'
Usage: validate-terraform.sh [--environment NAME]

Validates NOIM Terraform configuration. Without --environment, validates every
supported environment: development, staging, and production.
EOF
}

validate_environment() {
  local environment="$1"
  local environment_directory="${repository_root}/environments/${environment}"

  case " ${environments[*]} " in
    *" ${environment} "*) ;;
    *)
      printf 'Unsupported environment: %s\n' "${environment}" >&2
      return 1
      ;;
  esac

  if [[ ! -d "${environment_directory}" ]]; then
    printf 'Unknown or missing environment: %s\n' "${environment}" >&2
    return 1
  fi

  printf 'Validating Terraform environment: %s\n' "${environment}"
  terraform -chdir="${environment_directory}" init -backend=false -input=false
  terraform -chdir="${environment_directory}" validate
}

selected_environment=""
while (($# > 0)); do
  case "$1" in
    --environment)
      if (($# < 2)); then
        printf '%s\n' '--environment requires a value.' >&2
        usage >&2
        exit 2
      fi
      selected_environment="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v terraform >/dev/null 2>&1; then
  printf '%s\n' 'Terraform is required but was not found on PATH.' >&2
  exit 127
fi

cd "${repository_root}"
terraform fmt -check -recursive

if [[ -n "${selected_environment}" ]]; then
  validate_environment "${selected_environment}"
else
  for environment in "${environments[@]}"; do
    validate_environment "${environment}"
  done
fi

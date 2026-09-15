#!/usr/bin/env bash
# Contract tests for scripts/validate-terraform.sh. No Terraform binary required.
set -euo pipefail

readonly repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly temporary_directory="$(mktemp -d)"
trap 'rm -rf "${temporary_directory}"' EXIT

cat >"${temporary_directory}/terraform" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${TERRAFORM_CALL_LOG}"
EOF
chmod +x "${temporary_directory}/terraform"

assert_contains() {
  local expected="$1"
  local file="$2"
  if ! rg --fixed-strings --quiet -- "$expected" "$file"; then
    printf 'Expected command was not run: %s\n' "$expected" >&2
    cat "$file" >&2
    exit 1
  fi
}

call_log="${temporary_directory}/terraform-calls.log"
PATH="${temporary_directory}:${PATH}" TERRAFORM_CALL_LOG="${call_log}" \
  "${repository_root}/scripts/validate-terraform.sh" --environment development

assert_contains 'fmt -check -recursive' "${call_log}"
assert_contains "-chdir=${repository_root}/environments/development init -backend=false -input=false" "${call_log}"
assert_contains "-chdir=${repository_root}/environments/development validate" "${call_log}"

if rg --fixed-strings --quiet -- '/staging ' "${call_log}"; then
  printf '%s\n' 'A single-environment validation must not validate staging.' >&2
  exit 1
fi

: >"${call_log}"
PATH="${temporary_directory}:${PATH}" TERRAFORM_CALL_LOG="${call_log}" \
  "${repository_root}/scripts/validate-terraform.sh"
for environment in development staging production; do
  assert_contains "-chdir=${repository_root}/environments/${environment} validate" "${call_log}"
done

if PATH="${temporary_directory}:${PATH}" TERRAFORM_CALL_LOG="${call_log}" \
  "${repository_root}/scripts/validate-terraform.sh" --environment preview >/dev/null 2>&1; then
  printf '%s\n' 'An unsupported environment must fail validation.' >&2
  exit 1
fi

printf '%s\n' 'validate-terraform script contract tests passed.'

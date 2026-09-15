ENV ?= development
TF_DIR := environments/$(ENV)

.PHONY: fmt test validate validate-all init plan apply destroy

fmt:
	terraform fmt -recursive

validate:
	./scripts/validate-terraform.sh --environment $(ENV)

validate-all:
	./scripts/validate-terraform.sh

test:
	./tests/validate-terraform.sh
	PYTHONDONTWRITEBYTECODE=1 python3 ./tests/core-contracts.py

init:
	terraform -chdir=$(TF_DIR) init

plan:
	terraform -chdir=$(TF_DIR) plan

apply:
	terraform -chdir=$(TF_DIR) apply

destroy:
	terraform -chdir=$(TF_DIR) destroy

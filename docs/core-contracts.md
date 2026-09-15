# NOIM core contracts (v1)

## Purpose

The files in `contracts/v1/` are the small, machine-readable foundation for NOIM components. They are JSON Schema documents rather than a runtime framework, so a visual Explorer, Builder, Engineer tool, local process, cloud adapter, or AI agent can use the same contracts without being coupled to a language or provider.

## Contracts

| Contract | Represents | Boundary it establishes |
| --- | --- | --- |
| `identity-principal` | A human, developer, service, or AI-agent requester. | Identity description only; it is not authentication or authorization. |
| `policy-evaluation` | A request and explicit `allow`, `deny`, or `requires-approval` decision. | An operation must receive and satisfy a policy decision before execution. |
| `resource-descriptor` | A compute, storage, network, or service resource and its placement. | Uses `local`, `lan`, `noim-node`, `cloud`, and `edge` without binding to a vendor. |
| `block-metadata` | The identity, version, description, ports, and declared capabilities of a reusable block. | Supplies metadata a registry and visual Builder can display; it does not execute a block. |
| `audit-event` | A structured record of an operation and its outcome. | Allows future audit adapters to record events; it is not an audit store or immutable ledger. |
| `configuration` | Non-secret values plus references to an approved secret provider. | A reference is not secret material; plaintext secrets do not belong in this contract or Git. |

## Usage

Consumers should pin the major contract directory (`contracts/v1`) and validate payloads before use. `tests/core-contracts.py` validates representative valid and invalid fixtures without network access, credentials, or a cloud provider.

A future component should compose the contracts in this order: identify the principal, evaluate policy for the requested operation, execute only an allowed operation after obligations and approvals are satisfied, and emit an audit event. `requires-approval` is not permission to execute.

## Security and extension rules

These schemas deliberately provide no privileged actor, implicit allow, secret value field, provider credential field, or emergency bypass. Authentication, authorization, approval verification, durable audit storage, secret resolution, and provider adapters remain separate implementations that must preserve these boundaries.

Additive optional fields may be introduced in a later compatible version after documenting their visual meaning and policy/audit impact. Breaking changes require a new major contract directory. Do not embed provider credentials, personal data, or executable policy logic in contract examples.

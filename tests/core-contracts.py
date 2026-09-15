#!/usr/bin/env python3
"""Dependency-free contract tests for the versioned NOIM JSON Schemas."""
import datetime
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACTS = ROOT / "contracts" / "v1"
FIXTURES = json.loads((ROOT / "tests" / "fixtures" / "core-contracts" / "valid.json").read_text())
INVALID_FIXTURES = json.loads((ROOT / "tests" / "fixtures" / "core-contracts" / "invalid.json").read_text())


def matches_type(value, expected):
    expected_types = expected if isinstance(expected, list) else [expected]
    return any(
        (kind == "object" and isinstance(value, dict))
        or (kind == "array" and isinstance(value, list))
        or (kind == "string" and isinstance(value, str))
        or (kind == "number" and isinstance(value, (int, float)) and not isinstance(value, bool))
        or (kind == "boolean" and isinstance(value, bool))
        for kind in expected_types
    )


def validate(value, schema, path="$"):
    if "type" in schema and not matches_type(value, schema["type"]):
        raise ValueError(f"{path} has an invalid type")
    if "enum" in schema and value not in schema["enum"]:
        raise ValueError(f"{path} is not an allowed value")
    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            raise ValueError(f"{path} is too short")
        if "pattern" in schema and re.fullmatch(schema["pattern"], value) is None:
            raise ValueError(f"{path} does not match its required pattern")
        if schema.get("format") == "date-time":
            try:
                datetime.datetime.fromisoformat(value.replace("Z", "+00:00"))
            except ValueError as error:
                raise ValueError(f"{path} is not a date-time") from error
    if isinstance(value, list):
        if schema.get("uniqueItems") and len({json.dumps(item, sort_keys=True) for item in value}) != len(value):
            raise ValueError(f"{path} has duplicate items")
        for index, item in enumerate(value):
            validate(item, schema.get("items", {}), f"{path}[{index}]")
    if isinstance(value, dict):
        properties = schema.get("properties", {})
        for name in schema.get("required", []):
            if name not in value:
                raise ValueError(f"{path}.{name} is required")
        if schema.get("additionalProperties") is False:
            unexpected = set(value) - set(properties)
            if unexpected:
                raise ValueError(f"{path} contains unexpected properties: {sorted(unexpected)}")
        for name, item in value.items():
            if name in properties:
                validate(item, properties[name], f"{path}.{name}")
            elif isinstance(schema.get("additionalProperties"), dict):
                validate(item, schema["additionalProperties"], f"{path}.{name}")


schemas = {}
for schema_path in sorted(CONTRACTS.glob("*.schema.json")):
    schema = json.loads(schema_path.read_text())
    assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
    assert schema["$id"].startswith("https://noim.dev/contracts/v1/")
    schemas[schema_path.stem.removesuffix(".schema")] = schema

assert set(schemas) == set(FIXTURES) == set(INVALID_FIXTURES)
for name, schema in schemas.items():
    validate(FIXTURES[name], schema)
    try:
        validate(INVALID_FIXTURES[name], schema)
    except ValueError:
        continue
    raise AssertionError(f"Invalid {name} fixture unexpectedly passed validation")

# The configuration contract may carry a reference, but never a secret value field.
assert "secret" not in schemas["configuration"]["properties"]
# A policy result must make an explicit decision; there is no implicit allow path.
assert "decision" in schemas["policy-evaluation"]["required"]
print("NOIM core contract tests passed.")

#!/usr/bin/env python3
"""Fail closed when a native-app replica completion manifest is incomplete."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ALLOWED_CLAIMS = {"complete-reference", "bounded-slice"}
ALLOWED_KINDS = {"visual", "behavior", "both"}
ALLOWED_STATUSES = {"pass", "fail", "untested", "unresolved", "inferred"}


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def nonempty_list(value: object) -> bool:
    return isinstance(value, list) and bool(value) and all(isinstance(item, str) and item.strip() for item in value)


def validate(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        manifest = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as error:
        return [f"cannot read valid JSON: {error}"]
    require(manifest.get("schema_version") == 1, "schema_version must equal 1", errors)
    require(manifest.get("claim") in ALLOWED_CLAIMS, "invalid claim", errors)
    require(isinstance(manifest.get("scope_statement"), str) and manifest["scope_statement"].strip(), "scope_statement is required", errors)
    require(manifest.get("inventory_complete") is True, "reference inventory is not complete", errors)
    require(manifest.get("primary_workflow_passed") is True, "primary workflow has not passed", errors)
    require(manifest.get("installed_artifact_verified") is True, "installed artifact is not verified", errors)
    independent = manifest.get("independent_verification")
    require(isinstance(independent, dict), "independent_verification object is required", errors)
    if isinstance(independent, dict):
        require(independent.get("required") is True, "independent verification must be required", errors)
        require(independent.get("passed") is True, "independent verification has not passed", errors)
        require(isinstance(independent.get("verifier"), str) and independent["verifier"].strip(), "independent verifier identity is required", errors)
    rows = manifest.get("rows")
    require(isinstance(rows, list) and bool(rows), "at least one ledger row is required", errors)
    if not isinstance(rows, list):
        return errors
    seen: set[str] = set()
    for index, row in enumerate(rows):
        label = f"rows[{index}]"
        if not isinstance(row, dict):
            errors.append(f"{label} must be an object")
            continue
        row_id = row.get("id")
        require(isinstance(row_id, str) and row_id.strip(), f"{label}.id is required", errors)
        if isinstance(row_id, str):
            require(row_id not in seen, f"duplicate row id: {row_id}", errors)
            seen.add(row_id)
            label = row_id
        kind = row.get("kind")
        status = row.get("status")
        require(kind in ALLOWED_KINDS, f"{label}: invalid kind", errors)
        require(status in ALLOWED_STATUSES, f"{label}: invalid status", errors)
        if row.get("in_scope") is True:
            require(status == "pass", f"{label}: in-scope status is {status!r}, not 'pass'", errors)
            require(row.get("exercised") is True, f"{label}: was not directly exercised", errors)
            evidence = row.get("evidence")
            require(isinstance(evidence, dict), f"{label}: evidence object is required", errors)
            if isinstance(evidence, dict):
                require(nonempty_list(evidence.get("reference")), f"{label}: reference evidence is required", errors)
                require(nonempty_list(evidence.get("candidate")), f"{label}: candidate evidence is required", errors)
                if kind in {"visual", "both"}:
                    require(nonempty_list(evidence.get("comparison")), f"{label}: comparison evidence is required", errors)
                if kind in {"behavior", "both"}:
                    require(nonempty_list(evidence.get("behavior")), f"{label}: behavior evidence is required", errors)
        elif row.get("in_scope") is False:
            require(row.get("exclusion_approved") is True, f"{label}: exclusion lacks explicit approval", errors)
            require(isinstance(row.get("approval"), str) and row["approval"].strip(), f"{label}: exclusion approval record is required", errors)
        else:
            errors.append(f"{label}: in_scope must be true or false")
    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_completion_manifest.py <completion-manifest.json>", file=sys.stderr)
        return 2
    errors = validate(Path(sys.argv[1]))
    if errors:
        print(f"RED: {len(errors)} completion gate failure(s)", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("GREEN: completion manifest satisfies the clone finish line")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

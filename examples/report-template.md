# Types And Constants Audit Template

Use this template when writing a read-only audit report.

## Scope

- Target:
- Shape:
- Mode: read-only
- Command:

```bash
scripts/scan-types-constants.sh <target>
```

## Scanner Signals Used

- Candidate owner files:
- Repeated names:
- Repeated literal unions:
- Existing owner constants or unions:
- Ignored noisy areas:

## Findings

1. Finding type: `SymbolOrLiteral`
   Severity: high | medium | low
   Confidence: high | medium | low

   Current:
   - `path/file.ts:line`
   - `path/other.ts:line`

   Evidence missing:
   Only include this field if exact paths or usage proof are missing. If this field is needed, downgrade the item to a lead.

   Recommendation:
   Name the exact move, deletion, import change, or non-move.

   Reason:
   Explain the ownership or drift risk.

   Next action:
   Name the smallest follow-up edit or inspection step.

## Ignored Leads

- Lead ignored: reason.
- Lead ignored: reason.

## Summary

Short count of findings, safest first edit, and checks to run if edits are requested.

No files were modified during this audit.

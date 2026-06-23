# Naming Drift Audit

Use this module when the same domain idea may be named differently across owners, for example `status`, `state`, `phase`, `mode`, `kind`, `type`, `variant`, or `step`.

## Tool

```bash
scripts/scan-naming-drift.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- convention words in source
- type names using `Status`, `State`, `Phase`, `Mode`, `Kind`, `Type`, `Variant`, or `Step`
- object fields with those words
- function names with those words
- literal unions tied to those names
- same literal set with different names
- same type prefix with different convention words

## Judgment

Strong signals:

- the same literal union is named `Status` in one owner and `Phase` or `State` in another
- a route, store, and UI all refer to the same lifecycle with different naming words
- a type name changes while the values, owner, and usage stay the same
- filters, selectors, API params, and UI labels use different names for one domain concept
- a package exports one name while apps wrap it with another name

Weak signals:

- separate lifecycles that share values such as `pending`, `active`, or `archived`
- framework names such as route `type`, HTML input `type`, or component variant props
- UI-only variants that are not domain state
- generated API names that should match an external schema
- migration aliases kept temporarily for compatibility

## Follow-Up

Before reporting a task:

```bash
rg "Status|State|Phase|Mode|Kind|Type|Variant|Step" <target>
rg "status|state|phase|mode|kind|type|variant|step" <target>
```

Good tasks name one vocabulary decision. Do not rename a concept only because the words differ; rename it when the owner, values, and consumers prove it is the same concept.

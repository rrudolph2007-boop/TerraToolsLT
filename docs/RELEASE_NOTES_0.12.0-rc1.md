# TerraTools LT 0.12.0-rc1

TerraTools LT 0.12.0-rc1 is the first productized release-candidate package for external testing.

## What it is

TerraTools LT is an independent landscape architecture productivity toolkit for AutoCAD LT 2024+ on Windows. It uses ordinary DWG entities, lightweight TERRATOOLS XData identities, external project records, AutoLISP, and DCL.

This release is intentionally positioned as an **AutoCAD LT-first toolkit**, not as a claim of full Land F/X feature parity.

## Highlights

- project creation, persistence, backup, recovery, packaging, and verification
- project-scoped Work Areas
- Project Plants with variants, favorites, recent plants, labels, schedules, costs, path/array/fill/density workflows
- optional WFO June 2026 plant database with 435,702 accepted taxa and 999,746 linked aliases
- reference notes, callouts, site measurements, and concept boundaries
- project detail records, callouts, renumbering, and indexes
- lighting fixtures, transformers, circuits, loads, voltage-drop helper, schedules, and verification
- irrigation equipment, stations/controllers, directed pipe networks, downstream flow, Hazen-Williams sizing, pressure analysis, coverage, drip demand, and schedules
- QA, diagnostics, duplicate-identity reconciliation, and source-independent project copies
- redesigned native DCL home, plant manager, and shared record managers

## Release assets

- `TerraTools-LT-0.12.0-rc1.zip` — application/runtime package
- `terratools-wfo-2026-06.zip` — optional CC0 WFO plant database
- `SHA256SUMS.txt` — SHA-256 hashes for release ZIPs

## Install

See `INSTALL.md` in the runtime package.

## Important release-candidate limits

This is not 1.0. Remaining partial/missing items are documented in `PARITY_MATRIX.md` and the actual acceptance evidence is documented in `RELEASE_CHECKLIST.md`.

Notably:

- full visible-GUI acceptance across every target LT version/theme/DPI combination is not complete
- manufacturer-certified irrigation catalogs are not bundled
- source-DWG detail artwork insertion is partial
- symbol previews/library UX are incomplete
- cloud multi-user synchronization is not provided
- some office-standard/presentation conveniences remain partial or deferred

## Data note

The optional WFO database is taxonomy data, not horticultural or design-specification guidance. It does not establish hardiness, mature size, water use, sun requirements, toxicity, native range, code suitability, or project fitness.

## License

TerraTools LT software is MIT licensed. The optional WFO dataset is separately CC0-1.0 with source/provenance recorded in the package and repository.

## Independence

TerraTools LT is independent software and is not affiliated with, endorsed by, or derived from proprietary Land F/X code, databases, symbols, screenshots, private formats, or branded content.

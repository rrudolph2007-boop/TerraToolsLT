# TerraTools LT Roadmap

## 0.10.0-rc1, parity sprint implemented, runtime acceptance pending

- [x] Core loader, UUIDs, XData, project storage, preferences, layers, scale, reload, and diagnostics
- [x] Master and project planting data, individual plants, areas, mixes, labels, Work Areas, schedules, costs, and CSV import/export
- [x] COPY reconciliation and global smart-object tools
- [x] Site reference notes, measurements, concept polygons, coordinate labels, slope, and spot annotations
- [x] Project details, placements, callouts, renumbering, and indexes
- [x] Lighting catalog/palette, fixtures, transformers, wires, circuits, loads, schedules, costs, and verification
- [x] Irrigation catalog/palette, equipment, pipes, coverage, stations, schedules, and verification
- [x] Bulge-aware LWPOLYLINE length/area and centralized unit conversions
- [x] Directed irrigation topology, per-pipe downstream flow, Hazen-Williams calculations, sizing, and user-assisted critical-path reports
- [x] Normalized plant-data schema, USDA CSV importer, separate user library, attached catalogs, indexed search, pagination, favorites, and recent IDs
- [x] LINE/ARC/LWPOLYLINE plant paths, controlled scatter, and arbitrary percent/ratio mixes
- [x] Reusable user standards exchange and managed Work Area lifecycle
- [x] Site note costs/filtering, detail validation, lighting capacity, and voltage-drop helper
- [x] Expanded DCL launcher, in-product help, deterministic QA, provenance, architecture, contribution, and 48 acceptance scenarios

## Before 1.0

- [ ] Complete all AutoCAD LT scenarios in `ACCEPTANCE_TESTS.md`
- [ ] Fix runtime defects found during acceptance
- [ ] Confirm DCL, DXF entity creation, command localization, and Undo behavior in each supported LT release
- [ ] Validate representative Imperial and Metric project workflows
- [ ] Run 1,000, 5,000, and 10,000 object performance checks and a large USDA catalog search
- [ ] Decide whether automatic branched-network critical-path discovery is safe enough for 1.0
- [ ] Build deeper manager dialogs, configurable label/schedule styles, density areas, and safe region fill
- [ ] Add guided foreign-project reassociation with module-specific catalog validation

Version 1.0 is reserved for a release that has passed the documented runtime acceptance tests.

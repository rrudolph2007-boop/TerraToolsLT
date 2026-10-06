# TerraTools LT Roadmap

## 0.9.0-rc1, implementation complete, runtime acceptance pending

- [x] Core loader, UUIDs, XData, project storage, preferences, layers, scale, reload, and diagnostics
- [x] Master and project planting data, individual plants, areas, mixes, labels, Work Areas, schedules, costs, and CSV import/export
- [x] COPY reconciliation and global smart-object tools
- [x] Site reference notes, measurements, concept polygons, coordinate labels, slope, and spot annotations
- [x] Project details, placements, callouts, renumbering, and indexes
- [x] Lighting catalog/palette, fixtures, transformers, wires, circuits, loads, schedules, costs, and verification
- [x] Irrigation catalog/palette, equipment, pipes, coverage, stations, schedules, and verification
- [x] Directed irrigation topology, downstream flow, Hazen-Williams calculations, sizing, and explicit critical-path reports
- [x] Main DCL launcher with command-line fallbacks
- [x] Release-candidate documentation and acceptance scenarios

## Before 1.0

- [ ] Complete all AutoCAD LT scenarios in `ACCEPTANCE_TESTS.md`
- [ ] Fix runtime defects found during acceptance
- [ ] Confirm DCL, DXF entity creation, command localization, and Undo behavior in each supported LT release
- [ ] Validate representative Imperial and Metric project workflows
- [ ] Run larger-drawing performance checks
- [ ] Decide whether automatic branched-network critical-path discovery is safe enough for 1.0

Version 1.0 is reserved for a release that has passed the documented runtime acceptance tests.

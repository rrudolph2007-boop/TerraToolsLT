# TerraTools LT

TerraTools LT is a landscape architecture production toolkit for AutoCAD LT 2024+ on Windows. Release candidate `0.9.0-rc1` uses AutoLISP, DCL, ordinary DWG entities, TERRATOOLS XData, and external S-expression project files. It does not require full AutoCAD, .NET, ObjectARX, VBA, Civil 3D, Python, Node.js, or a database service.

## Install and load

Keep `TerraTools.lsp` with its `core`, `planting`, `site`, `details`, `lighting`, `irrigation`, `schedules`, `dialogs`, and `data` folders. Add the installation folder to AutoCAD LT's Support File Search Path and Trusted Locations. Include `\...` in the trusted path so subfolders are trusted. Run `APPLOAD`, select `TerraTools.lsp`, then type `TT`.

The loader resolves every module from the folder containing the selected `TerraTools.lsp`. It does not use a machine-specific path. After editing source, use `TTRELOAD`. Use `TTDEVSMOKE` for read-only checks and `TTDEBUG` for current environment and module status.

## Product areas

- `TT`: DCL launcher with a command-line fallback.
- Project: external project records, DWG association, preferences, layers, scale, and Work Areas.
- Planting: Master Catalog, Project Palette, placement, editing, areas, mixes, labels, schedules, costs, and CSV exchange.
- Site: reference notes, measured schedules, concept zones, area, length, volume, slope, coordinate, and spot labels.
- Details: project detail records, placements, callouts, renumbering, and indexes.
- Lighting: Master Fixture Catalog, Project Fixture Palette, fixtures, transformers, wire, circuits, loads, schedules, costs, and verification.
- Irrigation: equipment palette, equipment and pipe graphics, coverage, stations, topology checks, downstream flow, hydraulics, sizing, critical paths, schedules, and verification.
- Diagnostics: smart-object inspection, verification, UUID reconciliation, highlighting, mimic, and substitution.

## Data model

Project data is stored in `terratools-project.dat` in a user-selected project folder. The DWG stores only the project UUID and project path on the Named Object Dictionary. The external file remains authoritative. Before overwrite, the storage layer validates a staging file and maintains `terratools-project.dat.bak`.

Smart objects remain ordinary INSERT, LINE, LWPOLYLINE, CIRCLE, TEXT, or MTEXT entities. TERRATOOLS XData stores a unique entity UUID and lightweight identity fields. AutoCAD handles and block names are not permanent identity. Master records feed project palettes, project records feed placed instances, and schedules and labels are derived from current records and geometry.

Project schema version 1 remains in use. Release-candidate sections are additive, so existing schema-version 1 project files remain valid when the new sections are absent. See [Data Model](docs/DATA_MODEL.md).

## Runtime status

The earlier Core, UUID/XData, project, preferences, layer, scale, Master Plant Catalog, and basic Project Plant Palette work passed real AutoCAD LT tests before this release-candidate pass. The new release-candidate modules have received static review only. Run [ACCEPTANCE_TESTS.md](ACCEPTANCE_TESTS.md) in AutoCAD LT before treating them as verified.

Known limits are documented in the [User Guide](docs/USER_GUIDE.md), especially directed irrigation topology, explicit critical-path selection, Xref read-only behavior, simple original symbols, and TEXT/MTEXT schedule output.

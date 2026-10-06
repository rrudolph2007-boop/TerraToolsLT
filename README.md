# TerraTools LT

TerraTools LT is a landscape architecture production toolkit for AutoCAD LT 2024+ on Windows. Release candidate `0.10.0-rc1` uses AutoLISP, DCL, ordinary DWG entities, TERRATOOLS XData, and external S-expression project files. It does not require full AutoCAD, .NET, ObjectARX, VBA, Civil 3D, Python, Node.js, or a database service.

## Install and load

Keep `TerraTools.lsp` with its `core`, `planting`, `site`, `details`, `lighting`, `irrigation`, `schedules`, `dialogs`, and `data` folders. Add the installation folder to AutoCAD LT's Support File Search Path and Trusted Locations. Include `\...` in the trusted path so subfolders are trusted. Run `APPLOAD`, select `TerraTools.lsp`, then type `TT`.

The loader resolves every module from the folder containing the selected `TerraTools.lsp`. It does not use a machine-specific path. After editing source, use `TTRELOAD`. Use `TTQACHECK` for deterministic read-only calculations, `TTDEVSMOKE` for installation/project checks, and `TTDEBUG` for the current environment.

For optional startup loading, use AutoCAD LT's APPLOAD Startup Suite after the TerraTools folder is in both Support File Search Path and Trusted Locations. Add this installation's `TerraTools.lsp` through the Startup Suite. TerraTools does not install or rewrite `acaddoc.lsp`, and it does not weaken `SECURELOAD`.

## Product areas

- `TT`: DCL launcher with a command-line fallback.
- Project: external project records, DWG association, reusable user standards, preferences, layers, scale, and managed Work Areas.
- Planting: distributed/user/external plant data, indexed search, Project Palette, path/array/random placement, curved areas, multi-component mixes, labels, schedules, costs, and CSV tools.
- Site: cost-aware reference notes, Work Area schedules, concept zones, bulge-aware measurements, slope/ratio, bearing, coordinates, and spot labels.
- Details: searchable metadata fields, source-file checks, duplicate-number checks, placements, callouts, renumbering, and indexes.
- Lighting: Master Fixture Catalog, Project Fixture Palette, fixtures, transformers, wire, circuits, capacity checks, voltage-drop helper, schedules, costs, and verification.
- Irrigation: equipment palette, equipment and pipe graphics, coverage, stations, topology checks, per-pipe downstream flow, hydraulics, sizing, selected critical paths, schedules, and verification.
- Diagnostics: smart-object inspection, verification, UUID reconciliation, highlighting, mimic, and substitution.

## Data model

Project data is stored in `terratools-project.dat` in a user-selected project folder. The DWG stores only the project UUID and project path on the Named Object Dictionary. The external file remains authoritative. Before overwrite, the storage layer validates a staging file and maintains `terratools-project.dat.bak`.

Smart objects remain ordinary INSERT, LINE, LWPOLYLINE, CIRCLE, TEXT, or MTEXT entities. TERRATOOLS XData stores a unique entity UUID and lightweight identity fields. AutoCAD handles and block names are not permanent identity. Master records feed project palettes, project records feed placed instances, and schedules and labels are derived from current records and geometry.

Project schema version 1 remains in use. New sections are additive, so existing schema-version 1 project files remain valid when they are absent. See [Data Model](docs/DATA_MODEL.md), [Architecture](ARCHITECTURE.md), and [Data Sources](DATA_SOURCES.md).

The repository is being prepared for public release, but a final software license has not been chosen. See [License Notes](LICENSE_NOTES.md) and [Contributing](CONTRIBUTING.md).

## Runtime status

The earlier Core, UUID/XData, project, preferences, layer, scale, Master Plant Catalog, and basic Project Plant Palette work passed real AutoCAD LT tests before this release-candidate pass. The new release-candidate modules have received static review only. Run [ACCEPTANCE_TESTS.md](ACCEPTANCE_TESTS.md) in AutoCAD LT before treating them as verified.

Known limits are documented in the [User Guide](docs/USER_GUIDE.md) and [Parity Matrix](PARITY_MATRIX.md), especially user-assisted critical paths, Xref read-only behavior, simple original symbols, fixed schedule layouts, and runtime areas awaiting LT acceptance.

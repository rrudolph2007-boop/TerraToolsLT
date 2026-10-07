# TerraTools LT

TerraTools LT is a landscape architecture production toolkit for AutoCAD LT 2024+ on Windows. Release candidate `0.12.0-rc1` uses AutoLISP, DCL, ordinary DWG entities, TERRATOOLS XData, and external S-expression project files. It does not require full AutoCAD, .NET, ObjectARX, VBA, Civil 3D, Python, Node.js, or a database service.

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
- Irrigation: equipment palette, equipment and pipe graphics, coverage, stations, topology checks, per-pipe downstream flow, hydraulics, sizing, automatic critical paths, schedules, and verification.
- Diagnostics: smart-object inspection, verification, UUID reconciliation, highlighting, mimic, and substitution.

## Data model

Project data is stored in `terratools-project.dat` in a user-selected project folder. The DWG stores only the project UUID and project path on the Named Object Dictionary. The external file remains authoritative. Before overwrite, the storage layer validates a staging file and maintains `terratools-project.dat.bak`.

Smart objects remain ordinary INSERT, LINE, LWPOLYLINE, CIRCLE, TEXT, or MTEXT entities. TERRATOOLS XData stores a unique entity UUID and lightweight identity fields. AutoCAD handles and block names are not permanent identity. Master records feed project palettes, project records feed placed instances, and schedules and labels are derived from current records and geometry.

Project schema version 1 remains in use. New sections are additive, so existing schema-version 1 project files remain valid when they are absent. See [Data Model](docs/DATA_MODEL.md), [Architecture](ARCHITECTURE.md), and [Data Sources](DATA_SOURCES.md).

The repository is being prepared for public release, but a final software license has not been chosen. See [License Notes](LICENSE_NOTES.md) and [Contributing](CONTRIBUTING.md).

## Optional production plant database

The software works with its 15 fictional sample plants without installing a large dataset. The separate WFO June 2026 CC0 package contains 435,702 accepted taxa, 999,746 linked aliases and 435,702 taxonomy-only descriptions. It was built locally and reverified during closure. It is not a horticultural specification library.

Extract the data package so `data/plants/production/manifest.dat` sits below the TerraTools root. Set LISPSYS to 1 or 2 and restart LT if needed. Run `TTPLANTDATABASE`, then search with `TTPLANTS` > Search Plant Library. Runtime needs no Node installation. See [Plant Database](docs/PLANT_DATABASE.md) for package, build and update instructions.

## Current production workflows

`TTPLANTS` opens the Plant Manager with Project Plants, Search Plant Library, Favorites and Recent views. Variants share source provenance but have independent project IDs and unique codes. `TTPLANTFILL`, `TTDENSITYAREA`, `TTPLANTSYMBOLS`, `TTLABELSTYLE` and `TTSCHEDULESTYLE` provide the newer planting controls.

Shared record managers: `TTWORKAREAS`, `TTREFNOTES`, `TTDETAILS`, `TTLIGHTING`, `TTIRRIGATION`, `TTSTATIONS`, `TTCONTROLLERS`. Existing command-line entry points remain available where documented. `TTRECOVERPROJECT`, `TTPACKAGE` and `TTADOPT` provide deliberate recovery and limited portability.

## Runtime status

Earlier foundation tests passed in real AutoCAD LT. Closure was exercised in AutoCAD LT 2027 Core Console using disposable drawings/projects: loader/reload, read-only QA/smoke, project lifecycle, variants, recovery, package reopen, controller validation, XData and graph calculations. This does **not** establish GUI acceptance or compatibility with every LT version. The minimal DCL control and product dialogs both returned -1 in Core Console. Visible dialogs remain untested.

Run the 80 engineering and 15 UX scenarios in [Acceptance Tests](ACCEPTANCE_TESTS.md). [Release Checklist](RELEASE_CHECKLIST.md) records verification and remaining release gates. [Parity Matrix](PARITY_MATRIX.md) lists every deferred or partial capability. This is a prerelease, not 1.0.

The UX polish adds a persistent installed-database banner, explicit SAMPLE labels, project/library view controls, grouped native dialogs and workflow Tools menus. See [UX review and visual acceptance](docs/UX_REVIEW.md). Visible GUI testing is still required.

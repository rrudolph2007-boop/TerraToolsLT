# TerraTools LT — Engineering Instructions for AI Coding Agents

This file contains permanent engineering rules for all AI coding agents working in the TerraTools LT repository.

These rules apply to:

- feature development
- bug fixes
- refactoring
- database work
- UI work
- documentation work
- testing
- release preparation

Read this file completely before modifying the repository.

Also read `PRODUCT_REQUIREMENTS.md` before performing substantial product work.

---

# 1. Product Identity

TerraTools LT is an independently implemented landscape architecture CAD production system designed specifically for:

**AutoCAD LT 2024+ on Windows**

The goal is to provide professional landscape architecture workflows using technologies available in AutoCAD LT.

TerraTools is not a clone of another commercial application.

It may implement broadly similar professional workflow categories, but all code, UI, graphics, data architecture, documentation, symbols, and implementation details must be original or appropriately licensed.

---

# 2. Instruction Authority

When instructions conflict, use the following repository-level hierarchy:

1. `AGENTS.md` — permanent engineering policy
2. `PRODUCT_REQUIREMENTS.md` — permanent product requirements
3. explicit current user/task instructions
4. `PARITY_MATRIX.md` — current implementation truth
5. `ACCEPTANCE_TESTS.md` — runtime release criteria
6. architecture and technical documentation
7. roadmap and general documentation
8. existing implementation behavior

Do not weaken `AGENTS.md` or `PRODUCT_REQUIREMENTS.md` merely to make existing code appear complete.

If implementation conflicts with a permanent requirement, improve the implementation when technically feasible.

---

# 3. Runtime Platform

Production runtime must remain compatible with AutoCAD LT 2024+ on Windows.

Prefer:

- AutoLISP
- DCL
- standard AutoCAD commands
- DXF entity data
- XData
- ordinary DWG entities
- local filesystem operations
- external text-based project storage
- CSV
- documented S-expression-style data
- pure AutoLISP calculations

Do not introduce normal runtime dependencies on:

- .NET
- WPF
- ObjectARX
- VBA
- Civil 3D
- full-AutoCAD-only APIs
- Python
- Node.js
- Java
- external DLLs
- database servers
- unsupported COM/ActiveX functionality

Optional development or data-build utilities may use another language only when:

1. AutoCAD LT runtime does not require it.
2. The utility is optional.
3. Dependencies are documented.
4. Output uses documented/open formats.
5. Normal TerraTools operation remains independent of the development utility.

---

# 4. Engineering Priority Order

When tradeoffs occur, prioritize:

1. correctness
2. data integrity
3. AutoCAD LT runtime reliability
4. professional usability
5. workflow efficiency
6. database quality
7. maintainability
8. performance
9. interface consistency
10. visual quality
11. feature breadth

Do not sacrifice correctness for sophistication.

Do not sacrifice data integrity for convenience.

Do not present uncertain engineering calculations as authoritative.

---

# 5. Naming Conventions

Public commands must begin with:

`TT`

Examples:

- `TT`
- `TTPLANTS`
- `TTVERIFY`

Internal functions should use:

`TT:`

Examples:

- `TT:ProjectLoad`
- `TT:EntityArea`

Global TerraTools variables should follow the existing TerraTools naming convention and should be introduced sparingly.

Avoid uncontrolled global namespace pollution.

---

# 6. Public Command Stability

Public `TT...` commands are a user-facing API.

Preserve documented public commands whenever practical.

If a better DCL manager replaces an older command workflow:

- keep the old command as an entry point where practical
- redirect it to the improved workflow if appropriate
- preserve scripts and user habits where feasible

Do not casually rename or remove public commands.

If deprecation is unavoidable, provide a compatibility wrapper when feasible and document the change.

---

# 7. Module Boundaries

Maintain clear module ownership.

Current major areas include:

- `core/`
- `planting/`
- `site/`
- `details/`
- `lighting/`
- `irrigation/`
- `schedules/`
- `dialogs/`
- `data/`

Core modules should own reusable infrastructure such as:

- storage
- UUID generation
- XData
- units
- geometry
- preferences
- standards
- reconciliation
- CSV
- shared UI helpers
- shared schedule helpers
- validation
- QA

Product modules should own their domain-specific workflows.

Avoid circular module dependencies.

Load modules in explicit dependency order through `TerraTools.lsp`.

---

# 8. Main Loader

`TerraTools.lsp` is the authoritative application loader.

It must:

- resolve modules from the exact TerraTools installation root
- avoid accidentally loading stale support-path copies
- load modules in dependency order
- verify required files exist
- identify the exact failing module
- leave readiness flags false after failure
- set the product version consistently

Whenever a module is added, renamed, or removed, review the loader.

Do not rely on machine-specific absolute installation paths.

---

# 9. CAD Entity Architecture

Prefer ordinary AutoCAD entities wherever practical:

- INSERT
- LINE
- ARC
- LWPOLYLINE
- CIRCLE
- TEXT
- MTEXT
- HATCH when reliable and appropriate

TerraTools intelligence should be added through lightweight metadata and external project data rather than proprietary entity types.

A TerraTools drawing should remain meaningfully editable in AutoCAD LT even if TerraTools is not loaded.

---

# 10. XData Architecture

Use registered application:

`TERRATOOLS`

XData should remain lightweight.

Typical semantic fields may include:

- `ENTITY_UUID`
- `PROJECT_UUID`
- `MODULE`
- `OBJECT_TYPE`
- `CATALOG_ID`
- `WORK_AREA_ID`
- schema/version information
- small domain-specific identity fields where justified

Do not turn XData into a full database.

Do not place large lists or large descriptive records into entity XData when external/project storage is more appropriate.

---

# 11. Identity Rules

AutoCAD handles are not permanent TerraTools identity.

Block names are not permanent TerraTools identity.

Use UUIDs and stable catalog/project identifiers.

Entity identity:

`ENTITY_UUID`

Project identity:

`PROJECT_UUID`

Catalog/project identity:

stable domain IDs

Normal AutoCAD COPY may duplicate XData.

TerraTools reconciliation must detect duplicate entity UUIDs and assign new instance UUIDs without destroying semantic links.

---

# 12. Data Authority Hierarchy

Maintain this hierarchy:

Distributed / Open Master Data  
→ User Library  
→ Project Palette / Project Record  
→ Placed Instance  
→ Derived Label / Schedule / Report

Master or external data is reusable source material.

Project records are editable project-owned copies.

Placed instances reference project records.

Schedules, labels, reports, quantities, and cost summaries are derived output.

Derived output is never the source of truth.

---

# 13. Project Records Must Be Source-Independent

Once a source record is copied into a Project Palette, the project copy must remain usable even if the original source becomes:

- detached
- moved
- renamed
- deleted
- temporarily inaccessible

The source identifier remains provenance.

The Project Palette record remains project authority.

Do not invalidate an otherwise valid project record merely because its original source library is unavailable.

Reattaching the source should restore provenance resolution without changing the project identity.

Apply this principle where appropriate to:

- plants
- lighting fixtures
- irrigation equipment
- details
- other project-owned library records

---

# 14. External Project Storage

External project storage is authoritative for project-level data.

The DWG should contain only lightweight association data sufficient to locate and validate the project.

Project writes should use safe staging/validation/backup behavior where practical.

Do not silently recreate missing project files.

Do not silently search for similarly named project files and adopt them.

A missing project file should be reported clearly.

---

# 15. Storage Abstraction

Do not spread raw filesystem serialization logic across product modules.

Use shared storage abstractions.

Separate:

- serialization
- filesystem I/O
- validation
- migration
- product logic

Unknown compatible project fields should be preserved where feasible.

---

# 16. Schema Evolution and Migration

Schema changes require explicit migration logic.

Do not silently reinterpret older project data.

A migration should:

1. validate the old data
2. preserve a backup
3. apply deterministic transformations
4. validate the migrated data
5. write safely
6. preserve compatible unknown fields
7. report success or failure

Existing valid projects should remain openable through supported migrations.

Never destroy the only known-good copy.

---

# 17. Backup and Recovery

If project data becomes unreadable and a known-valid backup exists:

do not silently overwrite either file.

Provide a deliberate recovery path.

Recovery behavior should be understandable and user-controlled.

Never treat the backup as disposable until the replacement has been validated.

---

# 18. Imported Data Is Untrusted

Treat all imported external content as untrusted input.

This includes:

- CSV
- external plant catalogs
- user libraries
- office standards
- project packages
- externally generated data files

Validate:

- structure
- schema
- types
- IDs
- paths
- numeric ranges where sensible
- record counts where useful

Do not `eval` imported content.

Do not execute imported strings.

Malformed data must fail cleanly without corrupting current project state.

---

# 19. Clean-Room Development

Do not copy proprietary commercial software content.

Do not add:

- proprietary source code
- reverse-engineered private formats
- proprietary databases
- proprietary CAD symbols
- proprietary block libraries
- proprietary details
- proprietary screenshots
- copied UI artwork
- copied icons
- copied logos
- copied documentation
- copied plant descriptions
- copyrighted commercial plant imagery

General workflow concepts may be independently implemented.

TerraTools terminology, graphics, code, and UI should remain original.

---

# 20. Data Licensing and Provenance

Never fabricate licensing status.

Never assume public visibility permits redistribution.

Every bundled external dataset should have documented:

- source
- source URL
- version/date
- license or public-domain status
- attribution
- redistribution status

Prefer:

- public-domain government data
- permissively licensed open data
- original TerraTools samples
- user-imported data

Do not scrape proprietary plant or manufacturer databases.

---

# 21. Plant Database Standard

The original 15 fictional records are sample/test data, not the intended professional database.

The plant-data architecture should support professional-scale datasets.

Target where legally and technically achievable:

**50,000+ legitimate searchable plant/taxon records**

Never inflate counts with:

- fake plants
- generated fake cultivars
- duplicated aliases counted as unique accepted taxa
- blank cloned records
- fabricated botanical data

Database scale never overrides provenance or correctness.

---

# 22. Plant Data Architecture

Separate:

- distributed open database
- user custom plants
- project plant palette
- placed plants

Distributed-data updates must never overwrite:

- user custom plants
- project plants
- project-specific edits

Stable project identity must survive updates to distributed data.

---

# 23. Source Facts vs Generated Plant Content

Source-provided facts and TerraTools-generated editorial content are separate data layers.

Potential generated fields may include:

- `GENERATED_DESCRIPTION`
- `GENERATED_DESIGN_NOTES`
- `DESCRIPTION_GENERATION_VERSION`
- `DESCRIPTION_FACT_FIELDS`
- `DESCRIPTION_CONFIDENCE`

Generated content must remain identifiable as generated.

Never overwrite source facts with generated prose.

---

# 24. Generated Plant Description Rules

Generated descriptions may summarize verified structured fields.

They must not invent factual claims such as:

- mature size
- hardiness
- native status
- water requirements
- sunlight requirements
- soil preference
- toxicity
- edibility
- bloom color
- bloom season
- growth rate
- wildlife value
- deer resistance
- salt tolerance
- disease resistance
- invasiveness

unless supported by legitimate source data.

If the fact is unavailable, omit it.

Do not generate false certainty merely to produce richer prose.

Normal AutoCAD runtime must not require an AI API or API key.

---

# 25. Reproducible Data Builds

Production-scale datasets should be reproducible where practical.

Maintain build/source metadata such as:

- source name
- source URL
- source version/date
- license
- original filename
- checksum when practical
- normalization version
- schema version
- index version
- description-generation version

Separate appropriately:

- source code
- source manifests
- raw download cache
- generated production data
- search indexes

Do not commit uncontrolled raw downloads or temporary data.

Never hardcode fabricated database counts.

---

# 26. Database Manifest

Professional-scale data should expose a real manifest with actual values such as:

- database version
- schema version
- build version
- generated date
- total records
- accepted records
- synonym/alias count
- description count
- source counts
- source versions
- index version
- description-generation version

Diagnostics and documentation should consume actual manifest values when appropriate.

---

# 27. Search Performance

Do not display tens of thousands of records as command-line lists.

Large data should use:

- search
- filtering
- paging
- indexes
- lazy loading
- session caches

Do not parse the entire professional plant database during ordinary application startup unless unavoidable.

Do not rebuild a full-record search representation for every query.

---

# 28. UX Is Part of Product Correctness

A feature is not professionally complete merely because a function exists.

Normal workflows should strive to be:

- discoverable
- understandable
- efficient
- consistent
- forgiving
- easy to cancel
- easy to undo
- free of internal IDs
- searchable
- context-aware
- optimized for repetitive production work

Major routine workflows should use DCL when a reliable dialog materially improves the experience.

Command-line fallbacks should remain where useful.

---

# 29. Internal IDs Must Stay Internal

Normal users should not need to type or understand:

- entity UUID
- project UUID
- project plant ID
- catalog ID
- schema keys
- storage implementation fields

Prefer:

- selection
- human-readable names
- codes
- searchable lists
- managers

---

# 30. Repetitive Workflows

High-frequency placement workflows should support continuous operation where appropriate.

Examples:

- plant placement
- fixture placement
- irrigation equipment placement

Do not force users to restart a workflow after every object if continued placement is safe and natural.

---

# 31. Safe Defaults and Recent Values

Where predictable and useful, TerraTools may remember:

- recent plant
- recent fixture
- recent irrigation equipment
- active Work Area
- recent station
- pipe class
- label style
- schedule style

Remembered state must be visible or understandable.

Avoid hidden surprising state.

---

# 32. Empty States

Dialogs with no records should provide a useful next step.

Prefer:

"No project plants have been added yet. Search the Plant Database to add one."

instead of:

"No records."

Do not create dead-end managers.

---

# 33. Error Messages

User-facing errors should communicate:

1. what happened
2. why it likely happened
3. what the user can do next

Avoid vague output such as:

- Invalid
- Failed
- Error
- Nil result

Cancellation should not be presented as failure.

---

# 34. Undo

One logical user operation should generally correspond to one AutoCAD Undo action where practical.

Multi-object creation commands should group their changes sensibly.

Ensure error/cancel handlers close any opened Undo group.

---

# 35. System Variables

If a command temporarily changes AutoCAD system variables:

- save original values
- restore them after success
- restore them after failure
- restore them after cancellation where feasible

Do not leave the drawing environment altered unexpectedly.

---

# 36. DCL Visual Standard

TerraTools should have one coherent original visual language.

Use consistent conventions for:

- dialog titles
- grouping
- spacing
- button ordering
- button widths
- list dimensions
- search controls
- selected-record information
- help/status text
- Close/Cancel behavior

Major dialogs should visibly feel like one application.

---

# 37. DCL Usability

Within DCL capabilities:

- use sensible tab order
- use `is_default` appropriately
- use `is_cancel` appropriately
- Enter should activate a sensible default
- Esc should cancel safely
- avoid mouse-only dependency when keyboard operation is practical
- avoid oversized dialogs
- avoid cramped dialogs
- avoid controls with truncated common labels

Do not rely only on color to communicate status.

---

# 38. Visual Quality

TerraTools should look:

- clean
- professional
- calm
- precise
- consistent
- architectural
- legible

Avoid:

- debug-style UI
- random button placement
- inconsistent capitalization
- excessive text
- visual clutter
- copied commercial visual design

---

# 39. CAD Graphic Quality

Generated CAD output should also be professionally coherent.

Review:

- plant symbols
- lighting symbols
- irrigation symbols
- labels
- leaders
- schedules
- detail frames
- Work Area graphics
- coverage graphics

Original symbols should use consistent scale, center points, complexity, and visual weight.

Do not copy proprietary blocks.

---

# 40. Layer Roles

Use logical layer roles rather than hardcoded physical layer names.

Maintain module-appropriate roles for:

- planting
- site
- details
- lighting
- irrigation
- Work Areas
- schedules
- labels
- helpers

Preserve existing project mappings when expanding role definitions.

---

# 41. Coordinate System Correctness

Do not assume geometry can always be interpreted directly from raw coordinates.

Audit relevant calculations for:

- WCS
- UCS
- OCS
- LWPOLYLINE elevation
- extrusion direction

Use `trans` or appropriate DXF interpretation when required.

If unsupported geometry orientation cannot be reliably analyzed:

report the limitation instead of silently returning incorrect values.

---

# 42. Unit Correctness

Centralize unit conversion.

Do not implement independent ad hoc conversion code in product modules.

If project units and drawing units cannot be resolved for a unit-sensitive calculation:

stop and report the issue.

Do not guess from visual scale.

---

# 43. Geometry Engine

Shared geometry helpers should be authoritative.

Support where feasible:

- LINE
- ARC
- CIRCLE
- LWPOLYLINE
- positive bulges
- negative bulges
- mixed straight/arc boundaries
- open and closed paths

Reusable geometry should serve multiple modules rather than being reimplemented repeatedly.

---

# 44. Irrigation Engineering Discipline

Irrigation analysis must prioritize correctness.

Each pipe's design flow must be derived from actual downstream demand.

Do not use entire station demand for every pipe.

Detect or handle:

- branches
- loops
- merged incoming paths
- disconnected demand
- orphan pipes
- reversed/suspicious direction
- multiple sources
- zero-length edges
- unresolved units

Do not produce automatic critical-path results for ambiguous topology.

---

# 45. Pipe Hydraulic Diameter

When actual inside diameter is available, use it for hydraulic calculations.

Do not blindly assume nominal pipe size equals internal hydraulic diameter.

Pipe classes should separate:

- nominal diameter
- actual inside diameter
- material/class
- Hazen-Williams C factor

---

# 46. Engineering Claims

Hydraulic, lighting, water-runtime, or similar engineering helpers should make assumptions transparent.

Do not claim:

- code compliance
- stamped engineering validity
- regulatory approval

unless TerraTools genuinely has a verified basis for doing so.

---

# 47. Performance Discipline

Avoid repeated full-drawing scans within one operation.

Prefer:

- one smart-object scan
- temporary lookup maps
- UUID lookup tables
- graph structures
- indexed searches

over repeated nested scans.

Optimize obvious O(n²) patterns when reliable alternatives exist.

Never claim a performance benchmark that was not actually measured.

---

# 48. Multi-Drawing Isolation

Users may have multiple drawings/projects open.

Project-specific global state must not silently leak between drawings.

Audit state such as:

- current project
- current project path
- project UUID
- preferences
- attached external datasets
- active Work Area
- recent project-specific selections

Shared read-only caches are acceptable only if they cannot contaminate project-specific state.

---

# 49. CSV Handling

Shared CSV logic should correctly handle normal:

- commas
- quoted fields
- escaped quotes
- blanks
- headers

Do not implement incompatible one-off CSV parsers in separate modules.

Treat imported CSV as untrusted input.

---

# 50. CSV Formula Safety

Spreadsheet applications may interpret cell text beginning with:

- `=`
- `+`
- `-`
- `@`

as formulas.

Do not silently alter project data.

Where exporting potentially untrusted user text, provide or document an explicit safe strategy to prevent accidental spreadsheet formula execution when appropriate.

---

# 51. Project Packaging

Project package operations must validate included paths.

Package import/extraction must not allow path traversal outside the intended destination.

Use manifests where practical.

External resources should not be copied silently.

---

# 52. Xrefs

Treat Xref content as read-only unless a supported safe workflow explicitly exists.

Do not attempt to mutate referenced drawing content indirectly.

Make limitations clear.

---

# 53. Global Verification

TerraTools verification should eventually be capable of detecting problems such as:

- malformed XData
- missing UUID
- duplicate UUID
- unknown schema
- unknown module
- unknown object type
- foreign project UUID
- missing project record
- unavailable source
- invalid Work Area
- missing symbol
- orphan label
- orphan schedule
- broken detail source
- lighting overload
- irrigation ambiguity

Fix only issues that can be repaired unambiguously.

---

# 54. Privacy

Normal TerraTools runtime should have no hidden telemetry.

Do not transmit:

- project information
- drawing information
- plant selections
- user libraries
- file paths
- usage analytics

without explicit future user consent and a clear user-facing feature.

TerraTools should remain usable offline after local resources are installed.

---

# 55. Secrets

Never commit:

- API keys
- credentials
- passwords
- tokens
- personal test data
- private user project data

Keep `.env` and similar secret-bearing artifacts out of source control.

---

# 56. Release Hygiene

Do not commit local AutoCAD artifacts such as:

- `acadlt.err`
- `ErrorReports/`
- crash dumps
- recovery files
- temporary project data
- `.dwl`
- `.dwl2`

Maintain `.gitignore`.

---

# 57. Documentation Truthfulness

Documentation must describe the code that actually exists.

Do not rewrite docs to make unfinished functionality appear complete.

`PARITY_MATRIX.md` should be conservative.

When static review is the only verification, say so.

When AutoCAD LT runtime testing has passed, that may be documented explicitly.

---

# 58. Capability Status

Do not mark a feature IMPLEMENTED merely because:

- a function exists
- a command exists
- a button exists
- architecture exists
- documentation exists
- an importer exists

A capability should generally be IMPLEMENTED only when:

1. production code exists
2. it is loaded
3. it is integrated into a usable workflow
4. required persistence works
5. error/cancel behavior exists
6. documentation matches
7. relevant acceptance coverage exists

---

# 59. Testing Strategy

Use:

`TTRELOAD`

for exact-root development reload.

Use:

`TTDEVSMOKE`

for fast read-only installation/module/project smoke checking.

Use:

`TTQACHECK`

for deterministic read-only calculations.

Do not turn `TTDEVSMOKE` into a long destructive acceptance suite.

Do not make `TTQACHECK` modify drawing/project state.

---

# 60. Runtime Authority

Real AutoCAD LT behavior is authoritative.

Static reasoning cannot prove:

- DCL rendering
- command localization
- SECURELOAD behavior
- AutoCAD database edge cases
- selection behavior
- all entity mutation behavior

If runtime behavior differs from assumptions, investigate the exact runtime result.

---

# 61. Debugging Discipline

When fixing a bug:

1. identify the exact failing behavior
2. locate the root cause
3. make the smallest safe correction
4. avoid unrelated redesign
5. add or update a regression check where practical
6. retest the affected workflow

Do not rewrite entire subsystems for small bugs unless architecture truly requires it.

---

# 62. No Automatic Git Mutation

Coding agents must not automatically:

- commit
- push
- merge
- rebase
- reset
- force-push

unless the user explicitly requests that Git action.

Leave changes available for user review.

---

# 63. No Fake Completion

Never fabricate:

- runtime test results
- database counts
- plant facts
- source provenance
- licensing
- manufacturer data
- prices
- performance benchmarks
- engineering results

If something remains unverified, say so.

Reliability and honesty are more important than appearing complete.

---

# 64. Final Engineering Principle

Reliability is more valuable than cleverness.

A smaller feature that works predictably in AutoCAD LT is preferable to a sophisticated feature that depends on unsupported behavior.

Push AutoCAD LT hard, but stay inside a defensible architecture.

TerraTools should remain understandable, inspectable, repairable, and trustworthy.
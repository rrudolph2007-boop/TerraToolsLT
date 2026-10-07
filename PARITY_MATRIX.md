# TerraTools LT Capability Matrix

Status definitions: **IMPLEMENTED** means integrated production code exists. **PARTIAL** means a useful subset exists but the workflow is incomplete. **MISSING** means no working implementation exists. **LT-LIMITED** means AutoCAD LT prevents or materially constrains a dependable equivalent. This matrix describes the repository, not runtime verification.

Closure review for `0.12.0-rc1`, 2026-10-06. Repository status is distinct from GUI acceptance. See RELEASE_CHECKLIST.md for actual execution evidence.

## Project Management

| Capability | Status | Notes |
|---|---|---|
| Create, open, close project | IMPLEMENTED | External project file and command workflow. |
| Persistent DWG association | IMPLEMENTED | Named Object Dictionary XData. |
| Missing project detection | IMPLEMENTED | Association remains unresolved without fabricating data. |
| UUID mismatch detection | IMPLEMENTED | External record must match drawing association. |
| Safe write and backup | IMPLEMENTED | Staging and `.bak` replacement. |
| Project migration log | PARTIAL | Schema 1 identity migration is tested; no historical migration exists or runs, so no migration event log is needed yet. |
| Project archive/package | IMPLEMENTED | TTPACKAGE creates a new folder with manifest and explicitly selected resources; DWG copying is manual. |
| Recent projects | MISSING | Deferred convenience: no recent-project list; explicit Open remains available. |

## Plant Database

| Capability | Status | Notes |
|---|---|---|
| Schema-validated master catalog | IMPLEMENTED | Current catalog has 15 fictional sample records. |
| Normalized professional record model | IMPLEMENTED | External schema supports taxonomy, cultural, size, use, and provenance fields without requiring them. |
| Tens-of-thousands record support | IMPLEMENTED | Installed WFO build: 435,702 accepted taxa, 999,746 aliases; lazy record shards and token-prefix indexes. |
| Open government data ingestion | IMPLEMENTED | `TTIMPORTUSDA` converts the official checklist fields; no USDA records are bundled. |
| Source provenance per record | IMPLEMENTED | Normalized records carry source ID, URL, license note, attribution, and date fields. |
| User custom plant library | IMPLEMENTED | Roaming user file is separate from distributed data. |
| Optional missing fields | IMPLEMENTED | Absent source values remain blank or nil. |
| Duplicate master ID validation | IMPLEMENTED | Duplicate IDs fail validation. |

## Plant Project Palette

| Capability | Status | Notes |
|---|---|---|
| Add by category and number | IMPLEMENTED | Stable Master ID is retained internally. |
| List, edit, remove | IMPLEMENTED | Project copies are independently editable. |
| Duplicate protection | IMPLEMENTED | Unique PROJECT_PLANT_ID and case-insensitive project code; MASTER_PLANT_ID may repeat for variants. |
| Search before add | IMPLEMENTED | Multi-word indexed search with category/favorite filter and pagination. |
| Favorites and recent plants | IMPLEMENTED | Plant Manager includes Favorites and Recent Plants; project-owned source IDs persist. Unavailable sources are omitted. |
| Batch edit | MISSING | Deferred: editing is one project record at a time; batch instance replacement already exists. |
| Duplicate code validation | IMPLEMENTED | Central PlantPaletteSave guard covers DCL, CLI and code imports; existing conflicts remain readable for repair. |
| User plant link | IMPLEMENTED | User and attached normalized IDs resolve through the same Master lookup. |

## Plant Symbols

| Capability | Status | Notes |
|---|---|---|
| Original generated tree/shrub/groundcover symbols | IMPLEMENTED | Simple block definitions. |
| Per-project symbol override | IMPLEMENTED | Stored on project plant record. |
| Shared symbol families | IMPLEMENTED | Multiple records may use the same block. |
| User block assignment | IMPLEMENTED | Project symbol field accepts a block name. |
| Symbol scale controls | IMPLEMENTED | TTPLANTSYMBOLS persists per-project-plant scale and refreshes existing INSERTs. |
| Symbol preview | MISSING | Deferred visual polish: no symbol preview tile; placed symbols can be inspected in the DWG. |
| Symbol favorites/categories | MISSING | Deferred separate symbol-library UX; project records already retain assigned block names. |
| Missing-symbol verification/recovery | PARTIAL | TTPLANTSYMBOLS recreates generic defaults and refreshes assignments; missing custom block artwork cannot be reconstructed. |

## Plant Placement

| Capability | Status | Notes |
|---|---|---|
| Single and continuous placement | IMPLEMENTED | Repeated point loop. |
| Straight-line fixed spacing | IMPLEMENTED | `TTPLANTLINE`. |
| Rectangular array | IMPLEMENTED | `TTPLANTARRAY`. |
| Naturalistic scatter | IMPLEMENTED | Bounded seeded closed-XY polygon fill plus rectangular random scatter; supports sampled curved boundaries. |
| Along polyline or arc | IMPLEMENTED | LINE, ARC, and bulged LWPOLYLINE paths use authoritative geometry. |
| Equal spacing on path | IMPLEMENTED | Open and closed paths distribute requested counts without duplicate endpoints. |
| Fill closed region | IMPLEMENTED | TTPLANTFILL uses supported WCS XY boundaries, containment, spacing and bounded attempts. |
| Random rotation and scale | IMPLEMENTED | User-entered scale and rotation ranges are applied to each INSERT. |
| Work Area at placement | IMPLEMENTED | TTACTIVEWORKAREA is project-UUID scoped; plant and shared-manager placements inherit it. |

## Plant Editing

| Capability | Status | Notes |
|---|---|---|
| Replace selected plant | IMPLEMENTED | Position, transform, UUID, and Work Area remain. |
| Match selected plants | IMPLEMENTED | Source identity applies to targets. |
| Highlight and locate | IMPLEMENTED | Transient highlight and zoom. |
| Select similar | IMPLEMENTED | TTSELECTSIMILAR returns a selection set with project/module/type/catalog matching. |
| Count project | IMPLEMENTED | Counts project plant identities. |
| Count selected | IMPLEMENTED | TTCOUNTSELECTED counts selected plant INSERTs. |
| Count Work Area | IMPLEMENTED | TTCOUNTWORKAREA reports derived planting quantities and assigned cross-module object counts. |
| Batch replace | IMPLEMENTED | Match works on a selected set. |

## Plant Areas

| Capability | Status | Notes |
|---|---|---|
| Closed LWPOLYLINE areas | IMPLEMENTED | Current straight and curved geometry is live. |
| Curved/bulged boundaries | IMPLEMENTED | Signed circular-segment correction handles positive, negative, and mixed bulges. |
| Square spacing | IMPLEMENTED | Derived from current geometry. |
| Triangular spacing | IMPLEMENTED | Uses 0.8660254 cell factor. |
| Explicit spacing units | IMPLEMENTED | Inches, feet, millimeters, centimeters, and meters convert to drawing units. |
| Density-based quantity | IMPLEMENTED | TTDENSITYAREA uses project-variant density per square foot or square meter, with live boundary area. |
| Boundary edit recalculation | IMPLEMENTED | Query and schedules recalculate. |

## Plant Mixes

| Capability | Status | Notes |
|---|---|---|
| Reusable project mix record | IMPLEMENTED | Project data with stable mix UUID. |
| Two-component percentage mix | IMPLEMENTED | Covered by the general 2-20 component workflow. |
| Arbitrary component count | IMPLEMENTED | Mixes accept 2 through 20 unique project plants. |
| Ratio composition | IMPLEMENTED | Positive ratios normalize to stored percentages. |
| Edit existing mix | IMPLEMENTED | Complete composition replacement retains the mix UUID. |
| Per-component derived schedule quantity | IMPLEMENTED | Calculated from area and spacing. |

## Plant Labels

| Capability | Status | Notes |
|---|---|---|
| Single and group labels | IMPLEMENTED | Derived TEXT with target UUID list. |
| Quantity update after deletion | IMPLEMENTED | Live UUID lookup. |
| Orphan detection | IMPLEMENTED | Invalid project label records are reported. |
| Mixed-species guard | IMPLEMENTED | Group must share one Project Plant. |
| Common/botanical-name fields | IMPLEMENTED | TTLABELSTYLE selects quantity/code/name/size/spacing fields used in label output and refresh. |
| Configurable label styles | IMPLEMENTED | Project preference style; exchanged through office standards. |
| Optional leader geometry | PARTIAL | Optional ordinary LINE leader is created; automatic retargeting after moving plants/labels remains deferred. |
| Update after code edit | IMPLEMENTED | Refresh resolves current project code. |

## Plant Schedules

| Capability | Status | Notes |
|---|---|---|
| Derived MTEXT schedule | IMPLEMENTED | Ordinary LT entity. |
| Individual and area quantities | IMPLEMENTED | Mix components included. |
| Work Area filtering | IMPLEMENTED | Explicit assignment filter. |
| Schedule update | IMPLEMENTED | Existing entity text is replaced. |
| Configurable columns | IMPLEMENTED | TTSCHEDULESTYLE selects and orders supported plant schedule columns. |
| Sort and grouping choices | IMPLEMENTED | Plant schedules sort by selected field and optionally group by category; equal rows retained. |
| Reusable schedule style | IMPLEMENTED | Project preference style includes title, columns, sort/group and width; office-standard exchange includes it. |
| Multiple independent schedules | IMPLEMENTED | Each stores its own Work Area filter. |

## Plant Costing

| Capability | Status | Notes |
|---|---|---|
| Unit cost and subtotal | IMPLEMENTED | Project-specific copied costs. |
| Category totals | IMPLEMENTED | Printed summary. |
| Work Area totals | IMPLEMENTED | Explicit scope prompt. |
| Project total | IMPLEMENTED | Derived current total. |
| Cost CSV | IMPLEMENTED | Schedule export includes costs. |
| Cost escalation/alternates | MISSING | Deferred estimating scope; project-specific unit costs and variants cover current production needs. |

## Plant Verification

| Capability | Status | Notes |
|---|---|---|
| Duplicate UUID detection | IMPLEMENTED | Global reconciliation scan. |
| Missing project plant references | IMPLEMENTED | Palette references checked. |
| Missing symbols | IMPLEMENTED | Block table check. |
| Invalid Work Areas | IMPLEMENTED | Explicit IDs checked. |
| Invalid labels | IMPLEMENTED | Project label record lookup. |
| Duplicate plant codes | IMPLEMENTED | TTVERIFY reports central case-insensitive duplicate-code results. |
| Foreign project UUID | IMPLEMENTED | Global verification compares entity and active project UUIDs. |

## Plant Presentation

| Capability | Status | Notes |
|---|---|---|
| Temporary species highlight | IMPLEMENTED | `TTHIGHLIGHTPLANT`. |
| Category/species colorization | MISSING | Deferred presentation mode; transient species highlighting already preserves drawing properties. |
| Canopy display modes | MISSING | Deferred alternate graphics; current project block substitution is supported. |
| Groundcover graphic treatment | PARTIAL | Smart boundary and quantities work; automatic presentation hatches/fills are deferred. |

## Site / Reference Notes

| Capability | Status | Notes |
|---|---|---|
| Count, length, area, volume notes | IMPLEMENTED | Derived from selected geometry. |
| Notation and amenity notes | IMPLEMENTED | Count-like records. |
| Materials and hardscape categories | IMPLEMENTED | Dedicated reference-note types are available. |
| Note editing | IMPLEMENTED | Code, description, and project unit cost are editable. |
| Renumber/code manager | PARTIAL | Shared manager edits and checks codes individually; batch renumber is deferred. |
| Labels/callouts | IMPLEMENTED | TTREFNOTELABEL and TTUPDATEREFNOTELABELS use project note identity; labels excluded from quantities. |
| Work Area filtering | IMPLEMENTED | Reference schedules can use explicit Work Area assignment. |
| Cost support | IMPLEMENTED | Project unit cost and derived subtotal are scheduled. |

## Measurement

| Capability | Status | Notes |
|---|---|---|
| LINE and LWPOLYLINE length | IMPLEMENTED | Open, closed, straight, and bulged segments are supported. |
| Closed polyline area | IMPLEMENTED | Positive, negative, and mixed bulges are supported. |
| Perimeter | IMPLEMENTED | TTLENGTH returns closed boundary perimeter, including bulges; no separate command required. |
| Arc length | IMPLEMENTED | ARC and LWPOLYLINE arc segments use pure geometry. |
| Volume from area/depth | IMPLEMENTED | Drawing-unit result. |
| Bearing/distance | IMPLEMENTED | `TTBEARINGDIST` reports distance and clockwise-from-north azimuth. |
| Central unit conversion | IMPLEMENTED | One unit module serves spacing, site conversion, and irrigation lengths. |

## Grading Helpers

| Capability | Status | Notes |
|---|---|---|
| Two-point percentage slope | IMPLEMENTED | User-entered elevations. |
| Rise and run | IMPLEMENTED | Printed with percentage. |
| Ratio slope | IMPLEMENTED | Horizontal-to-vertical ratio is reported with percent slope. |
| Elevation difference | IMPLEMENTED | Rise is printed. |
| Spot elevation label | IMPLEMENTED | Ordinary TEXT. |
| Surface model | LT-LIMITED | No Civil 3D surface API. |

## Concept Graphics

| Capability | Status | Notes |
|---|---|---|
| Smart concept polygon | IMPLEMENTED | Named closed LWPOLYLINE. |
| Concept area report | PARTIAL | Area measurement exists; a dedicated multi-zone concept schedule is deferred. |
| Concept categories/styles | MISSING | Deferred concept presentation scope; named smart concept zones remain available. |
| Reversible presentation fills | MISSING | Deferred visual treatment; semantic boundaries remain ordinary editable polylines. |

## Details

| Capability | Status | Notes |
|---|---|---|
| Project detail records | IMPLEMENTED | Number, title, notes, template. |
| Original detail placement | PARTIAL | Generated original demo frame works; importing and arranging source DWG detail artwork is deferred pending GUI-safe insertion workflow. |
| Callouts and renumber update | IMPLEMENTED | Derived TEXT updates. |
| Detail index | IMPLEMENTED | Derived MTEXT. |
| Categories and keywords | IMPLEMENTED | Details manager searches title, number, category and keywords. |
| Source-file detection | IMPLEMENTED | Verification reports missing optional source DWGs. |
| Office/user libraries | IMPLEMENTED | Shared validated user library supports Save/Add/Import/Export; project copies receive new identity. |
| Duplicate-number verification | IMPLEMENTED | Add refuses duplicates and Verify reports persisted conflicts. |

## Lighting

| Capability | Status | Notes |
|---|---|---|
| Master and Project Fixture Palette | IMPLEMENTED | Fictional sample records. |
| Palette add/edit/remove | IMPLEMENTED | Numbered selection. |
| Fixture placement and replacement | IMPLEMENTED | Smart INSERT identity. |
| Wire and transformer graphics | IMPLEMENTED | Smart LINE/INSERT. |
| Circuit assignment and load | IMPLEMENTED | Connected watt total. |
| Match/count/highlight | IMPLEMENTED | TTMATCHFIXTURE, TTCOUNTLIGHTING and selected-record manager highlighting. |
| Transformer capacity verification | IMPLEMENTED | Circuit load is compared with assigned transformer capacity. |
| Voltage drop | IMPLEMENTED | Transparent copper two-conductor estimate supports common AWG sizes. |
| Schedule and cost | IMPLEMENTED | Derived fixture totals. |

## Irrigation Database

| Capability | Status | Notes |
|---|---|---|
| Schema-checked equipment catalog | IMPLEMENTED | Eight fictional records and one pipe class. |
| Project irrigation palette | IMPLEMENTED | Add/list. |
| Broad professional categories | PARTIAL | Eight fictional categories exist. Body/nozzle assemblies and further equipment-specific behavior are deferred pending suitable source data. |
| Manufacturer data import | MISSING | Source blocked: no licensed manufacturer dataset or stable adapter specification supplied. Generic user library exchange is available. |
| User equipment library | IMPLEMENTED | Irrigation manager Library uses validated separate user storage and project-owned copies. |
| Provenance/license fields | PARTIAL | Unknown record fields are retained in library copies; no standardized manufacturer provenance importer exists. |
| Multiple pipe classes | IMPLEMENTED | TTPIPECLASSES stores project classes with material, C and nominal:inside size pairs; legacy catalog IDs normalized on read. |

## Irrigation Placement

| Capability | Status | Notes |
|---|---|---|
| Equipment placement | IMPLEMENTED | Smart generated INSERT. |
| Mainline and lateral LINE | IMPLEMENTED | Directed smart pipe. |
| Drip line | IMPLEMENTED | Existing LINE/LWPOLYLINE attachment. |
| Coverage circle | IMPLEMENTED | Derived helper CIRCLE. |
| Rotation and arc coverage | IMPLEMENTED | TTIRRIGATIONCOVERAGE stores radius/sweep and uses head rotation for full-circle or ARC output. |
| Drip area | IMPLEMENTED | TTDRIPAREA derives demand from area/row spacing/emitter spacing/flow; rerun on untagged edited boundary to recalculate. |
| Coverage update | IMPLEMENTED | TTUPDATECOVERAGE recreates graphics from head metadata, deleting old graphics only after replacement succeeds. |
| Sleeve placement | IMPLEMENTED | Catalog equipment INSERT. |

## Pipe Networks

| Capability | Status | Notes |
|---|---|---|
| Directed start-to-end edges | IMPLEMENTED | LINE group 10 to 11. |
| Endpoint tolerance | IMPLEMENTED | Unit-aware default 3.048 mm converted to drawing units, with explicit project override. |
| Branch traversal | IMPLEMENTED | Operation-local directed graph aggregates downstream TO-node demand. |
| Disconnected equipment | IMPLEMENTED | Endpoint connection check. |
| Loop detection | IMPLEMENTED | Leaf elimination detects directed cycles; automatic pressure/sizing refuses ambiguous topology. |
| Merged-path ambiguity | IMPLEMENTED | Multiple incoming edges are counted and stop sizing/path output. |
| Reverse-direction detection | IMPLEMENTED | Orphan/reversed branch and pipe-into-source diagnostics; TTREVERSEPIPE explicitly reverses LINE endpoints. |
| Cached network graph | IMPLEMENTED | One operation-local graph is reused for flow/pressure/sizing; no stale persistent drawing graph cache. |

## Flow Analysis

| Capability | Status | Notes |
|---|---|---|
| Station demand | IMPLEMENTED | Sum of explicit flow fields. |
| Per-pipe downstream demand | IMPLEMENTED | Analyzer, sizing, and selected paths use each edge's downstream demand. |
| Branch flows | IMPLEMENTED | Directed graph downstream accumulation; branches retain distinct demand. |
| Zero-demand pipes | IMPLEMENTED | Valid zero result. |
| Ambiguous topology refusal | IMPLEMENTED | Sizing and selected critical path stop on loops, merges, or unresolved units. |
| Flow persistence | IMPLEMENTED | Derived, not stored as authority. |

## Hydraulics

| Capability | Status | Notes |
|---|---|---|
| Hazen-Williams | IMPLEMENTED | Pure function, US customary. |
| Velocity | IMPLEMENTED | Pure function. |
| Friction and total loss | IMPLEMENTED | Elevation/equipment inputs supported. |
| Invalid-input guards | IMPLEMENTED | Numeric and positive constraints. |
| Metric calculations | IMPLEMENTED | TTHYDRAULICMETRIC converts SI input into the same US-customary core and converts results back. |
| Node pressures | IMPLEMENTED | Pressure propagation includes friction, elevation, inline losses and terminal requirements; automatic critical route reported. |
| Transparent documentation | IMPLEMENTED | Formula and assumptions documented. |

## Pipe Sizing

| Capability | Status | Notes |
|---|---|---|
| Available-size recommendation | IMPLEMENTED | Smallest passing size. |
| Velocity and loss criteria | IMPLEMENTED | User-entered positive limits; defaults 5 ft/s and 5 psi friction per pipe. |
| Per-pipe downstream sizing | IMPLEMENTED | Each graph edge uses downstream TO demand and actual inside diameter. |
| Manual override protection | IMPLEMENTED | Only MANUAL_SIZE=0 pipes are changed; TTPIPEAUTO explicitly changes size-control mode. |
| Highlight undersized/excessive velocity | IMPLEMENTED | Sizing highlights failing/undersized pipes; no claim of complete design compliance. |
| Batch station sizing | IMPLEMENTED | Recommend, Single, Selection, Station and Network scopes; manual sizes retained. |

## Valves / Stations

| Capability | Status | Notes |
|---|---|---|
| Station assignment | IMPLEMENTED | Batch selection writes XData. |
| Zone flow and pipe count | IMPLEMENTED | Derived report. |
| Station highlight | IMPLEMENTED | Transient redraw. |
| Valve-to-station model | PARTIAL | Valves share station name links; dedicated valve IDs and one-valve constraints are deferred. |
| Zone pressure | IMPLEMENTED | TTAUTOCRITICALPATH prints node available pressure and margin for valid station trees. |
| Zone verification | PARTIAL | Graph detects topology defects; comprehensive controller-to-placed-valve validation remains deferred. |

## Controllers

| Capability | Status | Notes |
|---|---|---|
| Controller placement | IMPLEMENTED | Generic equipment record. |
| Controller assignment | IMPLEMENTED | Station records reference controller names and outputs; renames are refused until references are explicitly reassigned. |
| Station capacity | IMPLEMENTED | Controller capacity guards station output and capacity edits. |
| Duplicate station check | IMPLEMENTED | Unique station names and controller output assignment checked on manager save. |

## Drip

| Capability | Status | Notes |
|---|---|---|
| Point emitter equipment | IMPLEMENTED | Fictional drip record. |
| Drip LINE/LWPOLYLINE | IMPLEMENTED | Explicit total flow and station. |
| Drip area | IMPLEMENTED | TTDRIPAREA derives demand from area/row spacing/emitter spacing/flow; rerun on untagged edited boundary to recalculate. |
| Emitter-spacing calculations | IMPLEMENTED | Drip area count uses ceiling(area/(row spacing * emitter spacing)); gph converted to gpm. |

## Coverage

| Capability | Status | Notes |
|---|---|---|
| Full-circle helper | IMPLEMENTED | Smart nonplot CIRCLE. |
| Radius from equipment data | IMPLEMENTED | Optional RADIUS_FT converts to drawing units; absent radius prompts explicitly. |
| Partial arcs | IMPLEMENTED | Coverage sweep 0<angle<=360 persists in XData. |
| Coverage refresh | IMPLEMENTED | Head UUID links helpers; refresh uses current head point/rotation and stored radius/sweep. |

## Irrigation Schedules

| Capability | Status | Notes |
|---|---|---|
| Equipment summary | IMPLEMENTED | Derived quantities and total flow. |
| Pipe rows | IMPLEMENTED | Type, length, diameter. |
| Station filtering | IMPLEMENTED | Equipment schedule scope retains station name in its project schedule record. |
| Work Area filtering | IMPLEMENTED | Equipment schedules retain explicit Work Area scope and regenerate it. |
| Configurable columns/style | PARTIAL | Plant style engine is configurable; equipment schedules retain fixed engineering columns. |
| Existing schedule update | IMPLEMENTED | TTUPDATEEQUIPMENTSCHEDULE resolves stored scope and regenerates current quantities. |

## Runtime / Water Calculations

| Capability | Status | Notes |
|---|---|---|
| Area-depth-volume runtime | IMPLEMENTED | Uses 0.623 gal/sf/in. |
| Zone flow integration | IMPLEMENTED | Current station demand. |
| Precipitation-rate helper | MISSING | Deferred agronomic helper; nozzle distribution/overlap data is not modeled. |
| Metric runtime | MISSING | Deferred adapter for watering helper; metric pipe hydraulics is available. |

## Work Areas

| Capability | Status | Notes |
|---|---|---|
| Creation and stable IDs | IMPLEMENTED | Closed smart boundary plus project record. |
| Batch assignment | IMPLEMENTED | Explicit XData assignment. |
| Info and area | IMPLEMENTED | Current geometry. |
| Rename | IMPLEMENTED | Manager edits the external Work Area record. |
| Delete with dependency checks | IMPLEMENTED | Assigned objects block deletion; failed storage restores the boundary. |
| Highlight and counts | IMPLEMENTED | Manager reports assignments and transiently highlights boundary and objects. |
| Cross-module filtering | IMPLEMENTED | Plants, reference notes and equipment schedules filter explicit Work Area links. |
| Geometric assignment helper | MISSING | Deferred inference: Work Areas use explicit assignment and active placement context. |

## Office Standards

| Capability | Status | Notes |
|---|---|---|
| Project preferences | IMPLEMENTED | Additive project section. |
| TerraTools defaults | IMPLEMENTED | Default layers and general settings. |
| User standard | IMPLEMENTED | Validated roaming user standard is separate from project data. |
| Project override | IMPLEMENTED | Project preference values. |
| Import/export | IMPLEMENTED | Validated S-expression exchange preserves preference schema. |
| Irrigation/lighting/detail defaults | PARTIAL | Module roles and record-level settings exist; centralized office engineering defaults are not yet exposed. |

## Layer Standards

| Capability | Status | Notes |
|---|---|---|
| Logical role mapping | IMPLEMENTED | Original six roles preserved; additive module roles and alias names resolve without migrating old preferences. |
| Create missing layers | IMPLEMENTED | Existing layers are preserved. |
| Color, linetype, plot intent | IMPLEMENTED | Stored per role. |
| Lineweight | MISSING | Deferred office graphics preference; AutoCAD layer settings remain editable normally. |
| Module-specific roles | PARTIAL | New manager/pipe/coverage/schedule paths use dedicated roles; some legacy annotation/graphics commands still use existing layers. |
| Import/export | PARTIAL | Office standard exchange includes layer mappings; no layer-only format. |

## Annotation Standards

| Capability | Status | Notes |
|---|---|---|
| Text height | IMPLEMENTED | Project preference. |
| Numeric precision | IMPLEMENTED | Project preference. |
| Text style management | MISSING | Deferred style selector; output uses existing STANDARD style. |
| Label style definitions | IMPLEMENTED | Plant label preferences integrate with output and office-standard export/import. |
| Scale-aware paper sizing | PARTIAL | Scale exists but most commands do not apply it. |

## Schedule Standards

| Capability | Status | Notes |
|---|---|---|
| LT-compatible MTEXT schedules | IMPLEMENTED | No TABLE dependency. |
| Schedule layer | IMPLEMENTED | Logical role. |
| Reusable column/style definitions | PARTIAL | Plant schedules support reusable definitions; full cross-module configurable rendering is deferred. |
| Office schedule standards | IMPLEMENTED | Plant schedule style is part of exported/imported preferences. |

## Block / Symbol Management

| Capability | Status | Notes |
|---|---|---|
| Generate original simple blocks | IMPLEMENTED | CIRCLE, square, triangle families. |
| Preserve user blocks | IMPLEMENTED | Existing block definitions are reused. |
| Symbol validation | PARTIAL | Plant verification checks existence. |
| Cross-module symbol catalog | MISSING | Deferred library UX; block names remain on project records. |
| Preview and substitution manager | PARTIAL | Global metadata substitution, no visual manager. |

## Import / Export

| Capability | Status | Notes |
|---|---|---|
| Plant schedule CSV export | IMPLEMENTED | Quoted fields. |
| Plant-code palette CSV import | IMPLEMENTED | Header-aware parser accepts quoted Code fields and skips unknown/duplicates. |
| Full CSV quoting/parser | IMPLEMENTED | Shared parser handles commas, escaped quotes, blanks, headers and quoted physical newlines; malformed quoting rejected. |
| Lighting/irrigation CSV | MISSING | Deferred adapters; validated S-expression library exchange is the supported record format. |
| Reference note CSV | MISSING | Deferred adapter; project storage and derived schedule remain available. |
| Office standard exchange | IMPLEMENTED | Standards use validated S-expression import/export. |

## Project Portability

| Capability | Status | Notes |
|---|---|---|
| Relative installation resources | IMPLEMENTED | Loader root. |
| Relative project association | PARTIAL | Relative hint is stored; exact absolute association is authoritative. Reopen moved projects explicitly. |
| Missing-path reporting | IMPLEMENTED | No silent search/adoption. |
| Project package/resources | IMPLEMENTED | New-folder manifest package copies selected resources; packaged detail links become relative. Unselected links remain unchanged. |
| WBLOCK reassociation | PARTIAL | TTADOPT resolves plants/fixtures/equipment only; labels, mixes, pipes and dependent objects are conservatively refused. |
| Xref mutation | LT-LIMITED | Referenced content is treated as read-only. |

## Search / Filtering

| Capability | Status | Notes |
|---|---|---|
| Category filtering | IMPLEMENTED | Master plant Add workflow. |
| Partial-name search | IMPLEMENTED | All query words match a compact uppercase text index. |
| Multi-field plant filters | PARTIAL | Text, category, and favorites work; numeric/range filters are absent. |
| Work Area schedule filter | IMPLEMENTED | Plant schedule and cost. |
| Station filter | IMPLEMENTED | Analysis, sizing, highlight and persistent equipment-schedule scope. |
| Pagination | IMPLEMENTED | DCL pages contain 30 records; CLI pages contain 20. WFO broad searches cap displayed matches. |

## Favorites / Recent Items

| Capability | Status | Notes |
|---|---|---|
| Plant favorites | IMPLEMENTED | Project stores stable Master Plant IDs. |
| Symbol favorites | MISSING | Deferred symbol-library convenience; project block assignments persist. |
| Recent plants | IMPLEMENTED | Plant Manager Recent Plants resolves the stored last 20 source IDs; unavailable sources are omitted. |
| Recent projects | MISSING | Deferred convenience: no recent-project list; explicit Open remains available. |

## Error Checking / Reconciliation / Recovery

| Capability | Status | Notes |
|---|---|---|
| Duplicate UUID repair | IMPLEMENTED | New UUID only; semantic identity retained. |
| Malformed XData count | IMPLEMENTED | Raw filtered count vs parsed count. |
| Unknown module/object type | IMPLEMENTED | Known lists. |
| Missing project UUID | IMPLEMENTED | Reported. |
| Cross-module orphan records | PARTIAL | Plant/lighting checks are deeper than Site/Details. |
| Failed storage recovery | IMPLEMENTED | Staging and backup restoration. |
| Foreign-project reassociation | PARTIAL | TTADOPT validates supported catalog IDs and replaces entity UUID; dependent composite objects remain unsupported. |

## Performance

| Capability | Status | Notes |
|---|---|---|
| XData-filtered drawing scan | IMPLEMENTED | Global smart scans filter by app. |
| Targeted selection for edits | IMPLEMENTED | Entity-first edit commands. |
| Shared scan per report | PARTIAL | Some nested helpers rescan the drawing. |
| Large catalog index | IMPLEMENTED | WFO token-prefix shards and lazy record lookup; startup does not parse 435,702 full records. |
| 1k/5k/10k test fixtures | IMPLEMENTED | tools/benchmark.lsp creates disposable fixtures, measures and removes only its own objects, including error cleanup. |

## UI / UX

| Capability | Status | Notes |
|---|---|---|
| Main DCL launcher | IMPLEMENTED | Grouped Home with project/units/Work Area/database context, workflow task choosers and command-line fallback; GUI review pending. |
| Consistent numbered choices | IMPLEMENTED | Shared prompt helper. |
| Searchable plant manager DCL | IMPLEMENTED | Project Plants/Search Plant Library/Favorites/Recent; actual database banner, SAMPLE labels, session state, mode guards and Tools tasks. GUI acceptance pending. |
| Module manager dialogs | IMPLEMENTED | Shared record manager covers Work Areas, Reference Notes, Details, Lighting, Irrigation, Stations and Controllers. GUI acceptance pending. |
| Quiet cancellation | PARTIAL | Many commands are quiet; behavior varies. |
| Internal IDs hidden | IMPLEMENTED | Ordinary workflows use numbers/entities. |

## Documentation / Help

| Capability | Status | Notes |
|---|---|---|
| README, architecture, data, hydraulics guides | IMPLEMENTED | User, developer, architecture, model, formula, provenance, and release-readiness docs exist. |
| In-product `TTHELP` | IMPLEMENTED | Module topics list primary workflows and commands. |
| End-to-end acceptance tests | IMPLEMENTED | 80 engineering plus 15 UX scenarios cover workflows, data safety, managers, graphs and visual/interaction risks. |
| Formula documentation | IMPLEMENTED | Hazen-Williams and runtime assumptions. |
| Workflow-oriented user guide | IMPLEMENTED | Current project-to-production workflows and limits are documented. |

## Data Provenance / Open-Source Readiness

| Capability | Status | Notes |
|---|---|---|
| Original fictional sample records | IMPLEMENTED | No claimed manufacturer or horticultural authority. |
| Per-dataset provenance file | IMPLEMENTED | Root data-source file covers bundled and importable resources. |
| Third-party license inventory | IMPLEMENTED | Optional WFO CC0 package has source manifest and checksums; no manufacturer or plant image data bundled. |
| CONTRIBUTING guide | IMPLEMENTED | Runtime, data, review, and compatibility rules are documented. |
| Architecture document | IMPLEMENTED | Runtime, data hierarchy, project, XData, search, and irrigation boundaries are recorded. |
| Software license decision | IMPLEMENTED | MIT License selected in root LICENSE; third-party datasets retain separate terms. |

## Installation / Updating / Migration / Testing

| Capability | Status | Notes |
|---|---|---|
| Support-path and trusted-location instructions | IMPLEMENTED | README. |
| Exact-root reload | IMPLEMENTED | `TTRELOAD`. |
| Optional startup loading | IMPLEMENTED | README documents AutoCAD LT's trusted APPLOAD Startup Suite workflow. |
| Read-only smoke test | IMPLEMENTED | `TTDEVSMOKE`. |
| Pure deterministic QA suite | IMPLEMENTED | `TTQACHECK` covers units, geometry, density, CSV, and hydraulics without drawing edits. |
| Schema migration framework | IMPLEMENTED | Explicit current-schema identity boundary preserves unknown fields and refuses unsupported schemas; no invented legacy migrations. |
| Real LT acceptance status | PARTIAL | LT 2027 Core Console regressions/QA pass; GUI, secure loading, Undo, multiple open drawings and LT 2024-2026 acceptance remain unrun. |

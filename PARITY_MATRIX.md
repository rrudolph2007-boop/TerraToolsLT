# TerraTools LT Capability Matrix

Status definitions: **IMPLEMENTED** means integrated production code exists. **PARTIAL** means a useful subset exists but the workflow is incomplete. **MISSING** means no working implementation exists. **LT-LIMITED** means AutoCAD LT prevents or materially constrains a dependable equivalent. This matrix describes the repository, not runtime verification.

Final parity-sprint review for `0.10.0-rc1`. New sprint code has static review only and still requires the AutoCAD LT acceptance suite.

## Project Management

| Capability | Status | Notes |
|---|---|---|
| Create, open, close project | IMPLEMENTED | External project file and command workflow. |
| Persistent DWG association | IMPLEMENTED | Named Object Dictionary XData. |
| Missing project detection | IMPLEMENTED | Association remains unresolved without fabricating data. |
| UUID mismatch detection | IMPLEMENTED | External record must match drawing association. |
| Safe write and backup | IMPLEMENTED | Staging and `.bak` replacement. |
| Project migration log | MISSING | Schema remains version 1. |
| Project archive/package | MISSING | No resource packager. |
| Recent projects | MISSING | No recent-project list. |

## Plant Database

| Capability | Status | Notes |
|---|---|---|
| Schema-validated master catalog | IMPLEMENTED | Current catalog has 15 fictional sample records. |
| Normalized professional record model | IMPLEMENTED | External schema supports taxonomy, cultural, size, use, and provenance fields without requiring them. |
| Tens-of-thousands record support | PARTIAL | One-time full parse builds a compact session index; large-catalog LT timing is pending. |
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
| Duplicate protection | IMPLEMENTED | One Master Plant per project palette. |
| Search before add | IMPLEMENTED | Multi-word indexed search with category/favorite filter and pagination. |
| Favorites and recent plants | PARTIAL | Favorites have a search workflow; recent stable IDs are stored, but there is no recent-items browser yet. |
| Batch edit | MISSING | One record at a time. |
| Duplicate code validation | MISSING | IDs are validated; codes are not. |
| User plant link | IMPLEMENTED | User and attached normalized IDs resolve through the same Master lookup. |

## Plant Symbols

| Capability | Status | Notes |
|---|---|---|
| Original generated tree/shrub/groundcover symbols | IMPLEMENTED | Simple block definitions. |
| Per-project symbol override | IMPLEMENTED | Stored on project plant record. |
| Shared symbol families | IMPLEMENTED | Multiple records may use the same block. |
| User block assignment | IMPLEMENTED | Project symbol field accepts a block name. |
| Symbol scale controls | PARTIAL | Controlled random placement scale exists; no project symbol-scale manager. |
| Symbol preview | MISSING | No preview DCL. |
| Symbol favorites/categories | MISSING | No symbol catalog metadata. |
| Missing-symbol verification/recovery | PARTIAL | Verification reports missing blocks; recreation is indirect. |

## Plant Placement

| Capability | Status | Notes |
|---|---|---|
| Single and continuous placement | IMPLEMENTED | Repeated point loop. |
| Straight-line fixed spacing | IMPLEMENTED | `TTPLANTLINE`. |
| Rectangular array | IMPLEMENTED | `TTPLANTARRAY`. |
| Naturalistic scatter | PARTIAL | Rectangular controlled scatter exists without polygon containment. |
| Along polyline or arc | IMPLEMENTED | LINE, ARC, and bulged LWPOLYLINE paths use authoritative geometry. |
| Equal spacing on path | IMPLEMENTED | Open and closed paths distribute requested counts without duplicate endpoints. |
| Fill closed region | MISSING | No containment sampler. |
| Random rotation and scale | IMPLEMENTED | User-entered scale and rotation ranges are applied to each INSERT. |
| Work Area at placement | PARTIAL | Assignment is a later batch operation. |

## Plant Editing

| Capability | Status | Notes |
|---|---|---|
| Replace selected plant | IMPLEMENTED | Position, transform, UUID, and Work Area remain. |
| Match selected plants | IMPLEMENTED | Source identity applies to targets. |
| Highlight and locate | IMPLEMENTED | Transient highlight and zoom. |
| Select similar | PARTIAL | Highlight exists; selection-set return is absent. |
| Count project | IMPLEMENTED | Counts project plant identities. |
| Count selected | MISSING | No selection-scoped counter. |
| Count Work Area | PARTIAL | Internal filters exist; no focused count command. |
| Batch replace | IMPLEMENTED | Match works on a selected set. |

## Plant Areas

| Capability | Status | Notes |
|---|---|---|
| Closed LWPOLYLINE areas | IMPLEMENTED | Current straight and curved geometry is live. |
| Curved/bulged boundaries | IMPLEMENTED | Signed circular-segment correction handles positive, negative, and mixed bulges. |
| Square spacing | IMPLEMENTED | Derived from current geometry. |
| Triangular spacing | IMPLEMENTED | Uses 0.8660254 cell factor. |
| Explicit spacing units | IMPLEMENTED | Inches, feet, millimeters, centimeters, and meters convert to drawing units. |
| Density-based quantity | MISSING | Spacing only. |
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
| Common/botanical-name fields | MISSING | Fixed quantity and code text. |
| Configurable label styles | MISSING | Text height and layer only. |
| Optional leader geometry | MISSING | TEXT only. |
| Update after code edit | IMPLEMENTED | Refresh resolves current project code. |

## Plant Schedules

| Capability | Status | Notes |
|---|---|---|
| Derived MTEXT schedule | IMPLEMENTED | Ordinary LT entity. |
| Individual and area quantities | IMPLEMENTED | Mix components included. |
| Work Area filtering | IMPLEMENTED | Explicit assignment filter. |
| Schedule update | IMPLEMENTED | Existing entity text is replaced. |
| Configurable columns | MISSING | Fixed column set. |
| Sort and grouping choices | MISSING | Palette order only. |
| Reusable schedule style | MISSING | Width and headings are fixed. |
| Multiple independent schedules | IMPLEMENTED | Each stores its own Work Area filter. |

## Plant Costing

| Capability | Status | Notes |
|---|---|---|
| Unit cost and subtotal | IMPLEMENTED | Project-specific copied costs. |
| Category totals | IMPLEMENTED | Printed summary. |
| Work Area totals | IMPLEMENTED | Explicit scope prompt. |
| Project total | IMPLEMENTED | Derived current total. |
| Cost CSV | IMPLEMENTED | Schedule export includes costs. |
| Cost escalation/alternates | MISSING | No estimating model beyond unit cost. |

## Plant Verification

| Capability | Status | Notes |
|---|---|---|
| Duplicate UUID detection | IMPLEMENTED | Global reconciliation scan. |
| Missing project plant references | IMPLEMENTED | Palette references checked. |
| Missing symbols | IMPLEMENTED | Block table check. |
| Invalid Work Areas | IMPLEMENTED | Explicit IDs checked. |
| Invalid labels | IMPLEMENTED | Project label record lookup. |
| Duplicate plant codes | MISSING | Not checked. |
| Foreign project UUID | IMPLEMENTED | Global verification compares entity and active project UUIDs. |

## Plant Presentation

| Capability | Status | Notes |
|---|---|---|
| Temporary species highlight | IMPLEMENTED | `TTHIGHLIGHTPLANT`. |
| Category/species colorization | MISSING | No reversible presentation state. |
| Canopy display modes | MISSING | One generated symbol per assigned block. |
| Groundcover graphic treatment | PARTIAL | Boundary layer assignment only. |

## Site / Reference Notes

| Capability | Status | Notes |
|---|---|---|
| Count, length, area, volume notes | IMPLEMENTED | Derived from selected geometry. |
| Notation and amenity notes | IMPLEMENTED | Count-like records. |
| Materials and hardscape categories | IMPLEMENTED | Dedicated reference-note types are available. |
| Note editing | IMPLEMENTED | Code, description, and project unit cost are editable. |
| Renumber/code manager | PARTIAL | Individual codes can be edited; batch renumbering is absent. |
| Labels/callouts | MISSING | Schedule only. |
| Work Area filtering | IMPLEMENTED | Reference schedules can use explicit Work Area assignment. |
| Cost support | IMPLEMENTED | Project unit cost and derived subtotal are scheduled. |

## Measurement

| Capability | Status | Notes |
|---|---|---|
| LINE and LWPOLYLINE length | IMPLEMENTED | Open, closed, straight, and bulged segments are supported. |
| Closed polyline area | IMPLEMENTED | Positive, negative, and mixed bulges are supported. |
| Perimeter | PARTIAL | Length command covers it without explicit label. |
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
| Concept area report | PARTIAL | General area command. |
| Concept categories/styles | MISSING | One object type. |
| Reversible presentation fills | MISSING | No hatch/color state. |

## Details

| Capability | Status | Notes |
|---|---|---|
| Project detail records | IMPLEMENTED | Number, title, notes, template. |
| Original detail placement | IMPLEMENTED | Generated demo frame. |
| Callouts and renumber update | IMPLEMENTED | Derived TEXT updates. |
| Detail index | IMPLEMENTED | Derived MTEXT. |
| Categories and keywords | PARTIAL | Metadata can be stored and edited; dedicated search UI is absent. |
| Source-file detection | IMPLEMENTED | Verification reports missing optional source DWGs. |
| Office/user libraries | MISSING | Project library only. |
| Duplicate-number verification | IMPLEMENTED | Add refuses duplicates and Verify reports persisted conflicts. |

## Lighting

| Capability | Status | Notes |
|---|---|---|
| Master and Project Fixture Palette | IMPLEMENTED | Fictional sample records. |
| Palette add/edit/remove | IMPLEMENTED | Numbered selection. |
| Fixture placement and replacement | IMPLEMENTED | Smart INSERT identity. |
| Wire and transformer graphics | IMPLEMENTED | Smart LINE/INSERT. |
| Circuit assignment and load | IMPLEMENTED | Connected watt total. |
| Match/count/highlight | MISSING | Global tools only. |
| Transformer capacity verification | IMPLEMENTED | Circuit load is compared with assigned transformer capacity. |
| Voltage drop | IMPLEMENTED | Transparent copper two-conductor estimate supports common AWG sizes. |
| Schedule and cost | IMPLEMENTED | Derived fixture totals. |

## Irrigation Database

| Capability | Status | Notes |
|---|---|---|
| Schema-checked equipment catalog | IMPLEMENTED | Eight fictional records and one pipe class. |
| Project irrigation palette | IMPLEMENTED | Add/list. |
| Broad professional categories | PARTIAL | Core heads, drip, valve, controller, POC, regulator, sleeve. |
| Manufacturer data import | MISSING | No adapter. |
| User equipment library | MISSING | Distributed catalog only. |
| Provenance/license fields | PARTIAL | Fictional samples are documented; equipment import schema remains limited. |
| Multiple pipe classes | PARTIAL | Model allows lists; sample has one. |

## Irrigation Placement

| Capability | Status | Notes |
|---|---|---|
| Equipment placement | IMPLEMENTED | Smart generated INSERT. |
| Mainline and lateral LINE | IMPLEMENTED | Directed smart pipe. |
| Drip line | IMPLEMENTED | Existing LINE/LWPOLYLINE attachment. |
| Coverage circle | IMPLEMENTED | Derived helper CIRCLE. |
| Rotation and arc coverage | MISSING | Fixed block rotation and full circle. |
| Drip area | MISSING | Drip line only. |
| Coverage update | MISSING | Recreate manually. |
| Sleeve placement | IMPLEMENTED | Catalog equipment INSERT. |

## Pipe Networks

| Capability | Status | Notes |
|---|---|---|
| Directed start-to-end edges | IMPLEMENTED | LINE group 10 to 11. |
| Endpoint tolerance | IMPLEMENTED | Fixed 0.01 drawing unit. |
| Branch traversal | IMPLEMENTED | Recursive downstream scan. |
| Disconnected equipment | IMPLEMENTED | Endpoint connection check. |
| Loop detection | IMPLEMENTED | Revisited UUID reports ambiguity. |
| Merged-path ambiguity | IMPLEMENTED | Multiple incoming edges are counted and stop sizing/path output. |
| Reverse-direction detection | MISSING | Direction is assumed from drawing order. |
| Cached network graph | MISSING | Repeated list scans. |

## Flow Analysis

| Capability | Status | Notes |
|---|---|---|
| Station demand | IMPLEMENTED | Sum of explicit flow fields. |
| Per-pipe downstream demand | IMPLEMENTED | Analyzer, sizing, and selected paths use each edge's downstream demand. |
| Branch flows | IMPLEMENTED | Recursive downstream accumulation. |
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
| Metric calculations | MISSING | US customary only. |
| Node pressures | MISSING | Path aggregate only. |
| Transparent documentation | IMPLEMENTED | Formula and assumptions documented. |

## Pipe Sizing

| Capability | Status | Notes |
|---|---|---|
| Available-size recommendation | IMPLEMENTED | Smallest passing size. |
| Velocity and loss criteria | IMPLEMENTED | Command defaults fixed at 5. |
| Per-pipe downstream sizing | IMPLEMENTED | Selected smart pipe is sized from its recursive downstream demand. |
| Manual override protection | IMPLEMENTED | Explicit confirmation required. |
| Highlight undersized/excessive velocity | MISSING | No drawing report. |
| Batch station sizing | MISSING | One pipe at a time. |

## Valves / Stations

| Capability | Status | Notes |
|---|---|---|
| Station assignment | IMPLEMENTED | Batch selection writes XData. |
| Zone flow and pipe count | IMPLEMENTED | Derived report. |
| Station highlight | IMPLEMENTED | Transient redraw. |
| Valve-to-station model | PARTIAL | Shared station string only. |
| Zone pressure | PARTIAL | Manual path analysis. |
| Zone verification | PARTIAL | General irrigation verifier. |

## Controllers

| Capability | Status | Notes |
|---|---|---|
| Controller placement | IMPLEMENTED | Generic equipment record. |
| Controller assignment | PARTIAL | Station string can be attached. |
| Station capacity | MISSING | No controller capacity model. |
| Duplicate station check | MISSING | No controller-specific validation. |

## Drip

| Capability | Status | Notes |
|---|---|---|
| Point emitter equipment | IMPLEMENTED | Fictional drip record. |
| Drip LINE/LWPOLYLINE | IMPLEMENTED | Explicit total flow and station. |
| Drip area | MISSING | No area demand model. |
| Emitter-spacing calculations | MISSING | Total flow is user-entered. |

## Coverage

| Capability | Status | Notes |
|---|---|---|
| Full-circle helper | IMPLEMENTED | Smart nonplot CIRCLE. |
| Radius from equipment data | MISSING | User enters radius. |
| Partial arcs | MISSING | No ARC coverage. |
| Coverage refresh | MISSING | No update command. |

## Irrigation Schedules

| Capability | Status | Notes |
|---|---|---|
| Equipment summary | IMPLEMENTED | Derived quantities and total flow. |
| Pipe rows | IMPLEMENTED | Type, length, diameter. |
| Station filtering | MISSING | Whole drawing only. |
| Work Area filtering | MISSING | Whole drawing only. |
| Configurable columns/style | MISSING | Fixed MTEXT. |
| Existing schedule update | MISSING | Creation only. |

## Runtime / Water Calculations

| Capability | Status | Notes |
|---|---|---|
| Area-depth-volume runtime | IMPLEMENTED | Uses 0.623 gal/sf/in. |
| Zone flow integration | IMPLEMENTED | Current station demand. |
| Precipitation-rate helper | MISSING | No arc/radius/nozzle model. |
| Metric runtime | MISSING | US customary only. |

## Work Areas

| Capability | Status | Notes |
|---|---|---|
| Creation and stable IDs | IMPLEMENTED | Closed smart boundary plus project record. |
| Batch assignment | IMPLEMENTED | Explicit XData assignment. |
| Info and area | IMPLEMENTED | Current geometry. |
| Rename | IMPLEMENTED | Manager edits the external Work Area record. |
| Delete with dependency checks | IMPLEMENTED | Assigned objects block deletion; failed storage restores the boundary. |
| Highlight and counts | IMPLEMENTED | Manager reports assignments and transiently highlights boundary and objects. |
| Cross-module filtering | PARTIAL | Plant schedule/cost only. |
| Geometric assignment helper | MISSING | Explicit assignment only. |

## Office Standards

| Capability | Status | Notes |
|---|---|---|
| Project preferences | IMPLEMENTED | Additive project section. |
| TerraTools defaults | IMPLEMENTED | Default layers and general settings. |
| User standard | IMPLEMENTED | Validated roaming user standard is separate from project data. |
| Project override | IMPLEMENTED | Project preference values. |
| Import/export | IMPLEMENTED | Validated S-expression exchange preserves preference schema. |
| Irrigation/lighting/detail defaults | MISSING | General settings only. |

## Layer Standards

| Capability | Status | Notes |
|---|---|---|
| Logical role mapping | IMPLEMENTED | Six planting/helper roles. |
| Create missing layers | IMPLEMENTED | Existing layers are preserved. |
| Color, linetype, plot intent | IMPLEMENTED | Stored per role. |
| Lineweight | MISSING | No lineweight field. |
| Module-specific roles | MISSING | Site, lighting, irrigation share helper layers. |
| Import/export | PARTIAL | Office standard exchange includes layer mappings; no layer-only format. |

## Annotation Standards

| Capability | Status | Notes |
|---|---|---|
| Text height | IMPLEMENTED | Project preference. |
| Numeric precision | IMPLEMENTED | Project preference. |
| Text style management | MISSING | Hard-coded STANDARD. |
| Label style definitions | MISSING | No reusable style records. |
| Scale-aware paper sizing | PARTIAL | Scale exists but most commands do not apply it. |

## Schedule Standards

| Capability | Status | Notes |
|---|---|---|
| LT-compatible MTEXT schedules | IMPLEMENTED | No TABLE dependency. |
| Schedule layer | IMPLEMENTED | Logical role. |
| Reusable column/style definitions | MISSING | Fixed strings. |
| Office schedule standards | MISSING | No user standard. |

## Block / Symbol Management

| Capability | Status | Notes |
|---|---|---|
| Generate original simple blocks | IMPLEMENTED | CIRCLE, square, triangle families. |
| Preserve user blocks | IMPLEMENTED | Existing block definitions are reused. |
| Symbol validation | PARTIAL | Plant verification checks existence. |
| Cross-module symbol catalog | MISSING | Names live on records. |
| Preview and substitution manager | PARTIAL | Global metadata substitution, no visual manager. |

## Import / Export

| Capability | Status | Notes |
|---|---|---|
| Plant schedule CSV export | IMPLEMENTED | Quoted fields. |
| Plant-code palette CSV import | IMPLEMENTED | Header-aware parser accepts quoted Code fields and skips unknown/duplicates. |
| Full CSV quoting/parser | PARTIAL | Commas, quotes, blanks, and headers work; quoted physical newlines are unsupported. |
| Lighting/irrigation CSV | MISSING | No adapters. |
| Reference note CSV | MISSING | No adapter. |
| Office standard exchange | IMPLEMENTED | Standards use validated S-expression import/export. |

## Project Portability

| Capability | Status | Notes |
|---|---|---|
| Relative installation resources | IMPLEMENTED | Loader root. |
| Relative project association | IMPLEMENTED | Stored alongside absolute path. |
| Missing-path reporting | IMPLEMENTED | No silent search/adoption. |
| Project package/resources | MISSING | No copier or manifest. |
| WBLOCK reassociation | PARTIAL | Foreign project UUIDs are reported; safe guided reassociation is absent. |
| Xref mutation | LT-LIMITED | Referenced content is treated as read-only. |

## Search / Filtering

| Capability | Status | Notes |
|---|---|---|
| Category filtering | IMPLEMENTED | Master plant Add workflow. |
| Partial-name search | IMPLEMENTED | All query words match a compact uppercase text index. |
| Multi-field plant filters | PARTIAL | Text, category, and favorites work; numeric/range filters are absent. |
| Work Area schedule filter | IMPLEMENTED | Plant schedule and cost. |
| Station filter | PARTIAL | Analysis/highlight only. |
| Pagination | IMPLEMENTED | Search pages are limited to 20 results. |

## Favorites / Recent Items

| Capability | Status | Notes |
|---|---|---|
| Plant favorites | IMPLEMENTED | Project stores stable Master Plant IDs. |
| Symbol favorites | MISSING | No storage. |
| Recent plants | PARTIAL | The last 20 added stable IDs are stored; a recent-items browser is still missing. |
| Recent projects | MISSING | No storage. |

## Error Checking / Reconciliation / Recovery

| Capability | Status | Notes |
|---|---|---|
| Duplicate UUID repair | IMPLEMENTED | New UUID only; semantic identity retained. |
| Malformed XData count | IMPLEMENTED | Raw filtered count vs parsed count. |
| Unknown module/object type | IMPLEMENTED | Known lists. |
| Missing project UUID | IMPLEMENTED | Reported. |
| Cross-module orphan records | PARTIAL | Plant/lighting checks are deeper than Site/Details. |
| Failed storage recovery | IMPLEMENTED | Staging and backup restoration. |
| Foreign-project reassociation | MISSING | No guided workflow. |

## Performance

| Capability | Status | Notes |
|---|---|---|
| XData-filtered drawing scan | IMPLEMENTED | Global smart scans filter by app. |
| Targeted selection for edits | IMPLEMENTED | Entity-first edit commands. |
| Shared scan per report | PARTIAL | Some nested helpers rescan the drawing. |
| Large catalog index | PARTIAL | Compact session index avoids repeat full-record search; first parse remains whole-file. |
| 1k/5k/10k test fixtures | MISSING | No deterministic benchmark. |

## UI / UX

| Capability | Status | Notes |
|---|---|---|
| Main DCL launcher | IMPLEMENTED | Command-line fallback. |
| Consistent numbered choices | IMPLEMENTED | Shared prompt helper. |
| Searchable plant manager DCL | MISSING | Command-line category workflow. |
| Module manager dialogs | MISSING | Launcher delegates to commands. |
| Quiet cancellation | PARTIAL | Many commands are quiet; behavior varies. |
| Internal IDs hidden | IMPLEMENTED | Ordinary workflows use numbers/entities. |

## Documentation / Help

| Capability | Status | Notes |
|---|---|---|
| README, architecture, data, hydraulics guides | IMPLEMENTED | User, developer, architecture, model, formula, provenance, and release-readiness docs exist. |
| In-product `TTHELP` | IMPLEMENTED | Module topics list primary workflows and commands. |
| End-to-end acceptance tests | IMPLEMENTED | 48 release-candidate scenarios. |
| Formula documentation | IMPLEMENTED | Hazen-Williams and runtime assumptions. |
| Workflow-oriented user guide | IMPLEMENTED | Current project-to-production workflows and limits are documented. |

## Data Provenance / Open-Source Readiness

| Capability | Status | Notes |
|---|---|---|
| Original fictional sample records | IMPLEMENTED | No claimed manufacturer or horticultural authority. |
| Per-dataset provenance file | IMPLEMENTED | Root data-source file covers bundled and importable resources. |
| Third-party license inventory | IMPLEMENTED | No third-party dataset is bundled; USDA import terms and image exclusion are recorded. |
| CONTRIBUTING guide | IMPLEMENTED | Runtime, data, review, and compatibility rules are documented. |
| Architecture document | IMPLEMENTED | Runtime, data hierarchy, project, XData, search, and irrigation boundaries are recorded. |
| Software license decision | MISSING | Must be chosen before public release. |

## Installation / Updating / Migration / Testing

| Capability | Status | Notes |
|---|---|---|
| Support-path and trusted-location instructions | IMPLEMENTED | README. |
| Exact-root reload | IMPLEMENTED | `TTRELOAD`. |
| Optional startup loading | IMPLEMENTED | README documents AutoCAD LT's trusted APPLOAD Startup Suite workflow. |
| Read-only smoke test | IMPLEMENTED | `TTDEVSMOKE`. |
| Pure deterministic QA suite | IMPLEMENTED | `TTQACHECK` covers units, geometry, density, CSV, and hydraulics without drawing edits. |
| Schema migration framework | MISSING | Additive schema 1 only. |
| Real LT acceptance status | PARTIAL | Earlier foundation passed; release-candidate modules remain untested. |

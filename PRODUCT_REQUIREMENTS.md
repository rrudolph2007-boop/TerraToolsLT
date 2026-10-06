# TerraTools LT — Product Requirements

## 1. Purpose

TerraTools LT is a professional landscape architecture CAD production platform designed specifically for AutoCAD LT 2024+ on Windows.

Its purpose is to bring advanced landscape architecture production workflows to users who work in AutoCAD LT without requiring full AutoCAD, Civil 3D, proprietary custom-object runtimes, or external database services.

TerraTools should eventually provide a professional workflow spanning:

- project management
- planting design
- plant data
- site/reference notes
- landscape details
- landscape lighting
- irrigation design and analysis
- Work Areas
- labels
- schedules
- quantities
- costing
- office standards
- diagnostics
- project portability

The product should be powerful enough for serious production while remaining transparent, user-owned, and open-source-ready.

---

# 2. Product Positioning

TerraTools LT should be positioned as:

**An LT-native professional landscape architecture CAD productivity platform inspired by the workflow depth expected from mature landscape design software.**

It should not be presented as a literal clone of Land F/X or any other proprietary product.

TerraTools should independently implement professional workflow classes while developing its own:

- architecture
- terminology
- interface
- symbols
- data model
- graphics
- documentation
- open-data strategy

---

# 3. Product Principles

TerraTools should prioritize:

1. correctness
2. reliability
3. user-owned data
4. ease of use
5. professional workflow speed
6. transparency
7. open provenance
8. professional visual quality
9. extensibility
10. breadth

A large feature list is not useful if workflows are unreliable or unpleasant.

---

# 4. Target User

Primary users include:

- landscape architects
- landscape designers
- planting designers
- irrigation designers
- landscape architecture students
- small design offices
- professionals working primarily in AutoCAD LT

Users should not need software-development knowledge.

Normal workflows should not require knowledge of:

- AutoLISP
- XData
- UUIDs
- internal schemas
- project file structures

---

# 5. Target Platform

Required production environment:

**AutoCAD LT 2024+ on Windows**

TerraTools should use capabilities legitimately available in AutoCAD LT.

Normal runtime should not require:

- full AutoCAD
- Civil 3D
- Revit
- .NET plugins
- ObjectARX
- VBA
- Python
- Node.js
- database servers
- cloud services

The application should remain primarily local and offline-capable.

---

# 6. Open-Source / Clean-Room Requirement

TerraTools should be suitable for future open-source publication.

The repository must avoid proprietary contamination.

Do not copy:

- commercial plugin source
- commercial databases
- proprietary CAD libraries
- proprietary details
- commercial screenshots
- copied UI artwork
- copied icons
- copied documentation
- copyrighted commercial plant descriptions
- copyrighted plant photographs without compatible rights

General workflow concepts may be independently reproduced.

---

# 7. User Experience Requirement

Ease of use is a product requirement, not a polish phase.

Major routine workflows should be:

- discoverable
- searchable
- visually organized
- efficient
- consistent
- easy to cancel
- easy to Undo
- forgiving of ordinary mistakes

Common production workflows should minimize unnecessary prompts.

Where reliable in AutoCAD LT, professional DCL managers should be used instead of forcing users through long command-line sequences.

Command-line entry points should remain available where valuable.

---

# 8. Visual Design Requirement

TerraTools should have a cohesive original visual identity.

The application should feel:

- professional
- calm
- architectural
- precise
- coherent
- restrained

All major DCL managers should share conventions for:

- titles
- spacing
- action placement
- search fields
- list dimensions
- status text
- buttons
- empty states

Generated CAD output should also appear intentional and professional.

---

# 9. Main Application Hub

Command:

`TT`

should act as the primary application entry point.

The main UI should provide access to areas such as:

- Project
- Planting
- Site
- Details
- Lighting
- Irrigation
- Schedules
- Work Areas
- Standards
- Data
- Diagnostics
- Help

It should display useful project context such as:

- TerraTools version
- active project
- project status

---

# 10. Project Management

TerraTools projects should use an external authoritative project file associated with a DWG.

Project information should support concepts such as:

- project UUID
- project number
- project name
- client
- designer
- description
- units
- drawing scale
- created date
- schema/version

Required workflows:

- Create Project
- Open Project
- Close Project
- Project Info
- persistent DWG association
- missing project detection
- project backup
- migration
- recovery

TerraTools should never silently fabricate a missing project file.

---

# 11. Project Data Ownership

Project-specific design decisions belong to the project.

Project Palette records must remain valid even if the original source database later disappears.

This applies particularly to:

- project plants
- lighting fixtures
- irrigation equipment
- detail records where relevant

External source data provides provenance and reusable defaults.

Project records provide project authority.

---

# 12. Schema Migration

Project data should support controlled evolution.

Future versions should be able to open supported older project schemas.

Migrations should be:

- explicit
- validated
- backed up
- deterministic
- recoverable

A software update should not silently corrupt an older project.

---

# 13. Office Standards

TerraTools should support a hierarchy:

**TerraTools Defaults → User/Office Standard → Project Override**

Standards should eventually control areas such as:

- units
- drawing scale
- annotation height
- precision
- currency
- layer mappings
- colors
- linetypes
- lineweights where supported
- text styles
- label styles
- schedule styles
- plant defaults
- irrigation criteria
- network tolerance
- pipe-sizing criteria
- lighting defaults
- detail defaults

---

# 14. Work Areas

Work Areas should provide explicit project scoping.

Required concepts:

- stable Work Area identity
- boundary
- name
- area
- explicit smart-object assignment

Required workflows should include:

- create
- rename
- delete
- highlight
- assign
- unassign
- count
- inspect
- module summaries

Deletion should be dependency-aware.

Work Area assignment should remain authoritative rather than relying solely on spatial coincidence.

---

# 15. Professional Plant Database Requirement

TerraTools should operate against a professional-scale plant database.

Target where legally and technically achievable:

**50,000+ legitimate searchable plant/taxon records**

A production-scale plant database should not be simulated with fabricated content.

The product should support actual large-data workflows rather than merely theoretical scalability.

---

# 16. Plant Data Sources

Preferred plant-data sources include:

- public-domain government botanical data
- permissively licensed botanical datasets
- user-provided datasets

Source provenance must remain visible.

Each external data source should track:

- source name
- source ID
- source URL
- version/date
- licensing
- attribution
- redistribution status

---

# 17. Plant Database Reproducibility

The production plant database should be reproducibly buildable where practical.

A documented data pipeline should conceptually follow:

Raw Source  
→ Source Adapter  
→ Normalization  
→ Taxonomic Matching / Deduplication  
→ Description Generation  
→ Validation  
→ Search Index  
→ Database Manifest

The project should record source versions and build versions.

---

# 18. Plant Record Model

The normalized model should support fields where source data legitimately provides them.

Potential fields include:

- Plant ID
- accepted taxon ID
- source
- source ID
- scientific name
- accepted scientific name
- genus
- species
- subspecies
- variety
- form
- cultivar
- trade name
- common name
- common names
- family
- synonyms
- growth habit
- duration
- evergreen/deciduous
- native status
- native regions
- distribution
- hardiness
- water use
- sun
- shade tolerance
- soil information
- moisture
- mature height
- mature width
- growth rate
- bloom season
- bloom color
- foliage color
- fall color
- fruit characteristics
- wildlife value
- landscape uses
- wetland status
- project/design category
- source provenance

Unavailable information should remain unavailable.

It should never be invented merely to make a record appear complete.

---

# 19. Plant Descriptions

TerraTools should provide useful original descriptions at database scale.

Generated descriptions must remain separate from sourced facts.

Descriptions should be based on legitimate structured data.

Potential generated fields:

- generated description
- generated design notes
- description generation version
- fields used to generate description
- completeness/confidence category

Generated text must not pretend to be source-provided text.

---

# 20. Plant Description Quality

Descriptions should be concise and useful to landscape designers.

They may summarize available facts such as:

- growth habit
- mature size
- evergreen/deciduous
- native region
- sun exposure
- water use
- bloom information
- documented landscape-use fields

No unsupported factual claim should be invented.

A sparse record should receive a sparse description.

---

# 21. Plant Data Completeness

Plant records should expose a useful completeness concept.

Possible categories:

- TAXONOMY_ONLY
- BASIC
- ENRICHED

Completeness represents data availability, not scientific certainty.

---

# 22. Plant Search

Professional-scale plant data requires professional search.

Users should be able to search or filter by appropriate available fields such as:

- scientific name
- common name
- genus
- species
- cultivar
- synonym
- family
- category
- source
- native region
- hardiness
- water
- sun
- mature size
- favorites

The interface should support:

- paging
- recent plants
- favorites
- project-used plants
- selected-record details
- provenance
- generated description

Exact plant names should rank more strongly than generic description text.

---

# 23. User Plant Library

Users should have a custom plant library separate from distributed plant data.

Required long-term workflows:

- Add
- Edit
- Remove
- Duplicate
- Search
- Import
- Export

User plants must survive application and distributed database updates.

---

# 24. Project Plant Palette

Plants used in a project should be copied into a Project Plant Palette.

Project Plant records should support project-specific overrides such as:

- plant code
- size
- spacing
- unit cost
- symbol
- notes
- design category

Edits to Project Plant records must not modify distributed master data.

Project Plant identities should remain stable.

---

# 25. Plant Symbols

TerraTools should include an original lightweight symbol system.

Target families should include useful generic design types such as:

- deciduous tree
- evergreen tree
- ornamental tree
- multi-stem tree
- generic palm
- large shrub
- medium shrub
- small shrub
- ornamental grass
- perennial
- groundcover

Users should also be able to assign their own blocks.

The system should support:

- scale
- rotation
- random rotation where appropriate
- random scale where appropriate
- substitution
- missing-symbol verification
- preview where feasible

---

# 26. Plant Placement

Required professional planting workflows should include:

- single placement
- continuous placement
- fixed-spacing line
- equal-spacing line
- LINE path
- ARC path
- bulged LWPOLYLINE path
- closed path
- rectangular array
- row/grid placement
- naturalistic scatter
- closed-polygon fill

Placement operations should be easy to repeat and Undo.

---

# 27. Plant Editing

Required workflows should include:

- Info
- Select Similar
- Count Selected
- Count Drawing
- Count Work Area
- Highlight
- Locate
- Replace
- Batch Replace
- Match Plant
- Change Symbol
- Assign Work Area
- Remove Work Area
- Inspect Source

---

# 28. Plant Areas

Smart planting areas should support:

- closed curved boundaries
- square spacing
- triangular spacing
- density-based calculation
- explicit unit spacing
- live derived quantity
- Work Area assignment

Boundary editing should update quantities without recreating the smart object.

---

# 29. Plant Mixes

TerraTools should support reusable plant mixes.

Required concepts:

- multiple project plants
- percentage mode
- ratio mode
- density where appropriate
- stable mix identity
- editing
- duplication
- dependency-aware deletion

Derived mix schedule quantities should remain transparent.

---

# 30. Plant Labels

Plant labels should be derived from current project records and placed-instance identity.

Configurable label styles should support combinations of:

- quantity
- code
- botanical name
- common name
- size
- spacing

Target workflows:

- single label
- group label
- leader
- style
- refresh/update
- orphan detection

---

# 31. Plant Schedules

Plant schedules should be derived rather than manually maintained.

Target functionality:

- configurable columns
- column order
- headers
- sorting
- grouping
- Work Area filter
- category filter
- costs
- update/regeneration

Relevant columns may include:

- Code
- Botanical Name
- Common Name
- Quantity
- Size
- Spacing
- Category
- Notes
- Unit Cost
- Subtotal
- Work Area

---

# 32. Plant Costing

Project-specific plant costs should support:

- unit cost
- subtotals
- category totals
- Work Area totals
- project totals
- CSV export

Bundled/sample costs must be clearly identified as examples rather than current pricing.

---

# 33. Plant Presentation

TerraTools should support reversible presentation tools such as:

- species highlighting
- category highlighting
- temporary colorization
- canopy helpers
- plant-mass graphics

Presentation tools should not corrupt semantic object data.

---

# 34. Site / Reference Notes

TerraTools should support smart site/reference-note workflows.

Categories should include concepts such as:

- notation
- count
- length
- area
- volume
- material
- hardscape
- amenity
- custom

Target workflows:

- Add
- Edit
- Remove
- Duplicate
- Search
- Renumber
- Assign Geometry
- Label/Callout
- Work Area
- Cost
- Schedule

---

# 35. Site Measurement Helpers

TerraTools should support reliable LT-native measurement tools for:

- area
- length
- perimeter
- arc length
- volume
- bearing
- distance
- coordinates
- slope percent
- slope ratio
- rise/run
- spot elevations
- unit conversion

The product should not pretend AutoCAD LT provides Civil 3D surface analysis.

---

# 36. Concept Graphics

Concept-area workflows should eventually support:

- named zones
- categories
- area
- style
- labels
- schedule
- Work Area
- reversible visual treatment where practical

---

# 37. Detail Management

TerraTools should support:

**Distributed Original Details → User Detail Library → Project Detail Set**

Detail records should support concepts such as:

- detail ID
- number
- title
- category
- keywords
- notes
- source path
- scale
- revision
- status

Target workflows:

- Search
- Filter
- Add
- Edit
- Remove
- Duplicate
- Import
- Place
- Callout
- Cross-reference
- Renumber
- Index
- Verify
- Relink
- Locate

Do not bundle proprietary commercial details.

---

# 38. Lighting

TerraTools should support professional landscape-lighting production workflows.

Lighting data should support concepts such as:

- fixture ID
- manufacturer/source
- model
- code
- description
- type
- wattage
- VA
- voltage
- lamp type
- color temperature
- beam
- unit cost
- symbol
- notes

Distributed samples should remain clearly fictional unless real data has documented redistribution rights.

---

# 39. Lighting Workflow

Target workflows:

- Fixture Manager
- Project Fixture Palette
- Place Fixture
- Replace Fixture
- Match Fixture
- Count
- Highlight
- Wire
- Transformer
- Circuit
- Circuit Assignment
- Circuit Info
- Load
- Transformer Capacity
- Voltage Drop
- Schedule
- Verification

TerraTools should not claim electrical-code compliance.

---

# 40. Irrigation Product Goal

Irrigation should become one of TerraTools' strongest technical systems.

It should provide transparent, defensible network-analysis workflows suitable for landscape irrigation design assistance within AutoCAD LT limitations.

It must prioritize correctness over producing an answer.

---

# 41. Irrigation Database

The irrigation data architecture should support categories such as:

- spray bodies
- nozzles
- spray assemblies
- rotors
- bubblers
- drip emitters
- dripline
- valves
- master valves
- controllers
- sensors
- backflow
- points of connection
- filters
- regulators
- quick couplers
- sleeves
- mainline pipe
- lateral pipe
- pipe classes

Real manufacturer data should only be bundled when redistribution rights are clear.

---

# 42. Irrigation Graphics

TerraTools should provide original lightweight symbols for common irrigation objects.

Coverage graphics should be derived and updateable where feasible.

---

# 43. Irrigation Network Graph

Irrigation networks should be modeled internally as graphs during analysis.

The graph should represent:

- nodes
- directed pipe edges
- incoming edges
- outgoing edges
- connected demand
- station
- source
- valve
- pipe metadata

It should detect:

- branching
- terminals
- loops
- merges
- disconnected demand
- orphan pipes
- reversed/suspicious direction
- multiple sources

---

# 44. Irrigation Connectivity

Connectivity tolerance must be unit-aware or project-configurable.

A fixed drawing-unit tolerance is insufficient across imperial and metric projects.

---

# 45. Irrigation Downstream Flow

Every pipe should derive its own actual downstream flow.

Do not use total station flow for every edge.

Derived flow should support branched systems.

Ambiguous topology must be identified rather than silently guessed.

---

# 46. Pipe Classes

Pipe-class data should support:

- material
- class
- Hazen-Williams C factor
- nominal diameter
- actual inside diameter

Hydraulics should use actual inside diameter when available.

---

# 47. Hydraulic Calculations

TerraTools should provide transparent hydraulic calculations including:

- Hazen-Williams friction
- velocity
- friction loss
- elevation pressure effect
- equipment losses where provided
- pressure margin

Formulas and assumptions must be documented.

Invalid inputs must be rejected.

---

# 48. Node Pressure

For valid directed networks, TerraTools should eventually propagate available pressure through the network and identify terminal pressure deficits.

---

# 49. Automatic Critical Path

For a valid unambiguous directed network:

TerraTools should determine source-to-terminal paths and identify the path requiring the greatest source pressure.

A critical-path report should be able to communicate:

- segment flow
- pipe size
- velocity
- friction
- elevation effect
- equipment loss
- required terminal pressure
- source requirement
- available pressure
- pressure margin

For ambiguous topology, TerraTools should refuse automatic certainty and provide an assisted workflow instead.

---

# 50. Irrigation Pipe Sizing

TerraTools should support:

- Recommend Size
- Apply Single
- Apply Selection
- Apply Station
- Apply Network

Sizing criteria should support:

- maximum velocity
- maximum friction loss
- pipe class
- available sizes

Manual overrides should be respected.

---

# 51. Stations and Controllers

TerraTools should provide managers for stations/zones and controllers.

Station concepts should include:

- ID
- name
- valve
- controller
- derived flow
- design flow
- status

Controller concepts should include:

- station capacity
- assigned stations
- connected valves
- notes

Verification should detect obvious assignment errors.

---

# 52. Drip

TerraTools should support:

- dripline
- drip area
- flow per length
- flow per area
- emitter flow
- emitter spacing

Demand should be derived when enough design data exists.

Manual flow override should remain available.

---

# 53. Irrigation Schedules

TerraTools should provide updateable derived schedules for appropriate irrigation categories.

Filters should support concepts such as:

- station
- Work Area
- equipment category

---

# 54. Watering / Runtime

TerraTools may provide transparent helpers for:

- zone flow
- area
- application depth
- runtime
- precipitation rate where sufficient data exists

Assumptions must be visible.

Do not present agronomic recommendations as guaranteed prescriptions.

---

# 55. Shared Schedule Architecture

Schedules across modules should use a reusable shared architecture where feasible.

Schedules should support:

- title
- columns
- rows
- sorting
- filtering
- update metadata
- consistent appearance

AutoCAD LT reliability is more important than sophisticated table entities.

MTEXT or ordinary entities are acceptable when they provide more reliable LT behavior.

---

# 56. Import / Export

TerraTools should support appropriate import/export workflows for:

- plant data
- project plant palette
- user plants
- reference notes
- lighting
- irrigation
- cost data
- office standards

Formats should be documented and validated.

Imports should never silently overwrite stable identity.

---

# 57. Project Packaging

TerraTools should eventually support project packaging.

A package may include:

- project data
- manifest
- selected attached plant catalogs
- selected detail resources

External resources should only be copied deliberately.

Packages should be validated and protected from unsafe paths.

---

# 58. Foreign Project Objects

TerraTools should detect smart objects originating from another project.

The user should be able to:

- inspect
- leave foreign
- safely adopt where dependencies can be resolved

TerraTools must not simply rewrite `PROJECT_UUID` while leaving broken catalog references.

---

# 59. Xrefs

Referenced drawing content should be treated as read-only.

TerraTools should clearly distinguish between limitations caused by Xrefs and normal smart objects.

---

# 60. Verification and Diagnostics

TerraTools should provide powerful diagnostics.

Long-term verification should cover:

- smart-object metadata
- UUID duplication
- project mismatch
- missing records
- unavailable sources
- missing blocks
- invalid Work Areas
- labels
- schedules
- details
- lighting
- irrigation
- schema
- data manifest

Fix operations should only repair unambiguous problems.

---

# 61. Performance

TerraTools should remain useful on substantial professional drawings.

Architecture should avoid unnecessary repeated global scans.

Target benchmark scenarios should eventually include:

- 1,000 smart objects
- 5,000 smart objects
- 10,000 smart objects

Plant-search architecture should remain practical with 50,000+ records.

Application startup should not require eagerly parsing the entire production plant database.

---

# 62. Multi-Drawing Reliability

TerraTools should behave correctly when users switch among multiple open drawings and projects.

Project A data must not silently leak into Project B.

Project-specific cached/default state must be isolated or correctly refreshed.

---

# 63. Coordinate Systems

Geometry calculations must account for or explicitly reject unsupported:

- UCS
- WCS
- OCS
- entity elevation
- extrusion direction

The product must never knowingly return incorrect area/length values solely because the geometry is oriented differently than expected.

---

# 64. Units

TerraTools should support professional imperial and metric drawing workflows.

Target linear units:

- inches
- feet
- millimeters
- centimeters
- meters

Unit-sensitive engineering calculations should stop when units cannot be resolved.

---

# 65. Offline Operation

Normal TerraTools CAD workflows should work offline once required local data is installed.

No hidden network dependency should be required for:

- project loading
- plant placement
- schedules
- lighting
- irrigation
- diagnostics

Database updates may use explicit external tooling or user actions.

---

# 66. Privacy

TerraTools should not include hidden telemetry.

Project and drawing data should remain private to the user's environment unless a future explicit user-controlled feature intentionally transmits it.

---

# 67. Documentation

The product should maintain:

- `README.md`
- `ROADMAP.md`
- `PARITY_MATRIX.md`
- `ACCEPTANCE_TESTS.md`
- `ARCHITECTURE.md`
- `CHANGELOG.md`
- `RELEASE_CHECKLIST.md`
- `DATA_SOURCES.md`
- `LICENSE_NOTES.md`
- `CONTRIBUTING.md`
- `docs/USER_GUIDE.md`
- `docs/DEVELOPER_GUIDE.md`
- `docs/DATA_MODEL.md`
- `docs/PLANT_DATABASE.md`
- `docs/HYDRAULICS.md`

Documentation must remain consistent with actual implementation.

---

# 68. Parity Matrix

`PARITY_MATRIX.md` is the implementation truth table.

Statuses should be conservative.

A feature should not be marked IMPLEMENTED simply because some supporting code exists.

Remaining limitations should be explicit.

---

# 69. Acceptance Testing

`ACCEPTANCE_TESTS.md` is the real AutoCAD LT release gate.

Tests should cover complete workflows rather than only functions.

High-value scenarios should include:

- loading
- project persistence
- migration
- recovery
- database search
- source-independent project records
- placement
- copy/reconciliation
- curved geometry
- labels
- schedules
- Work Areas
- site notes
- details
- lighting
- irrigation graph analysis
- sizing
- critical path
- save/reopen
- malformed input
- cancellation
- multi-drawing isolation
- performance

---

# 70. Release Candidates

Do not call TerraTools `1.0` merely because a large amount of code exists.

Release candidates should remain prerelease versions until:

- major acceptance scenarios pass in real AutoCAD LT
- critical data workflows are proven
- migration/recovery are proven
- UI workflows are usable
- serious known correctness issues are resolved

---

# 71. Definition of Professional Completion

A capability is professionally complete when:

1. working production code exists
2. it is loaded and integrated
3. required data persists
4. cancellation/errors are handled
5. the normal workflow is usable
6. interface quality is acceptable
7. documentation is accurate
8. relevant acceptance coverage exists
9. dependencies and provenance are known

A stub, architecture, button, or documentation section alone is not completion.

---

# 72. Long-Term Product Objective

TerraTools LT should become an original professional landscape architecture production platform with:

- professional project management
- large-scale open plant data
- useful generated plant descriptions
- advanced planting
- smart labels
- smart schedules
- site/reference-note production
- detail management
- landscape-lighting tools
- irrigation equipment management
- network graph analysis
- per-pipe flow
- hydraulic calculations
- pressure analysis
- automatic critical path where topology permits
- pipe sizing
- stations/controllers
- Work Areas
- office standards
- import/export
- project portability
- migration/recovery
- professional DCL managers
- coherent original CAD graphics
- strong diagnostics
- transparent data provenance
- user-owned project data
- offline-friendly operation

The product should push AutoCAD LT as far as its supported architecture responsibly allows.

Correctness and reliability remain more important than superficial parity.
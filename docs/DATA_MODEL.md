# TerraTools LT Data Model

TerraTools uses four levels of data:

1. A Master Catalog contains shared source records with stable catalog IDs.
2. A Project Palette copies selected catalog records into `terratools-project.dat` and gives project records their own stable IDs where needed.
3. A placed smart instance is an ordinary DWG entity with lightweight TERRATOOLS XData.
4. Labels, schedules, counts, costs, and reports are derived views.

The project file is one AutoLISP S-expression headed by `TERRATOOLS_PROJECT`. Required schema-version 1 fields remain unchanged. Optional additive keys include `PREFERENCES`, `PLANT_PALETTE`, `PLANT_MIXES`, `PLANT_LABELS`, `PLANT_FAVORITES`, `PLANT_RECENT`, `PLANT_DATA_PATHS`, `WORK_AREAS`, `REFERENCE_NOTES`, `DETAIL_LIBRARY`, `LIGHTING_PALETTE`, and `IRRIGATION_PALETTE`. Unknown keys survive updates because project changes replace only the requested keyed section.

Plant source data can be distributed `PLANT_RECORD` data, a separate user library, or external `NORMALIZED_PLANT` records. A normalized record has stable source identity and optional taxonomy, names, family, habit, hardiness, water, sun, soil, mature size, region, distribution, bloom, foliage, growth, uses, wetland, production defaults, URL, license, attribution, date, and notes. Empty source fields stay empty.

TERRATOOLS entity XData schema 1 starts with `TT_ENTITY`, followed by the schema number and key/value pairs. Core fields are `entity_uuid`, `project_uuid`, `module`, `object_type`, `catalog_id`, and `work_area_id`. Lighting and irrigation add small operational values such as circuit, station, flow, diameter, C factor, capacity, and manual-size status. Project and catalog records are never copied into XData.

The current drawing association is TERRATOOLS XData on the Named Object Dictionary. It contains the project UUID, absolute project path, and a relative path when the drawing location permits one. Project load verifies that the external file is readable, validates it, and confirms its UUID. Missing files and UUID mismatches do not create replacement data.

Normal AutoCAD COPY may duplicate XData. `TTRECONCILE` gives later copies new entity UUIDs while retaining their project and catalog meaning. Entity handles and block names have no identity role.

In 0.12.0-rc1, PROJECT_PLANT_ID and case-insensitive PLANT_CODE are unique per palette save. MASTER_PLANT_ID is provenance and may repeat across deliberate variants. Existing conflicting codes remain readable so users can repair them. Source absence never invalidates an otherwise complete project copy.

Other additive project sections include IRRIGATION_STATIONS, IRRIGATION_CONTROLLERS, PIPE_CLASSES and EQUIPMENT_SCHEDULES. Pipe metadata separates DIAMETER_IN (nominal), INSIDE_DIAMETER, PIPE_CLASS, MATERIAL and C_FACTOR. Legacy DIAMETER_IN remains the fallback when actual ID is absent. COVERAGE_SWEEP and PRESSURE_PSI are serialized operational XData fields. Coverage is derived from its head UUID, radius and sweep.

Generated plant content is separate from source facts. The optional WFO package uses stable WFO IDs and identifies every generated description as TAXONOMY_ONLY with generation metadata. Manifest counts describe accepted records separately from aliases. This package is not embedded in the project or DWG.

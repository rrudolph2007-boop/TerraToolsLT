# TerraTools LT Data Model

TerraTools uses four levels of data:

1. A Master Catalog contains shared source records with stable catalog IDs.
2. A Project Palette copies selected catalog records into `terratools-project.dat` and gives project records their own stable IDs where needed.
3. A placed smart instance is an ordinary DWG entity with lightweight TERRATOOLS XData.
4. Labels, schedules, counts, costs, and reports are derived views.

The project file is one AutoLISP S-expression headed by `TERRATOOLS_PROJECT`. Required schema-version 1 fields remain unchanged. Optional additive keys include `PREFERENCES`, `PLANT_PALETTE`, `PLANT_MIXES`, `PLANT_LABELS`, `WORK_AREAS`, `REFERENCE_NOTES`, `DETAIL_LIBRARY`, `LIGHTING_PALETTE`, and `IRRIGATION_PALETTE`. Unknown keys survive updates because project changes replace only the requested keyed section.

TERRATOOLS entity XData schema 1 starts with `TT_ENTITY`, followed by the schema number and key/value pairs. Core fields are `entity_uuid`, `project_uuid`, `module`, `object_type`, `catalog_id`, and `work_area_id`. Lighting and irrigation add small operational values such as circuit, station, flow, diameter, C factor, capacity, and manual-size status. Project and catalog records are never copied into XData.

The current drawing association is TERRATOOLS XData on the Named Object Dictionary. It contains the project UUID, absolute project path, and a relative path when the drawing location permits one. Project load verifies that the external file is readable, validates it, and confirms its UUID. Missing files and UUID mismatches do not create replacement data.

Normal AutoCAD COPY may duplicate XData. `TTRECONCILE` gives later copies new entity UUIDs while retaining their project and catalog meaning. Entity handles and block names have no identity role.

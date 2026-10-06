# TerraTools LT Architecture

TerraTools LT is an AutoLISP and DCL application for AutoCAD LT 2024+ on Windows. `TerraTools.lsp` resolves every module from its own installation folder and loads them in dependency order. Runtime code uses DXF entity data, standard AutoCAD commands, XData, and local text files. It has no managed-code, COM, database-server, Python, or Node.js runtime requirement.

The data flow is:

1. Open master data and user libraries provide stable source records.
2. A project palette stores editable project copies and project identities.
3. A placed object is an ordinary DWG entity with lightweight TERRATOOLS XData.
4. Labels, schedules, quantities, costs, and reports are rebuilt from project records and current geometry.

The external `terratools-project.dat` file is authoritative for project records. A drawing-level association on the Named Object Dictionary stores only the project UUID and path information. Loading verifies the file, schema, and UUID before marking a project active.

Core modules own storage, identity, units, geometry, standards, reconciliation, QA, help, and UI. Product modules own their records and CAD workflows. Calculation functions are kept separate from prompts and entity changes where practical. Changes to a project section preserve unknown keys.

TERRATOOLS XData schema 1 stores compact typed key/value pairs. Entity UUIDs identify instances. Project UUIDs expose copied or foreign objects. Catalog IDs connect instances to project records. Work Area IDs provide explicit scope. Block names only select graphics.

Normal AutoCAD COPY duplicates XData. `TTRECONCILE` repairs duplicate entity UUIDs and preserves semantic links. Xrefs are treated as read-only. Foreign project UUIDs are reported by `TTVERIFY`; automatic reassociation is withheld because catalog and project identities may not be compatible.

The plant data system has four layers: distributed sample master data, a user library under the current Windows roaming application-data folder, optional normalized external catalogs attached to a project, and the Project Plant Palette. Search builds a compact in-memory uppercase index once per session and pages results. Reloading or changing attached/user data invalidates it.

The irrigation model treats LINE start points as upstream and end points as downstream. Flow is derived recursively for each pipe. Loops and merged incoming paths are reported as ambiguous. Sizing and selected critical-path calculations stop when topology or drawing units cannot be resolved.

AutoCAD LT runtime acceptance remains required. Static checks cannot prove DCL behavior, command localization, SECURELOAD configuration, or all entity-database edge cases.

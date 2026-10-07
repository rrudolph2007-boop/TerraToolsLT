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

Normal AutoCAD COPY duplicates XData. `TTRECONCILE` sorts an operation-local scan, repairs duplicate entity UUIDs and preserves semantic links. Xrefs are treated as read-only. `TTVERIFY` reports foreign project UUIDs. Explicit `TTADOPT` accepts only supported plants, fixtures and equipment whose project record IDs resolve; dependent composite objects are refused. Adoption clears circuit/station assignments and unresolved Work Area links.

The plant data system separates distributed samples, the optional WFO production package, a roaming user library, explicitly attached normalized catalogs, and project-owned copies. WFO uses token-prefix index shards and lazy ID record shards. It is not parsed at startup. Small attached/user catalogs retain a session search index invalidated when their context changes. Project palette validation uses its own stored fields; absent sources affect provenance status only. PROJECT_PLANT_ID and case-insensitive PLANT_CODE must be unique on every save. MASTER_PLANT_ID may repeat for project variants.

The irrigation model treats LINE start points as upstream and end points as downstream. An operation-local directed graph computes each edge's downstream TO-node demand. Loops, merges, multiple sources and disconnected demand block automatic engineering output. Pressure propagation includes elevation and inline losses; the lowest terminal pressure margin identifies the automatic critical route. Pipe classes retain nominal and actual inside diameters separately. Sizing uses actual ID and never changes protected manual sizes.

Shared record managers use one DCL browser/editor for Work Areas, reference notes, details, lighting, irrigation, stations and controllers. Domain-specific identity/dependency checks remain separate. User libraries validate their envelope and copies before storage. Reusable plant label/schedule styles live in project preferences; equipment schedules retain their scope in project records and use fixed columns.

Schema 1 has an explicit identity migration boundary, not invented historical conversions. Recovery stages a valid backup while preserving both the previous file and backup. Folder packages copy only selected resources into a new destination, retain project UUID, validate manifest paths, and remap explicitly packaged detail resources. The DWG itself must be copied separately.

The 0.12.0-rc1 closure passed LT 2027 Core Console regression and calculation checks. GUI and supported-version acceptance remain required. Static checks cannot prove DCL behavior, command localization, SECURELOAD configuration, or all entity-database edge cases. See RELEASE_CHECKLIST.md and docs/CLOSURE_REPORT.md.

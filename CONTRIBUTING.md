# Contributing to TerraTools LT

TerraTools targets AutoCAD LT 2024+ on Windows. Keep runtime code in AutoLISP, DCL, standard AutoCAD commands, DXF/entity operations, XData, and local text formats. Do not add a required managed-code, COM, Python, Node.js, database-server, Civil 3D, or full-AutoCAD dependency.

Read `AGENTS.md`, `ARCHITECTURE.md`, and `docs/DATA_MODEL.md` before changing interfaces. Preserve the master data, Project Palette, placed instance, and derived view hierarchy. Public commands use `TT`; internal functions use `TT:`. Keep machine paths out of source.

For a change:

1. Make the smallest coherent edit.
2. Keep calculations separate from prompts and CAD changes.
3. Preserve unknown project fields and unrelated application XData.
4. Group drawing changes with Undo and restore system variables on error.
5. Run the parenthesis, duplicate-command, and unfinished-marker checks in `docs/DEVELOPER_GUIDE.md`.
6. Run `TTRELOAD`, `TTQACHECK`, and `TTDEVSMOKE` in AutoCAD LT.
7. Add a focused acceptance scenario when behavior changes.
8. State which LT versions were actually tested.

Data contributions need a source URL, license or public-domain basis, attribution, modification notes, and redistribution assessment. Missing source fields stay missing. Do not infer horticultural facts.

# Developer Guide

`TerraTools.lsp` records its exact installation directory in `*TT:Root*` and loads every module by explicit path. Keep dependency order intact. After edits, run `TTRELOAD`, `TTQACHECK`, and `TTDEVSMOKE` in AutoCAD LT.

Public commands use `TT`; internal functions use `TT:`. Keep calculations separate from prompts and entity changes. New project keys should be additive. Use `TT:ProjectSaveSection` so unknown fields survive. External S-expression writes go through the storage layer, which stages and verifies writes and maintains a backup.

Use ordinary LT entities and DXF functions. Each smart entity needs a fresh UUID through `TT:SmartAttach` or an equivalent constructor. Catalog IDs carry meaning; block names carry graphics. Preserve unrelated application XData.

Use `TT:ConvertLength`, `TT:ConvertArea`, and the dimension helpers for dimensional calculations. `TT:EntityLength` and `TT:EntityArea` are authoritative for supported geometry. LWPOLYLINE bulge math uses `theta = 4 atan(b)`, arc length `r |theta|`, and the signed segment correction `r^2(theta - sin(theta))/2` added to the Green's-theorem chord term.

Plant data layers are separate. The distributed catalog is application data. User plants are stored in `%APPDATA%\TerraToolsLT\user-plants.dat`. External normalized catalogs are explicit project attachments. Project Palette records are editable copies.

The CSV reader handles quoted commas, doubled quotes, blank fields, and headers. Physical newlines inside a quoted field are unsupported. AutoLISP Unicode behavior depends on `LISPSYS`; test non-ASCII imports in every supported LT release.

Before review, run:

```powershell
rg -n "TODO|FIXME|placeholder|stub|not implemented|C:\\Users\\" -S . -g '!.git/**'
rg -n --no-heading '^\(defun C:' -g '*.lsp'
git diff --check
```

Also use a string/comment-aware parenthesis scan, verify every loader path, inspect duplicate public commands, and compare DCL keys with `action_tile` registrations. Static checks do not prove LT behavior.

COPY can duplicate XData until `TTRECONCILE` runs. Xrefs are read-only. Cross-drawing copies can carry a foreign project UUID; `TTVERIFY` reports them without making unsafe catalog substitutions.

Large reports should call `TT:SmartScan` once and reuse the list. Plant search builds a compact index once and pages results. Representative 1,000, 5,000, and 10,000 entity performance tests remain part of runtime acceptance.

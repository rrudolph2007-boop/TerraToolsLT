# Developer Guide

Load `TerraTools.lsp` once with APPLOAD. It records its exact installation folder in `*TT:Root*` and loads modules by explicit relative paths. After source edits, run `TTRELOAD`. Run `TTDEVSMOKE` next. It is read-only and checks core, XData, UUID creation, project health when associated, preferences, scale, planting data, and module flags.

Public commands use the `TT` prefix. Internal functions use `TT:`. Keep storage, CAD entity work, calculations, and command/UI code separate. New persistent project fields must be additive or include a documented migration. Use `TT:ProjectSaveSection` for optional project sections and the storage layer for files.

Use ordinary LT entities and `entget`, `entmod`, `entmake`, or `entmakex`. Attach smart identity through `TT:SmartAttach`. Each placed entity needs a fresh entity UUID. Shared catalog or project IDs belong in `CATALOG_ID`. Use explicit `WORK_AREA_ID` assignments when present.

Before review, check parenthesis balance, loader order, public command collisions, hard-coded paths, unsupported ActiveX/.NET calls, XData field types, and all changed DCL resources. Static checks do not replace AutoCAD LT testing. Use `ACCEPTANCE_TESTS.md` as the release gate.

COPY duplicates XData until `TTRECONCILE` runs. Xref entities are outside the host drawing's editable selection set. Do not mutate them or adopt their project records. Erasing a source object may leave a derived label or project record; verification commands report cases that can be identified, and automatic fixes are limited to unambiguous UUID and label updates.

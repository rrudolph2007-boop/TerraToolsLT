# Developer Guide

Version 0.12.0-rc1. Read AGENTS.md and PRODUCT_REQUIREMENTS.md before substantial work. TerraTools runtime is AutoLISP/DCL on AutoCAD LT 2024+ Windows. Optional Node tools build or verify data and audit source; they are not runtime dependencies.

## Boundaries

TerraTools.lsp is the authoritative explicit module list. It records the installation root, prints each module before loading, reports the failing relative path and clears readiness after failure. TTRELOAD passes the exact loader path. Never rely on a bare support-path module name. A helper may be defined later if only called after full load; avoid executing dependent product logic at module load time.

Use TT public commands and TT: internal functions. Use TT:ProjectSaveSection and shared storage rather than ad hoc serialization. Imported S-expressions are read and validated, never evaluated. Trailing expressions are rejected. Preserve unknown compatible project fields. Schema 1 is current; TT:ProjectMigrate is deliberately an identity boundary with refusal for unknown schemas.

ProjectCurrent re-reads external storage and validates UUID. Do not replace this with a session cache that hides a moved/deleted file. Filter operation-local smart scans with TT:ProjectItems before aggregating current-project output. Active Work Area state includes project UUID. Search context includes project/source state; favorites and recents live in project data. Multiple GUI documents still require acceptance testing.

PlantPaletteSave owns project ID/code uniqueness across callers. Source IDs may repeat for variants. Source lookup must never become a prerequisite for validating project-owned records. Do not overwrite project edits during database updates.

Use TT:SmartAttach or equivalent fresh UUID metadata constructors. Preserve unrelated XData. Ordinary COPY duplicates metadata until TTRECONCILE repairs identity. Never use handles or block names as permanent identity. Use existing entity/coordinate helpers and trans where OCS/UCS/WCS differ. Unsupported tilted polygon fills are rejected.

## Calculations and storage

TT:ConvertLength, TT:ConvertArea and strict dimension parsing own conversion. TT:EntityLength and TT:EntityArea own supported geometry. Bulge math uses theta=4 atan(b), arc length r*abs(theta), and signed segment area r^2*(theta-sin(theta))/2.

The irrigation graph is operation-local. Use each edge's TO-node accumulated flow. Pressure/sizing must stop on ambiguous topology. Actual INSIDE_DIAMETER takes precedence over legacy DIAMETER_IN; nominal size remains a selection/display field. See HYDRAULICS.md. Never silently override manual size protection.

The shared CSV parser handles commas, doubled quotes, blank fields, headers and quoted physical newlines; malformed quoting fails. CSV export does not mutate stored text. Review formula-leading untrusted text before opening exported data in a spreadsheet. Unicode source data requires LISPSYS 1 or 2 and an LT restart when that value changes.

User libraries normalize optional fields then validate the envelope before save. Project packages use new folders, safe relative paths and selected resources. Recovery preserves both the previous current file and valid backup. No normal command runs arbitrary imported code.

## Development checks

From the repository root:

```powershell
node tools/check-lisp.mjs
node tools/check-dcl.mjs
node tools/verify-plants.mjs data/plants/production
rg -n 'TODO|FIXME|STUB|PLACEHOLDER|NOT IMPLEMENTED|TEMP|HACK' core planting site details lighting irrigation schedules dialogs tools
rg -n '^\(defun C:' -g '*.lsp'
git diff --check
```

The Lisp checker audits reader structure, arguments, duplicate definitions, direct unresolved TT calls and loader files. The DCL checker audits delimiters, dialog/key duplication and cancel controls. Neither is an AutoLISP interpreter or GUI renderer. Inspect callbacks and actual dialog behavior separately.

In a disposable LT drawing, run TTRELOAD, TTDEVSMOKE and TTQACHECK. The latter two are read-only. For development regression only, load tools/lt-regression.lsp, then tools/completion-regression.lsp. They execute on load, create temporary project/package files and temporary DWG entities, and must never be run against production work. The extended harness expects the foundation harness's disposable project. Preserve logs outside the repository.

For benchmark only, load tools/benchmark.lsp and call (TT:RunBenchmark) in an empty disposable drawing. It creates up to 10,000 points, measures scans and reconciliation, and deletes only its own points on normal/error exit. Compare smart-object count before and after. It is intentionally outside smoke/QA.

LT 2027 Core Console ran these checks during closure. Both product DCL and a minimal control dialog returned -1 there, so DCL regression is SKIP, not PASS. Run visible GUI tests and supported-version coverage before release. The LT 2024 [AutoLISP reference](https://help.autodesk.com/cloudhelp/2024/PLK/AutoCAD-LT-AutoLISP-Reference/files/GUID-B21C91DD-D359-4370-84ED-317F8BBAF414.htm) documents the sorting primitive used by schedule ordering; [LT AutoLISP limitations](https://help.autodesk.com/cloudhelp/2024/HUN/AutoCAD-AutoLISP/files/GUID-037BF4D4-755E-4A5C-8136-80E85CCEDF3E.htm) still apply. No COM/ActiveX assumption substitutes for version testing.

See PLANT_DATABASE.md for the optional streaming WFO build and checksums. Do not commit raw data, generated production packages, temporary projects, AutoCAD lock/crash files or credentials. Do not commit or push without explicit user instruction.

# TerraTools LT User Guide

Run `TT` for the main dialog. Each button opens a module workflow. If the DCL resource cannot load, the same launcher appears at the command line.

Start with `TTPROJECT` and choose Create or Open. Then use `TTPREFERENCES`, `TTLAYERS`, and `TTSCALE`. Create named boundaries with `TTWORKAREA`, and assign selected smart objects with `TTASSIGNWORKAREA`.

For planting, add Master Catalog records to the Project Plant Palette with `TTPLANTS`. Place them with `TTPLACEPLANT`, `TTPLANTLINE`, `TTPLANTARRAY`, or `TTPLANTRANDOM`. Use `TTGROUND` for a closed single-species planting boundary and `TTMIX` plus `TTMIXAREA` for a two-species mix. Labels and schedules derive their values from live objects. Refresh them with `TTUPDATEPLANTLABELS` and `TTUPDATEPLANTSCHEDULE`. Run `TTVERIFYPLANTS` before issue. `TTEXPORTPLANTCSV` writes a schedule; `TTIMPORTPLANTCSV` reads the first Code column and adds matching Master Catalog records to the active project palette.

For Site work, `TTREFNOTE` attaches a project note record to selected geometry. Length, area, and volume notes derive quantities from LINE or closed LWPOLYLINE geometry. `TTREFNOTESCHEDULE` creates an MTEXT schedule. `TTAREA`, `TTLENGTH`, `TTVOLUME`, `TTSLOPE`, `TTCOORDLABEL`, `TTSPOTELEVATION`, and `TTCONCEPT` provide direct site helpers.

Use `TTDETAILS` to add and browse project details. `TTPLACEDETAIL` creates an original demo detail frame, `TTCALLOUT` creates a reference, `TTDETAILRENUMBER` updates the record and its live callout text, and `TTDETAILINDEX` creates an MTEXT index.

Use `TTLIGHTING` to add fixtures to the Project Fixture Palette, place or replace fixtures, draw wires, place transformers, assign circuits, inspect circuit load, make a schedule, and verify records. The included fixture data and symbols are fictional examples.

Use `TTIRRIGATION` to add fictional equipment records, place equipment, draw directed mainline or lateral pipe, draw head coverage, assign stations, analyze flow, size pipe, make schedules, and verify. Draw every smart pipe from upstream to downstream and snap connected objects to pipe endpoints. See `HYDRAULICS.md` before relying on pressure results.

`TTINFO` inspects any smart object. `TTVERIFY` reports UUID and metadata problems. `TTRECONCILE` repairs duplicate entity UUIDs caused by COPY. `TTHIGHLIGHT` and module highlight commands use temporary screen highlighting; REGEN clears it.

Schedules use MTEXT because it is dependable in LT AutoLISP. Symbols are simple original definitions made in the current DWG. Xrefs are treated as read-only. WBLOCK or copied objects retain XData and may need `TTRECONCILE` in the destination drawing. Deleting geometry does not delete external catalog or project records.

# TerraTools LT 0.9.0-rc1 Acceptance Tests

Run these tests in AutoCAD LT 2024 or newer on Windows. Use disposable DWGs and project folders. Record the LT version and mark each scenario Pass or Fail with the actual command-line output.

## 1. Load, launcher, and reload

**Setup:** Start a blank drawing with the TerraTools folder trusted. **Actions:** APPLOAD `TerraTools.lsp`; run `TTHELLO`, `TT`, close the dialog, then run `TTRELOAD`. **Expected:** The loader reports `0.9.0-rc1`; TTHELLO prints its established success message; the launcher opens; reload uses the same root. **Pass:** No load error and `*TT:CoreLoaded*` remains true.

## 2. Read-only diagnostics

**Setup:** Use the loaded blank drawing. **Actions:** Run `TTDEBUG` and `TTDEVSMOKE`. **Expected:** Core, XData, all release-candidate modules, and UI report loaded; project checks are SKIP when no project is associated. **Pass:** Smoke test ends PASS and creates no entities or files.

## 3. Create and persist a project

**Setup:** Make an empty writable test folder. **Actions:** Run `TTPROJECT`, Create, enter all requested data; SAVE the DWG; close LT; reopen LT and the DWG; APPLOAD TerraTools; run `TTPROJECTINFO`. **Expected:** The same UUID, metadata, and file path return. **Pass:** `terratools-project.dat` exists and the association survives restart.

## 4. Preferences, layers, and scale

**Setup:** Open an active test project. **Actions:** Run `TTPREFERENCES`, change text height; run `TTLAYERS`, Create; run `TTSCALE`, set 100; reload and inspect again. **Expected:** settings persist and configured layers exist. **Pass:** scale is positive, layer roles resolve, and TTDEVSMOKE passes these checks.

## 5. Missing project recovery

**Setup:** Save and close a project-associated DWG. **Actions:** Rename its external project folder; reopen and run `TTPROJECTINFO` and `TTDEBUG`; restore the original name and reload. **Expected:** missing file is reported, readable is No, and no data is fabricated; restoring the path restores health. **Pass:** association information survives both states.

## 6. Plant Master Catalog and palette

**Setup:** Active project. **Actions:** `TTPLANTMASTER`, browse all categories; `TTPLANTS` Add one record from each category by number; Edit one project record; List. **Expected:** Master count is 15, no raw ID is requested, and edits affect only project data. **Pass:** duplicates are rejected and reload preserves palette changes.

## 7. Individual plant placement

**Setup:** Create standard layers and add plants to the palette. **Actions:** `TTPLACEPLANT`, choose by number, place three points, press Enter; run `TTPLANTINFO` and `TTCOUNTPLANTS`. **Expected:** ordinary INSERTs appear on logical layers with unique UUIDs and shared project plant identity. **Pass:** info resolves the project record and count is three.

## 8. COPY and UUID reconciliation

**Setup:** One placed plant. **Actions:** COPY it twice with AutoCAD; run `TTVERIFY`, then `TTRECONCILE`, then `TTVERIFY`. **Expected:** verification finds duplicate UUIDs; reconciliation changes only duplicate instance UUIDs. **Pass:** geometry remains, all three plant references match, and duplicate count becomes zero.

## 9. Plant edit, replace, match, highlight, locate

**Setup:** Several placed plants of two palette records. **Actions:** Run `TTEDITPLANT`, `TTREPLACEPLANT`, `TTMATCHPLANT`, `TTHIGHLIGHTPLANT`, and `TTLOCATEPLANT`. **Expected:** replacement preserves INSERT position and instance UUID while changing graphics/catalog identity; match changes selected targets. **Pass:** each command works by entity or numbered selection with no raw ID prompt.

## 10. Rapid planting

**Setup:** Active plant palette. **Actions:** Run `TTPLANTLINE`, `TTPLANTARRAY`, and `TTPLANTRANDOM` with small counts. **Expected:** spacing and counts match prompts; each INSERT has a different UUID. **Pass:** one Undo removes each command's created set and no partial set remains after cancellation.

## 11. Groundcover geometry

**Setup:** Draw a closed rectangular LWPOLYLINE and choose a plant with spacing. **Actions:** `TTGROUND`, choose Square; run `TTGROUNDINFO`; grip-edit the boundary larger; run `TTUPDATEGROUND`. **Expected:** quantity derives from current area and changes after the edit. **Pass:** geometry remains an ordinary closed polyline and no stored quantity masks the change.

## 12. Plant mix

**Setup:** Two project plants and a closed boundary. **Actions:** `TTMIX`, choose both and a percentage; `TTMIXAREA`; `TTMIXINFO`. **Expected:** both derived quantities use current boundary area, spacing, and percentages. **Pass:** percentages and stable project plant references survive reload.

## 13. Plant labels

**Setup:** Place twelve instances of one plant. **Actions:** `TTLABELGROUP`, select all; erase two plants; `TTUPDATEPLANTLABELS`; erase the label. **Expected:** label starts at 12, updates to 10, and erasing it does not erase plants. **Pass:** label is a derived TEXT entity tied to target UUIDs.

## 14. Plant verification and repair

**Setup:** Include valid plants, a copied duplicate, and a deleted label target. **Actions:** Run `TTVERIFYPLANTS`, `TTFIXPLANTS`, then `TTVERIFYPLANTS`. **Expected:** reports identify missing/invalid references; only unambiguous UUID and label updates occur. **Pass:** ordinary geometry is not erased or silently reassigned.

## 15. Plant schedules, costs, and CSV

**Setup:** Individual and area plants with unit costs. **Actions:** `TTPLANTSCHEDULE`; change geometry; `TTUPDATEPLANTSCHEDULE`; `TTPLANTCOST`; `TTEXPORTPLANTCSV`; inspect the CSV; in another project run `TTIMPORTPLANTCSV`. **Expected:** quantities and costs are derived; CSV fields are quoted; import adds known codes and skips duplicates/unknown codes. **Pass:** source Master Catalog remains unchanged.

## 16. Work Area filtering

**Setup:** Two closed boundaries and placed plants. **Actions:** Create each with `TTWORKAREA`; use `TTASSIGNWORKAREA`; run `TTPLANTSCHEDULE`, WorkArea, and choose one. **Expected:** schedule contains only explicitly assigned objects for that Work Area. **Pass:** Work Area identity survives moving its boundary and project reload.

## 17. Reference notes and site schedule

**Setup:** Draw a LINE and a closed LWPOLYLINE. **Actions:** attach Length and Area records with `TTREFNOTE`; run `TTREFNOTESCHEDULE`; edit geometry; run `TTUPDATEREFNOTES`. **Expected:** schedule quantities follow current geometry. **Pass:** note records persist externally and geometry stores only lightweight identity.

## 18. Site and grading helpers

**Setup:** Simple geometry with known dimensions. **Actions:** Run `TTAREA`, `TTLENGTH`, `TTVOLUME`, `TTSLOPE`, `TTCOORDLABEL`, `TTSPOTELEVATION`, and `TTCONCEPT`. **Expected:** numerical results match hand calculations and annotations use ordinary entities. **Pass:** canceling any prompt exits cleanly.

## 19. Details

**Setup:** Active project. **Actions:** `TTDETAILS` Add two details; `TTPLACEDETAIL`; `TTCALLOUT`; `TTDETAILRENUMBER`; `TTDETAILINFO`; `TTDETAILINDEX`. **Expected:** original demo graphics and callouts reference project records; renumber updates existing callout text. **Pass:** list and index show the new number after reload.

## 20. Lighting palette and placement

**Setup:** Active project and standard layers. **Actions:** `TTLIGHTING` Add two fixtures; Place several; Replace one; Info. **Expected:** selections are numbered, INSERTs get unique UUIDs, and replacement preserves instance identity. **Pass:** Project Fixture Palette persists and Master data is unchanged.

## 21. Lighting circuits and schedules

**Setup:** Placed fixtures, wire, and transformer. **Actions:** `TTLIGHTWIRE`, `TTTRANSFORMER`, assign fixtures with `TTCIRCUITASSIGN`; run `TTCIRCUITINFO`, `TTLIGHTINGSCHEDULE`, `TTVERIFYLIGHTING`. **Expected:** connected watts equal fixture totals and schedule includes quantities, load, and cost. **Pass:** circuit survives save, close, and reopen.

## 22. Irrigation equipment and coverage

**Setup:** Active project. **Actions:** `TTIRRIGATION` Add spray, rotor, valve, controller, and POC records; Place them; run `TTIRRIGATIONCOVERAGE` on a head. **Expected:** equipment uses ordinary INSERTs and coverage is an ordinary helper CIRCLE. **Pass:** metadata identifies equipment and coverage parent without handles.

## 23. Directed irrigation network

**Setup:** Place a valve and three heads. Draw connected lateral LINEs from upstream start to downstream end with `TTPIPE`; assign all to station 1 with `TTASSIGNSTATION`. **Actions:** run `TTIRRIGATIONANALYZE`. **Expected:** demand is the sum of head flows, each pipe gets downstream demand, and disconnected count is zero. **Pass:** results match a hand trace of line directions.

## 24. Disconnected and loop detection

**Setup:** Add one unconnected station head and a directed pipe loop. **Actions:** run `TTIRRIGATIONANALYZE`. **Expected:** at least one disconnected demand object and an ambiguous loop warning. **Pass:** TerraTools does not invent a clean flow solution.

## 25. Hydraulic calculator and sizing

**Setup:** Prepare a hand calculation for known length, gpm, diameter, and C. **Actions:** Run `TTHYDRAULIC` with the same values; run `TTSIZEPIPE`; run `TTIRRIGATIONSIZE` on a pipe and answer No, then repeat and answer Yes. **Expected:** formula results agree within display precision; No preserves the size; Yes applies the shown size. **Pass:** invalid zero diameter or negative flow is rejected.

## 26. Station and critical-path reports

**Setup:** A valid station network. **Actions:** `TTZONEINFO`, `TTHIGHLIGHTSTATION`, `TTCRITICALPATH`, selecting pipes in the design path. **Expected:** station demand and pipe count agree; highlighting is temporary; path loss is the sum for selected smart pipes. **Pass:** REGEN restores display and no CAD property is changed.

## 27. Irrigation schedule, persistence, and verification

**Setup:** Completed sample network. **Actions:** `TTIRRIGATIONSCHEDULE`, `TTVERIFYIRRIGATION`; save, close, reopen, reload, and repeat. **Expected:** schedule quantities and flow totals remain derived from placed equipment; verification status is stable. **Pass:** XData, station, pipe diameter, and project palette persist.

## 28. Error handling and performance sanity

**Setup:** Copy a test drawing and create at least 1,000 mixed smart objects. Make the project file read-only for one save test, then restore it. **Actions:** time `TTVERIFY`, `TTDEVSMOKE`, and schedule generation; cancel representative selection and point prompts; attempt a project write while read-only. **Expected:** scans finish without locking LT, cancellation is quiet, and failed storage reports an error while preserving the prior file and drawing usability. **Pass:** no crash, no silent data replacement, no unexpected entity deletion, and no machine-specific path appears.

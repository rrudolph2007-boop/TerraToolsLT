# TerraTools LT 0.10.0-rc1 Acceptance Tests

Run these tests in AutoCAD LT 2024 or newer on Windows. Use disposable DWGs and project folders. Record the LT version and mark each scenario Pass or Fail with the actual command-line output.

## 1. Load, launcher, and reload

**Setup:** Start a blank drawing with the TerraTools folder trusted. **Actions:** APPLOAD `TerraTools.lsp`; run `TTHELLO`, `TT`, close the dialog, then run `TTRELOAD`. **Expected:** The loader reports `0.10.0-rc1`; TTHELLO prints its established success message; the launcher opens; reload uses the same root. **Pass:** No load error and `*TT:CoreLoaded*` remains true.

## 2. Read-only diagnostics

**Setup:** Use the loaded blank drawing. **Actions:** Run `TTDEBUG`, `TTQACHECK`, and `TTDEVSMOKE`. **Expected:** deterministic QA ends PASS; Core, XData, all release-candidate modules, and UI report loaded; project checks are SKIP when no project is associated. **Pass:** Both tests end PASS and create no entities or files.

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

**Setup:** Active plant palette with LINE, ARC, and bulged LWPOLYLINE paths. **Actions:** Run `TTPLANTPATH` with fixed and equal spacing, then `TTPLANTARRAY` and `TTPLANTRANDOM` with small counts. **Expected:** spacing and counts match prompts; random scale/rotation stay within entered limits; each INSERT has a different UUID. **Pass:** one Undo removes each command's created set and no partial set remains after cancellation.

## 11. Groundcover geometry

**Setup:** Draw a closed rectangular LWPOLYLINE and choose a plant with spacing. **Actions:** `TTGROUND`, choose Square; run `TTGROUNDINFO`; grip-edit the boundary larger; run `TTUPDATEGROUND`. **Expected:** quantity derives from current area and changes after the edit. **Pass:** geometry remains an ordinary closed polyline and no stored quantity masks the change.

## 12. Plant mix

**Setup:** Four project plants and a closed boundary. **Actions:** `TTMIX`, create a four-component ratio mix; `TTMIXEDIT`, replace it with three percentages totaling 100; `TTMIXAREA`; `TTMIXINFO`. **Expected:** all component quantities use current area, spacing, and normalized percentages. **Pass:** arbitrary components and stable project plant references survive reload.

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

## 29. Bulged polyline geometry

**Setup:** Draw a closed two-vertex semicircular LWPOLYLINE with diameter 2 and a mixed straight/arc closed polyline. **Actions:** Run `TTLENGTH`, `TTAREA`, and attach an Area reference note. **Expected:** semicircle area is approximately pi/2 and perimeter is approximately pi+2; mixed results agree with hand calculations. **Pass:** signs of positive and negative bulges produce correct absolute area and arc length.

## 30. Open bulged polyline length

**Setup:** Draw open LWPOLYLINEs with positive and negative semicircle bulges. **Actions:** Run `TTLENGTH` on each. **Expected:** both arc lengths equal pi times radius for the same chord/bulge magnitude. **Pass:** no closing chord is included for an open polyline.

## 31. Central unit conversion

**Setup:** Use a disposable project and set matching Imperial or Metric `INSUNITS`. **Actions:** Run `TTUNITS` and `TTUNITCONVERT` for 12 in to 1 ft, 1000 mm to 1 m, and 100 cm to 1 m. **Expected:** resolved drawing units and conversions are exact within display precision. **Pass:** unknown units do not produce a guessed result.

## 32. Plant spacing units

**Setup:** Make equivalent planting areas in inch, foot, millimeter, centimeter, and meter drawings. Enter equivalent explicit spacing strings. **Actions:** Run `TTGROUNDINFO`. **Expected:** equivalent physical areas and spacing produce equivalent density. **Pass:** numeric legacy spacing still behaves as drawing units.

## 33. Plant search and pagination

**Setup:** Active project with the sample catalog. **Actions:** Run `TTPLANTSEARCH`; search partial terms such as `sample tree`, filter categories, page results, and Add. **Expected:** search matches all words across indexed fields; pages contain no more than 20 records; Add retains the stable Master Plant ID. **Pass:** no raw ID entry is required.

## 34. Favorites and recent plants

**Setup:** Active project. **Actions:** Favorite a search result, filter Favorites, add two plants, save/reopen, and inspect project data. **Expected:** favorite and recent stable IDs persist. **Pass:** favorites do not duplicate Master or Project Palette records.

## 35. User plant library

**Setup:** Active project and writable roaming application-data folder. **Actions:** Run `TTPLANTUSER`, Add a record, reload TerraTools, search it, and add it to a project. **Expected:** the user record survives reload outside the distributed catalog. **Pass:** reinstall-style replacement of `data/` does not remove the user library.

## 36. USDA import pipeline

**Setup:** Download the current official USDA Complete PLANTS Checklist CSV. **Actions:** Run `TTIMPORTUSDA`, choose an output file, attach it with `TTPLANTDATA`, and search a known symbol/name. **Expected:** import reports the real record count and copies only source fields; missing design data stays blank. **Pass:** stable IDs begin with `USDA-PLANTS-`, provenance fields exist, and no images are imported.

## 37. Malformed plant data

**Setup:** Copy a normalized plant file and damage its envelope or a required identity. **Actions:** Attach it with `TTPLANTDATA`. **Expected:** the file is rejected as invalid or empty. **Pass:** the Project Palette and existing attachment list remain unchanged.

## 38. Project Plant source independence

**Setup:** Create a normalized external catalog containing a uniquely identified plant, attach it with `TTPLANTDATA`, add that plant to the Project Plant Palette, and place one instance. **Actions:** Record the Project Plant ID; detach the external catalog; run `TTRELOAD`, `TTPLANTS` List, `TTPLANTINFO`, and `TTVERIFYPLANTS`; then reattach the same catalog and repeat the information and verification commands. **Expected:** after detach, the palette loads, the placed instance still resolves through the unchanged Project Plant ID, project edits remain intact, and diagnostics report `SOURCE UNAVAILABLE`; after reattach, diagnostics report `SOURCE AVAILABLE` without migration. **Pass:** detaching changes only `PLANT_DATA_PATHS`; it does not delete, recreate, or alter the Project Plant or placed entity.

## 39. Office standards exchange

**Setup:** Active project with changed preferences. **Actions:** `TTSTANDARDS` SaveUser, reset project preferences, ApplyUser, Export, then Import the export into another project. **Expected:** validation succeeds and preferences match. **Pass:** existing preference schema remains version 1 and unrelated project fields survive.

## 40. Work Area lifecycle

**Setup:** Two Work Areas, one with assigned objects and one empty. **Actions:** `TTWORKAREAS` Rename, Highlight, Count; attempt to delete both. **Expected:** the dependent area cannot be deleted; the empty area and boundary can be deleted after confirmation. **Pass:** failed project storage restores a boundary deleted during the attempted transaction.

## 41. Reference note Work Area and cost

**Setup:** Reference-note objects split between two Work Areas with unit costs. **Actions:** Create an all-project and a Work Area schedule, edit a code/cost, then update the schedule. **Expected:** scoped quantities and subtotals match assignments and current geometry. **Pass:** curved area/length quantities use bulge-aware geometry.

## 42. Detail validation

**Setup:** Add details with categories, keywords, and one source DWG. **Actions:** Attempt a duplicate number, rename the source file, run Verify, and try removing a placed detail. **Expected:** duplicate Add is refused, missing file is reported, and referenced removal is refused. **Pass:** restoring the source path clears the file issue.

## 43. Lighting transformer capacity

**Setup:** Assign fixtures and a transformer to one circuit. **Actions:** Run `TTTRANSFORMERLOAD` below and above capacity, then `TTVERIFYLIGHTING`. **Expected:** load, capacity, spare watts, and PASS/FAIL are correct. **Pass:** overload is reported without changing entities.

## 44. Lighting voltage drop

**Setup:** Prepare a hand calculation using 100 W, 12 V, 50 ft one-way, and supported copper AWG. **Actions:** Run `TTVOLTAGEDROP`. **Expected:** result matches `2 K I L / CM` with K=12.9 and reports percentage. **Pass:** unsupported AWG and zero voltage are rejected.

## 45. Branched per-pipe irrigation flow

**Setup:** Build one upstream pipe that branches to 3 gpm and 5 gpm heads. **Actions:** Analyze and size each branch and upstream pipe. **Expected:** branch flows are 3 and 5 gpm; upstream flow is 8 gpm. **Pass:** pipe sizing uses those three different flows.

## 46. Merged-path irrigation ambiguity

**Setup:** Draw two directed pipes merging into one downstream node for a station. **Actions:** Analyze, size a pipe, and run a selected critical path. **Expected:** merged-node count is positive and sizing/path calculations stop with an ambiguity message. **Pass:** no diameter is silently changed.

## 47. Foreign-project copy detection

**Setup:** Copy or WBLOCK a smart entity from project A into a DWG associated with project B. **Actions:** Run `TTVERIFY` and `TTRECONCILE`. **Expected:** verification reports a foreign project UUID; reconciliation only repairs duplicate entity UUIDs. **Pass:** TerraTools does not silently adopt or rewrite the foreign catalog identity.

## 48. CSV parser edge cases

**Setup:** Prepare an import CSV with commas, doubled quotes, blank fields, headers, and non-ASCII text. **Actions:** Run `TTQACHECK` and the relevant import in each supported `LISPSYS` setting. **Expected:** structural fields parse correctly; unsupported encoding is reported or documented. **Pass:** no existing record is silently overwritten.

## 49. Large catalog and drawing performance

**Setup:** Attach a legitimate large normalized catalog and prepare drawings with about 1,000, 5,000, and 10,000 smart entities. **Actions:** Time first and repeated plant searches, `TTVERIFY`, and representative schedules. **Expected:** first search builds the index; repeated searches reuse it; drawing scans complete without nested-scan stalls. **Pass:** results stay correct and AutoCAD LT remains responsive enough for review.

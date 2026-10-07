# TerraTools LT 0.12.0-rc1 Acceptance Tests

Run these tests in AutoCAD LT 2024 or newer on Windows. Use disposable DWGs and project folders. Record the LT version and mark each scenario Pass or Fail with actual evidence. All GUI scenarios remain NOT RUN until exercised in visible AutoCAD LT. Core Console results are recorded separately in RELEASE_CHECKLIST.md.

## 1. Load, launcher, and reload

**Setup:** Start a blank drawing with the TerraTools folder trusted. **Actions:** APPLOAD `TerraTools.lsp`; run `TTHELLO`, `TT`, close the dialog, then run `TTRELOAD`. **Expected:** The loader reports `0.12.0-rc1`; TTHELLO prints its established success message; the launcher opens; reload uses the same root. **Pass criteria:** No load error and `*TT:CoreLoaded*` remains true. In a disposable installation copy, remove a late-loaded module and reload: the exact module must be named and all readiness flags must be nil; restore the file and reload successfully.

## 2. Read-only diagnostics

**Setup:** Use the loaded blank drawing. **Actions:** Run `TTDEBUG`, `TTQACHECK`, and `TTDEVSMOKE`. **Expected:** deterministic QA ends PASS; Core, XData, all release-candidate modules, and UI report loaded; project checks are SKIP when no project is associated. **Pass criteria:** Both tests end PASS and create no entities or files.

## 3. Create and persist a project

**Setup:** Make an empty writable test folder. **Actions:** Run `TTPROJECT`, Create, enter all requested data; SAVE the DWG; close LT; reopen LT and the DWG; APPLOAD TerraTools; run `TTPROJECTINFO`. **Expected:** The same UUID, metadata, and file path return. **Pass criteria:** `terratools-project.dat` exists and the association survives restart.

## 4. Preferences, layers, and scale

**Setup:** Open an active test project. **Actions:** Run `TTPREFERENCES`, change text height; run `TTLAYERS`, Create; run `TTSCALE`, set 100; reload and inspect again. **Expected:** settings persist and configured layers exist. **Pass criteria:** scale is positive, layer roles resolve, and TTDEVSMOKE passes these checks.

## 5. Missing project recovery

**Setup:** Save and close a project-associated DWG. **Actions:** Rename its external project folder; reopen and run `TTPROJECTINFO` and `TTDEBUG`; restore the original name and reload. **Expected:** missing file is reported, readable is No, and no data is fabricated; restoring the path restores health. **Pass criteria:** association information survives both states.

## 6. Plant Master Catalog and palette

**Setup:** Active project. **Actions:** `TTPLANTMASTER`, browse all categories; `TTPLANTS`, use Plant Sources to add one record from each category; edit one project record; return to Project Plants. **Expected:** Master count is 15, no raw ID is requested, and edits affect only project data. **Pass criteria:** duplicate project codes are rejected, same-source variants are allowed, and reload preserves palette changes.

## 7. Individual plant placement

**Setup:** Create standard layers and add plants to the palette. **Actions:** `TTPLACEPLANT`, choose by number, place three points, press Enter; run `TTPLANTINFO` and `TTCOUNTPLANTS`. **Expected:** ordinary INSERTs appear on logical layers with unique UUIDs and shared project plant identity. **Pass criteria:** info resolves the project record and count is three.

## 8. COPY and UUID reconciliation

**Setup:** One placed plant. **Actions:** COPY it twice with AutoCAD; run `TTVERIFY`, then `TTRECONCILE`, then `TTVERIFY`. **Expected:** verification finds duplicate UUIDs; reconciliation changes only duplicate instance UUIDs. **Pass criteria:** geometry remains, all three plant references match, and duplicate count becomes zero.

## 9. Plant edit, replace, match, highlight, locate

**Setup:** Several placed plants of two palette records. **Actions:** Run `TTEDITPLANT`, `TTREPLACEPLANT`, `TTMATCHPLANT`, `TTHIGHLIGHTPLANT`, and `TTLOCATEPLANT`. **Expected:** replacement preserves INSERT position and instance UUID while changing graphics/catalog identity; match changes selected targets. **Pass criteria:** each command works by entity or numbered selection with no raw ID prompt.

## 10. Rapid planting

**Setup:** Active plant palette with LINE, ARC, and bulged LWPOLYLINE paths. **Actions:** Run `TTPLANTPATH` with fixed and equal spacing, then `TTPLANTARRAY` and `TTPLANTRANDOM` with small counts. **Expected:** spacing and counts match prompts; random scale/rotation stay within entered limits; each INSERT has a different UUID. **Pass criteria:** one Undo removes each command's created set and no partial set remains after cancellation.

## 11. Groundcover geometry

**Setup:** Draw a closed rectangular LWPOLYLINE and choose a plant with spacing. **Actions:** `TTGROUND`, choose Square; run `TTGROUNDINFO`; grip-edit the boundary larger; run `TTUPDATEGROUND`. **Expected:** quantity derives from current area and changes after the edit. **Pass criteria:** geometry remains an ordinary closed polyline and no stored quantity masks the change.

## 12. Plant mix

**Setup:** Four project plants and a closed boundary. **Actions:** `TTMIX`, create a four-component ratio mix; `TTMIXEDIT`, replace it with three percentages totaling 100; `TTMIXAREA`; `TTMIXINFO`. **Expected:** all component quantities use current area, spacing, and normalized percentages. **Pass criteria:** arbitrary components and stable project plant references survive reload.

## 13. Plant labels

**Setup:** Place twelve instances of one plant. **Actions:** `TTLABELGROUP`, select all; erase two plants; `TTUPDATEPLANTLABELS`; erase the label. **Expected:** label starts at 12, updates to 10, and erasing it does not erase plants. **Pass criteria:** label is a derived TEXT entity tied to target UUIDs.

## 14. Plant verification and repair

**Setup:** Include valid plants, a copied duplicate, and a deleted label target. **Actions:** Run `TTVERIFYPLANTS`, `TTFIXPLANTS`, then `TTVERIFYPLANTS`. **Expected:** reports identify missing/invalid references; only unambiguous UUID and label updates occur. **Pass criteria:** ordinary geometry is not erased or silently reassigned.

## 15. Plant schedules, costs, and CSV

**Setup:** Individual and area plants with unit costs. **Actions:** `TTPLANTSCHEDULE`; change geometry; `TTUPDATEPLANTSCHEDULE`; `TTPLANTCOST`; `TTEXPORTPLANTCSV`; inspect the CSV; in another project run `TTIMPORTPLANTCSV`. **Expected:** quantities and costs are derived; CSV fields are quoted; import adds known codes and skips duplicates/unknown codes. **Pass criteria:** source Master Catalog remains unchanged.

## 16. Work Area filtering

**Setup:** Two closed boundaries and placed plants. **Actions:** Create each with `TTWORKAREA`; use `TTASSIGNWORKAREA`; run `TTPLANTSCHEDULE`, WorkArea, and choose one. **Expected:** schedule contains only explicitly assigned objects for that Work Area. **Pass criteria:** Work Area identity survives moving its boundary and project reload.

## 17. Reference notes and site schedule

**Setup:** Draw a LINE and a closed LWPOLYLINE. **Actions:** attach Length and Area records with `TTREFNOTE`; run `TTREFNOTESCHEDULE`; edit geometry; run `TTUPDATEREFNOTES`. **Expected:** schedule quantities follow current geometry. **Pass criteria:** note records persist externally and geometry stores only lightweight identity.

## 18. Site and grading helpers

**Setup:** Simple geometry with known dimensions. **Actions:** Run `TTAREA`, `TTLENGTH`, `TTVOLUME`, `TTSLOPE`, `TTCOORDLABEL`, `TTSPOTELEVATION`, and `TTCONCEPT`. **Expected:** numerical results match hand calculations and annotations use ordinary entities. **Pass criteria:** canceling any prompt exits cleanly.

## 19. Details

**Setup:** Active project. **Actions:** `TTDETAILS` Add two details; `TTPLACEDETAIL`; `TTCALLOUT`; `TTDETAILRENUMBER`; `TTDETAILINFO`; `TTDETAILINDEX`. **Expected:** original demo graphics and callouts reference project records; renumber updates existing callout text. **Pass criteria:** list and index show the new number after reload.

## 20. Lighting palette and placement

**Setup:** Active project and standard layers. **Actions:** `TTLIGHTING` Add two fixtures; Place several; Replace one; Info. **Expected:** selections are numbered, INSERTs get unique UUIDs, and replacement preserves instance identity. **Pass criteria:** Project Fixture Palette persists and Master data is unchanged.

## 21. Lighting circuits and schedules

**Setup:** Placed fixtures, wire, and transformer. **Actions:** `TTLIGHTWIRE`, `TTTRANSFORMER`, assign fixtures with `TTCIRCUITASSIGN`; run `TTCIRCUITINFO`, `TTLIGHTINGSCHEDULE`, `TTVERIFYLIGHTING`. **Expected:** connected watts equal fixture totals and schedule includes quantities, load, and cost. **Pass criteria:** circuit survives save, close, and reopen.

## 22. Irrigation equipment and coverage

**Setup:** Active project. **Actions:** `TTIRRIGATION` Add spray, rotor, valve, controller, and POC records; Place them; run `TTIRRIGATIONCOVERAGE` on a head. **Expected:** equipment uses ordinary INSERTs and coverage is an ordinary helper CIRCLE. **Pass criteria:** metadata identifies equipment and coverage parent without handles.

## 23. Directed irrigation network

**Setup:** Place one POC, a valve and three heads. Draw connected lateral LINEs from upstream start to downstream end with `TTPIPE`; assign all to station 1 with `TTASSIGNSTATION`. **Actions:** run `TTIRRIGATIONANALYZE`. **Expected:** demand is the sum of head flows, each pipe gets downstream demand, and disconnected count is zero. **Pass criteria:** results match a hand trace of line directions.

## 24. Disconnected and loop detection

**Setup:** Add one unconnected station head and a directed pipe loop. **Actions:** run `TTIRRIGATIONANALYZE`. **Expected:** at least one disconnected demand object and an ambiguous loop warning. **Pass criteria:** TerraTools does not invent a clean flow solution.

## 25. Hydraulic calculator and sizing

**Setup:** Prepare a hand calculation for known length, gpm, diameter, and C. **Actions:** Run `TTHYDRAULIC` with the same values; run `TTSIZEPIPE`; run `TTIRRIGATIONSIZE` Recommend; test Single with manual protection on, then explicitly use `TTPIPEAUTO` Automatic and repeat. **Expected:** formula results agree within display precision; Recommend and manual protection preserve size; Automatic permits applying the recommendation. **Pass criteria:** invalid zero diameter or negative flow is rejected.

## 26. Station and critical-path reports

**Setup:** A valid station network. **Actions:** `TTZONEINFO`, `TTHIGHLIGHTSTATION`, `TTCRITICALPATH`, entering the station and available source pressure. **Expected:** station demand and pipe count agree; highlighting is temporary; the critical route is derived from the valid directed station tree. **Pass criteria:** REGEN restores display and no CAD property is changed.

## 27. Irrigation schedule, persistence, and verification

**Setup:** Completed sample network. **Actions:** `TTIRRIGATIONSCHEDULE`, `TTVERIFYIRRIGATION`; save, close, reopen, reload, and repeat. **Expected:** schedule quantities and flow totals remain derived from placed equipment; verification status is stable. **Pass criteria:** XData, station, pipe diameter, and project palette persist.

## 28. Error handling and performance sanity

**Setup:** Copy a test drawing and create at least 1,000 mixed smart objects. Make the project file read-only for one save test, then restore it. **Actions:** time `TTVERIFY`, `TTDEVSMOKE`, and schedule generation; cancel representative selection and point prompts; attempt a project write while read-only. **Expected:** scans finish without locking LT, cancellation is quiet, and failed storage reports an error while preserving the prior file and drawing usability. **Pass criteria:** no crash, no silent data replacement, no unexpected entity deletion, and no machine-specific path appears.

## 29. Bulged polyline geometry

**Setup:** Draw a closed two-vertex semicircular LWPOLYLINE with diameter 2 and a mixed straight/arc closed polyline. **Actions:** Run `TTLENGTH`, `TTAREA`, and attach an Area reference note. **Expected:** semicircle area is approximately pi/2 and perimeter is approximately pi+2; mixed results agree with hand calculations. **Pass criteria:** signs of positive and negative bulges produce correct absolute area and arc length.

## 30. Open bulged polyline length

**Setup:** Draw open LWPOLYLINEs with positive and negative semicircle bulges. **Actions:** Run `TTLENGTH` on each. **Expected:** both arc lengths equal pi times radius for the same chord/bulge magnitude. **Pass criteria:** no closing chord is included for an open polyline.

## 31. Central unit conversion

**Setup:** Use a disposable project and set matching Imperial or Metric `INSUNITS`. **Actions:** Run `TTUNITS` and `TTUNITCONVERT` for 12 in to 1 ft, 1000 mm to 1 m, and 100 cm to 1 m. **Expected:** resolved drawing units and conversions are exact within display precision. **Pass criteria:** unknown units do not produce a guessed result.

## 32. Plant spacing units

**Setup:** Make equivalent planting areas in inch, foot, millimeter, centimeter, and meter drawings. Enter equivalent explicit spacing strings. **Actions:** Run `TTGROUNDINFO`. **Expected:** equivalent physical areas and spacing produce equivalent density. **Pass criteria:** numeric legacy spacing still behaves as drawing units.

## 33. Plant search and pagination

**Setup:** Active project with the sample catalog. **Actions:** Run `TTPLANTSEARCH`; search partial terms such as `sample tree`, filter categories, page results, and Add. **Expected:** search matches all words across indexed fields; DCL pages contain no more than 30 records (CLI: 20); Add retains the stable Master Plant ID. **Pass criteria:** no raw ID entry is required.

## 34. Favorites and recent plants

**Setup:** Active project. **Actions:** Favorite a search result, filter Favorites, add two plants, save/reopen, and inspect project data. **Expected:** favorite and recent stable IDs persist. **Pass criteria:** favorites do not duplicate Master or Project Palette records.

## 35. User plant library

**Setup:** Active project and writable roaming application-data folder. **Actions:** Run `TTPLANTUSER`, Add a record, reload TerraTools, search it, and add it to a project. **Expected:** the user record survives reload outside the distributed catalog. **Pass criteria:** reinstall-style replacement of `data/` does not remove the user library.

## 36. USDA import pipeline

**Setup:** Download the current official USDA Complete PLANTS Checklist CSV. **Actions:** Run `TTIMPORTUSDA`, choose an output file, attach it with `TTPLANTDATA`, and search a known symbol/name. **Expected:** import reports the real record count and copies only source fields; missing design data stays blank. **Pass criteria:** stable IDs begin with `USDA-PLANTS-`, provenance fields exist, and no images are imported.

## 37. Malformed plant data

**Setup:** Copy a normalized plant file and damage its envelope or a required identity. **Actions:** Attach it with `TTPLANTDATA`. **Expected:** the file is rejected as invalid or empty. **Pass criteria:** the Project Palette and existing attachment list remain unchanged.

## 38. Project Plant source independence

**Setup:** Create a normalized external catalog containing a uniquely identified plant, attach it with `TTPLANTDATA`, add that plant to the Project Plant Palette, and place one instance. **Actions:** Record the Project Plant ID; detach the external catalog; run `TTRELOAD`, `TTPLANTS` List, `TTPLANTINFO`, and `TTVERIFYPLANTS`; then reattach the same catalog and repeat the information and verification commands. **Expected:** after detach, the palette loads, the placed instance still resolves through the unchanged Project Plant ID, project edits remain intact, and diagnostics report `SOURCE UNAVAILABLE`; after reattach, diagnostics report `SOURCE AVAILABLE` without migration. **Pass criteria:** detaching changes only `PLANT_DATA_PATHS`; it does not delete, recreate, or alter the Project Plant or placed entity.

## 39. Office standards exchange

**Setup:** Active project with changed preferences. **Actions:** `TTSTANDARDS` SaveUser, reset project preferences, ApplyUser, Export, then Import the export into another project. **Expected:** validation succeeds and preferences match. **Pass criteria:** existing preference schema remains version 1 and unrelated project fields survive.

## 40. Work Area lifecycle

**Setup:** Two Work Areas, one with assigned objects and one empty. **Actions:** `TTWORKAREAS` Rename, Highlight, Count; attempt to delete both. **Expected:** the dependent area cannot be deleted; the empty area and boundary can be deleted after confirmation. **Pass criteria:** failed project storage restores a boundary deleted during the attempted transaction.

## 41. Reference note Work Area and cost

**Setup:** Reference-note objects split between two Work Areas with unit costs. **Actions:** Create an all-project and a Work Area schedule, edit a code/cost, then update the schedule. **Expected:** scoped quantities and subtotals match assignments and current geometry. **Pass criteria:** curved area/length quantities use bulge-aware geometry.

## 42. Detail validation

**Setup:** Add details with categories, keywords, and one source DWG. **Actions:** Attempt a duplicate number, rename the source file, run Verify, and try removing a placed detail. **Expected:** duplicate Add is refused, missing file is reported, and referenced removal is refused. **Pass criteria:** restoring the source path clears the file issue.

## 43. Lighting transformer capacity

**Setup:** Assign fixtures and a transformer to one circuit. **Actions:** Run `TTTRANSFORMERLOAD` below and above capacity, then `TTVERIFYLIGHTING`. **Expected:** load, capacity, spare watts, and PASS/FAIL are correct. **Pass criteria:** overload is reported without changing entities.

## 44. Lighting voltage drop

**Setup:** Prepare a hand calculation using 100 W, 12 V, 50 ft one-way, and supported copper AWG. **Actions:** Run `TTVOLTAGEDROP`. **Expected:** result matches `2 K I L / CM` with K=12.9 and reports percentage. **Pass criteria:** unsupported AWG and zero voltage are rejected.

## 45. Branched per-pipe irrigation flow

**Setup:** Build one upstream pipe that branches to 3 gpm and 5 gpm heads. **Actions:** Analyze and size each branch and upstream pipe. **Expected:** branch flows are 3 and 5 gpm; upstream flow is 8 gpm. **Pass criteria:** pipe sizing uses those three different flows.

## 46. Merged-path irrigation ambiguity

**Setup:** Draw two directed pipes merging into one downstream node for a station. **Actions:** Analyze, size a pipe, and run a selected critical path. **Expected:** merged-node count is positive and sizing/path calculations stop with an ambiguity message. **Pass criteria:** no diameter is silently changed.

## 47. Foreign-project copy detection

**Setup:** Copy or WBLOCK a smart entity from project A into a DWG associated with project B. **Actions:** Run `TTVERIFY` and `TTRECONCILE`. **Expected:** verification reports a foreign project UUID; reconciliation only repairs duplicate entity UUIDs. **Pass criteria:** TerraTools does not silently adopt or rewrite the foreign catalog identity.

## 48. CSV parser edge cases

**Setup:** Prepare an import CSV with commas, doubled quotes, blank fields, headers, and non-ASCII text. **Actions:** Run `TTQACHECK` and the relevant import in each supported `LISPSYS` setting. **Expected:** structural fields parse correctly; unsupported encoding is reported or documented. **Pass criteria:** no existing record is silently overwritten.

## 49. Large catalog and drawing performance

**Setup:** Attach a legitimate large normalized catalog and prepare drawings with about 1,000, 5,000, and 10,000 smart entities. **Actions:** Time first and repeated plant searches, `TTVERIFY`, and representative schedules. **Expected:** first search builds the index; repeated searches reuse it; drawing scans complete without nested-scan stalls. **Pass criteria:** results stay correct and AutoCAD LT remains responsive enough for review.

## 50. Plant Manager state

**Setup:** Active project and several sample plants.

**Actions:** Search Tree, select a category and add a plant; edit a project plant; remove an unused plant; return after each action.

**Expected:** Manager refreshes data and retains query/category/mode.

**Pass criteria:** No reopening is needed; no raw ID prompt; Esc closes safely.

## 51. Same-source project variants

**Setup:** One project plant with at least one placed instance.

**Actions:** Use New Variant; give a different code, size, spacing, symbol and cost. Repeat through TTPLANTSCLI Add using the same source.

**Expected:** Distinct project IDs share master provenance; edits are independent.

**Pass criteria:** Both variants persist across save/reopen and placements resolve separately.

## 52. Code uniqueness across write paths

**Setup:** Two variants.

**Actions:** Try matching codes with different case and surrounding spaces through DCL and CLI edits and code CSV import; run TTVERIFY.

**Expected:** Central palette save refuses duplicate codes. Existing corrupt duplicates are reported, not deleted.

**Pass criteria:** No valid project record is silently overwritten; IDs remain stable.

## 53. Production database install

**Setup:** Install the optional WFO production folder; use LISPSYS 1 or 2.

**Actions:** TTPLANTDATABASE; inspect manifest and run optional node tools/verify-plants.mjs data/plants/production.

**Expected:** 435702 accepted taxa, 999746 aliases, 435702 descriptions for the documented June build; file checksums pass.

**Pass criteria:** Counts come from manifest; missing package is clearly reported without pretending samples are production data.

## 54. WFO lazy search and provenance

**Setup:** Installed database.

**Actions:** Search Acer rubrum and Quercus alba in Plant Sources, then multiword family/name terms; open Full Details and add a record.

**Expected:** Exact accepted-name result is prioritized; aliases can resolve accepted records; full record loaded on selection.

**Pass criteria:** Project copy persists; description completeness is TAXONOMY_ONLY and no invented cultural facts appear.

## 55. Recent and Favorite browsers

**Setup:** Project with added WFO and sample plants.

**Actions:** Toggle favorites; switch Favorites and Recent Plants; reload; repeat in a second project.

**Expected:** Correct project-owned source IDs resolve; unavailable sources may be omitted.

**Pass criteria:** No favorites/recents leak between projects.

## 56. Density planting area

**Setup:** Feet drawing with 100-square-foot closed boundary.

**Actions:** TTDENSITYAREA, set 2 plants per square foot; inspect quantity, create schedule, enlarge area to 150.

**Expected:** Quantity changes from 200 to 300; a metric-equivalent test agrees.

**Pass criteria:** Record density and stable project identity survive reopen.

## 57. Curved closed-region fill

**Setup:** Closed WCS XY boundary with positive/negative bulges.

**Actions:** TTPLANTFILL using modest count/spacing and recorded seed; repeat and test tilted boundary refusal.

**Expected:** Points stay in supported boundary within documented sampling tolerance; attempts/count bounded.

**Pass criteria:** No outside points; cancellation cleans its created objects; one Undo reverses completed fill.

## 58. Select Similar and Count Selected

**Setup:** Two project plants plus ordinary CAD entities and foreign-project plants.

**Actions:** TTSELECTSIMILAR on one instance; TTCOUNTSELECTED on the returned set.

**Expected:** Selection matches project, module, object type and catalog identity.

**Pass criteria:** Count matches selected instances; foreign objects not selected by similarity.

## 59. Project symbol scale and repair

**Setup:** Place multiple instances of one variant.

**Actions:** TTPLANTSYMBOLS, enter scale 2; inspect new placements and existing INSERT scales; assign a missing generic block and refresh.

**Expected:** Scale persists and generic symbol can be generated; existing user block definitions remain intact.

**Pass criteria:** UUIDs and project links unchanged; custom missing artwork is not claimed as recovered.

## 60. Plant label style and leader

**Setup:** Three plants of one type.

**Actions:** TTLABELSTYLE, choose QUANTITY CODE BOTANICAL_NAME and Leader Yes; label group; erase a plant; refresh labels.

**Expected:** Displayed fields match style and current count; ordinary leader line is created.

**Pass criteria:** Style survives reload; moving targets requires manual leader adjustment, as documented.

## 61. Plant schedule style

**Setup:** Placed plants from two categories, including equal quantities.

**Actions:** TTSCHEDULESTYLE, reorder columns, sort code, group category; create and update schedule; test empty count after erasing all plants.

**Expected:** No equal-valued rows disappear; columns/grouping and empty regenerated result match.

**Pass criteria:** Style survives standards export/import and project reopen.

## 62. Shared manager browsing and editing

**Setup:** Records in each of Work Areas, Reference Notes, Details, Lighting, Irrigation, Stations and Controllers.

**Actions:** Open each manager, search, select, edit, cancel, reopen and use Highlight/Count.

**Expected:** Each displays real project records and saves selected-record edits.

**Pass criteria:** All tile labels legible, keyboard/Esc usable, no raw IDs needed for common actions.

## 63. Active Work Area isolation

**Setup:** Projects A and B each with a Work Area.

**Actions:** TTACTIVEWORKAREA in A; place plants/fixtures through managers; switch to B, place; return to A.

**Expected:** Only A placements inherit A area; B uses its own state or no area.

**Pass criteria:** No foreign area ID is written; TTCOUNTWORKAREA matches A assignments.

## 64. Work Area safe removal and unassignment

**Setup:** One boundary with assignments, another without.

**Actions:** Remove both through manager; unassign objects using TTUNASSIGNWORKAREA and retry.

**Expected:** Dependent removal refused; empty manager removal detaches boundary metadata and retains geometry.

**Pass criteria:** Project record and drawing references stay consistent; CLI delete confirmation behavior is separately checked.

## 65. Reference callouts

**Setup:** Count and length notes with known quantities.

**Actions:** TTREFNOTELABEL; create schedule; edit code/description via manager; TTUPDATEREFNOTELABELS.

**Expected:** Callout updates; adding labels does not increase note quantity.

**Pass criteria:** Label project identity persists and foreign project labels are unchanged. In a disposable project with write access blocked, failed TTREFNOTE storage restores prior geometry metadata.

## 66. User libraries

**Setup:** Project fixture/equipment/detail records, including an old sample with omitted optional fields.

**Actions:** Manager Library Save, Export, Import, Add into a second project; edit new copy.

**Expected:** Validated independent project copy gets new identity and source provenance; library stays unchanged.

**Pass criteria:** Malformed library import refused; existing user records never overwritten silently.

## 67. Detail relink and duplicate number

**Setup:** Two project detail records and one optional source DWG.

**Actions:** Edit source path/category/keywords in manager; search; attempt duplicate number via TTDETAILRENUMBER.

**Expected:** Source status updates; duplicate renumber refused; callouts use current number after explicit refresh/renumber.

**Pass criteria:** No claim that a demo frame imports source artwork.

## 68. Lighting match and scoped schedule

**Setup:** Two fixture types across two Work Areas and a circuit.

**Actions:** TTMATCHFIXTURE on selected targets; TTCOUNTLIGHTING; create WorkArea lighting schedule and refresh it.

**Expected:** Target identity/transform/circuit retained; only fixture link/block changes; scoped totals/costs agree.

**Pass criteria:** Foreign fixtures remain unchanged; schedule scope survives reopen.

## 69. Stations and controllers

**Setup:** Create controller capacity 2, two stations.

**Actions:** Assign output 1 to each; try output 3, reduce capacity, rename referenced controller, remove referenced controller.

**Expected:** Duplicate output, excess capacity and unsafe rename/remove refused.

**Pass criteria:** Valid output 2 persists; unused records can be removed after checking other DWGs.

## 70. Actual inside diameter and pipe classes

**Setup:** Active project with resolved units.

**Actions:** TTPIPECLASSES Add 1:1.049 1.25:1.380 with verified C/material; TTPIPE; reload and inspect.

**Expected:** Nominal and actual diameters distinct; legacy class identity still resolves.

**Pass criteria:** Hydraulics uses actual ID; missing actual ID explicitly uses legacy nominal assumption.

## 71. Sizing scopes and manual protection

**Setup:** POC tree with 3/5 gpm branches and class sizes.

**Actions:** Run Recommend, Single, Selection, Station and Network; mark some pipes Automatic with TTPIPEAUTO; keep others Manual.

**Expected:** Flows are 3,5,8; only Automatic pipes change; no passing class reports failure.

**Pass criteria:** Manual sizes unchanged; no size changes for invalid topology.

## 72. Coverage arc persistence

**Setup:** Placed head with rotated INSERT.

**Actions:** TTIRRIGATIONCOVERAGE radius 10, sweep 90; save/reopen; move/rotate head; TTUPDATECOVERAGE; repeat full circle.

**Expected:** Radius/sweep persist; ARC/CIRCLE tracks head; old helper removed only after replacement.

**Pass criteria:** Exactly one replacement per head; unrelated geometry remains.

## 73. Drip area demand

**Setup:** 100-square-unit area, row spacing 2, emitter spacing 1, emitter flow 0.5 gph.

**Actions:** TTDRIPAREA; pressure 30 psi; assign station and connect inlet at first vertex; reopen and analyze.

**Expected:** 50 emitters, 25 gph, 0.4166667 gpm; pressure persists.

**Pass criteria:** Geometry edits require explicit untag/recreate recalculation and documentation says so.

## 74. Metric hydraulic equivalence

**Setup:** Equivalent physical US and SI inputs.

**Actions:** TTHYDRAULIC and TTHYDRAULICMETRIC, including positive/negative elevation.

**Expected:** Converted friction, velocity and total loss agree within displayed precision.

**Pass criteria:** No separate drifting metric formula; zero diameter rejected.

## 75. Graph pressure and critical path

**Setup:** POC, branch tree, terminal demands and known elevations/losses.

**Actions:** TTQACHECK; analyze station; TTAUTOCRITICALPATH with known source pressure; reverse one pipe and rerun.

**Expected:** TO-demand flows and pressure margins match hand calculation; reversed/orphan branch refused.

**Pass criteria:** Loop/merge/multiple-source/disconnected tests all refuse automatic results.

## 76. Deliberate backup recovery

**Setup:** Valid backup; damaged current file; drawing association with known UUID.

**Actions:** TTRECOVERPROJECT; first cancel, then Restore; repeat with different-UUID backup.

**Expected:** Cancel changes nothing; restore archives old file and keeps backup; mismatch refused.

**Pass criteria:** Known-good copies survive failures; no automatic overwrite.

## 77. Migration and package safety

**Setup:** Current schema project with unknown compatible fields and optional detail resource.

**Actions:** TTPROJECTMIGRATE; TTPACKAGE Create new folder with selected resource; Open manifest; try traversal manifest and existing destination.

**Expected:** Identity migration makes no write; UUID/unknown fields preserved; only selected resource copied; unsafe paths refused.

**Pass criteria:** Original project unchanged and package can be explicitly reopened after moving.

## 78. Foreign adoption boundaries

**Setup:** Foreign plants with both resolvable and missing project IDs, plus foreign labels/mixes/pipes.

**Actions:** TTADOPT selected objects; inspect UUID/project/catalog/Work Area.

**Expected:** Only supported resolvable records adopt with new entity UUID; unsupported composites stay foreign.

**Pass criteria:** No dangling catalog references manufactured; unresolved area links and circuit/station assignments are cleared only on adopted objects. Reassign those links in the current project.

## 79. Multi-drawing project state

**Setup:** Two open drawings/projects, distinct favorites, catalog paths, active areas and preferences.

**Actions:** Cycle A to B to A, reload each, use managers, source search, counts, labels and schedules.

**Expected:** ProjectRefresh validates each drawing association; project context and search data remain isolated.

**Pass criteria:** No file writes or metadata links target the other project.

## 80. Measured performance and cleanup

**Setup:** Disposable empty drawing; installed WFO package.

**Actions:** Load tools/benchmark.lsp; run (TT:RunBenchmark); capture 1000/5000/10000 scan and reconciliation times; cancel a second run.

**Expected:** Actual times reported; only benchmark-created entities removed on finish or error.

**Pass criteria:** No fixture remains and no project is modified; retain machine/LT/version context with results.

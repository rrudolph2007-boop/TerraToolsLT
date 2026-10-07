# TerraTools LT User Guide

Version 0.12.0-rc1. Load TerraTools.lsp with APPLOAD, then type TT. The main DCL launcher opens the product areas. TTRELOAD loads the same installation after source changes. See README.md for trusted paths and startup loading.

## Getting started

Type TT to open Home. The top shows your project, drawing units, the Work Area for new placements, and installed plant database status. Choose Project to create or open a project. Gray production buttons need a readable project; Plant Library browsing and Recovery are still available. Home returns after a task, so Close is the explicit exit.

Use Plants to open the Plant Manager, or choose a design module. Each manager has a search above its list, a selected-record panel, primary actions and a Tools button. Search is the safe default for Enter. Esc closes a manager without changing records. Save applies editor changes; Cancel discards them. Tools shows a task explanation before Continue starts its existing command. Some tasks then ask for input at the AutoCAD command line.

## Projects and production settings

TTPROJECT offers Create, Open, Info and Close. Each project owns an external terratools-project.dat file. Save the DWG to preserve its project UUID/path. Close disassociates the drawing without deleting the project. TTPROJECTINFO and TTDEBUG read the actual external file; missing files and UUID mismatches remain unresolved until corrected or explicitly reopened.

TTPREFERENCES, TTLAYERS, TTSCALE and TTUNITS control project settings. TTSTANDARDS exchanges validated user office standards, including plant label/schedule styles. Most geometry commands still use drawing units; setting scale does not automatically scale every annotation.

TTWORKAREAS opens the Work Area manager. Add creates a closed boundary record; Assign assigns selected current-project objects. Referenced areas cannot be removed. Manager removal keeps boundary geometry and removes its TerraTools tag. The older TTWORKAREASCLI Delete action can erase the boundary after confirmation. TTACTIVEWORKAREA selects the area inherited by subsequent supported placements; Enter clears it. TTUNASSIGNWORKAREA clears selected current-project assignments. Work Areas use explicit assignment, not inferred containment.

## Planting: Project Plants and Plant Library

Plant Library means source records available to add. Project Plants means editable copies owned by this project and used in your design. Built-in samples are fictional demonstrations, not the complete library.

TTPLANTS opens the Plant Manager. The Available plant data panel is always visible. With the documented WFO package installed, it reads "435,702 plants available" and identifies WFO-2026-06. This count comes from the installed package. A separate notice identifies the built-in sample library; sample rows carry SAMPLE, including project copies of those samples.

To find a plant, choose Search Plant Library, enter a name such as Acer rubrum, keep All categories and click Search (or Enter). Choose a result, review the selected-plant panel and click Add to Project. Enter a unique project code and design category, then Save. The status line confirms the botanical name and code. Choose Project Plants to place or edit your copy.

A library view without a search initially shows sample/user records only and explains that at least two letters are needed for open-database search. WFO has no TerraTools design categories: a Tree/Shrub filter excludes it, and the status line tells you to choose All categories. If the optional database is missing, the banner says it is unavailable and points to installation help through Tools > Plant libraries. It never describes the sample list as the full database.

Project Plants stays usable when its original library is detached. The selection panel explains that the original source is unavailable while the project copy remains usable. New Variant makes an independent design copy; choose a distinct code. Duplicate code errors stay in the editor so you can correct them without losing other fields.

Favorites and Recent are project-owned lists of library choices. Add, Edit, Favorite and Variant retain the manager's current search, category, mode and page. Empty or filtered views explain the next step. Place/Edit/Variant/Remove apply to Project Plants; Add to Project applies to library views. Without a project, only browsing and Details are available.

The distributed catalog contains 15 fictional samples. The optional WFO package contains 435,702 accepted taxa, searchable by name/family/synonym token prefixes. It has taxonomy-only descriptions, not horticultural recommendations. Install it as described in PLANT_DATABASE.md. TTPLANTDATABASE reports its manifest. TTPLANTSEARCH opens the library view directly; TTPLANTSEARCHCLI provides the command-line fallback. Broad WFO queries cap displayed matches; refine the words.

TTPLANTUSER manages custom source plants. TTIMPORTUSDA accepts CSV and normalizes supplied checklist facts. TTPLANTDATA attaches/detaches normalized catalogs. Adding a source with no usable category asks you to classify its project copy. Detaching or deleting a source does not invalidate existing project plants or placed instances. Reattaching restores provenance resolution. Project edits remain authoritative. Reload after editing a catalog externally.

## Planting output

TTPLACEPLANT supports repeated point placement. TTPLANTPATH places along LINE, ARC and supported bulged polylines. TTPLANTARRAY and TTPLANTRANDOM provide rectangular patterns. TTPLANTFILL uses a bounded seeded fill inside a supported closed WCS XY boundary; it refuses unsupported tilted boundaries. TTGROUND uses square or triangular spacing; TTDENSITYAREA uses density. Dimension prompts support explicit units. TTMIX, TTMIXEDIT and TTMIXAREA create and apply project mixes.

TTSELECTSIMILAR and TTCOUNTSELECTED operate on selected plant identity. TTPLANTSYMBOLS changes project symbol scale or repairs default assignments. Missing custom artwork must be supplied by the user.

TTLABELSTYLE and TTSCHEDULESTYLE edit plant output styles. TTUPDATEPLANTLABELS and TTUPDATEPLANTSCHEDULE rebuild derived output. Optional label leaders are static lines and do not follow a moved label automatically. Schedules are ordinary MTEXT. Run TTVERIFYPLANTS and TTRECONCILE before issue. Sample costs are demonstration values.

## Shared managers, Site and Details

Shared searchable managers are TTWORKAREAS, TTREFNOTES, TTDETAILS, TTLIGHTING, TTIRRIGATION, TTSTATIONS and TTCONTROLLERS. Select a record before Edit, Remove, Place or Assign, or Highlight. Tools opens named workflows with short explanations. Controllers use Stations for output assignments, so their Place and Highlight buttons are disabled. Details, Lighting and Irrigation managers have a Library action for validated, separate user records and project-owned copies.

TTREFNOTE creates a reference record and tags geometry. TTREFNOTELABEL places a callout, TTUPDATEREFNOTELABELS refreshes callouts, and TTREFNOTESCHEDULE produces cost/quantity output with optional Work Area scope. Callout entities do not count as source quantities. TTAREA, TTLENGTH, TTVOLUME, TTSLOPE, TTBEARINGDIST and TTUNITCONVERT are measurement helpers, not a Civil 3D surface engine.

TTDETAILS manages searchable metadata, category, keywords, source paths and numbers. Verification reports missing sources and duplicate numbers. TTDETAILRENUMBER refuses collisions. Placement currently produces an original sample frame, not the contents of the source DWG. TTCALLOUT and TTDETAILINDEX create derived output. Source relinking does not replace already placed graphics.

## Lighting

TTLIGHTING manages fixtures and supports continuous manager placement. TTMATCHFIXTURE copies a project fixture choice onto selected current-project fixtures while retaining instance identity and transforms. TTCOUNTLIGHTING reports counts; the manager highlights a selected record. Circuit and transformer commands calculate connected watt totals and capacity. TTVOLTAGEDROP is a copper two-conductor estimate, not an electrical-code determination.

TTLIGHTINGSCHEDULE creates a derived schedule with optional Work Area scope. TTUPDATEEQUIPMENTSCHEDULE rebuilds an existing equipment schedule from its stored scope. Its columns are fixed. Lighting catalog values are fictional and need project verification.

## Irrigation

Use TTIRRIGATION for project equipment and user libraries. Its Tools menu presents Equipment, Stations, Controllers, Pipe Classes, Draw Pipes, Verify, Analyze, Size and Pressure in working order. Coverage, drip and schedules are listed below those steps. The selected station shows its controller/output; controller selection shows capacity. Draw pipes from upstream to downstream. TTREVERSEPIPE deliberately reverses a selected pipe. TTNETWORKTOLERANCE controls endpoint matching in resolved drawing units. TTIRRIGATIONANALYZE builds the directed graph and derives each edge's downstream TO-node flow. Loops, merges, disconnected demand, multiple sources and unresolved units stop automatic engineering output.

TTPIPECLASSES stores material, C factor and nominal:inside diameter pairs. TTPIPE creates class-based pipes. TTSIZEPIPE recommends a class size from explicit inputs. TTIRRIGATIONSIZE supports Recommend, Single, Selection, Station and Network. TTPIPEAUTO explicitly enables or disables automatic sizing on selected pipes. Manual sizes are retained. A class with no passing size reports failure rather than silently choosing an inadequate diameter.

TTSTATIONS and TTCONTROLLERS manage names, outputs and capacities. Duplicate outputs and insufficient capacity are rejected. Rename is refused because names are references; create a new record and explicitly reassign uses. Referenced records cannot be removed. TTZONEINFO and TTCRITICALPATH route to graph-based reports; TTAUTOCRITICALPATH reports node pressure and the limiting terminal route. Pressure includes friction, elevation and inline equipment loss.

TTIRRIGATIONCOVERAGE stores radius and sweep; TTUPDATECOVERAGE rebuilds circles/arcs from head position/rotation. TTDRIPAREA derives demand from boundary area, row/emitter spacing and emitter flow. After geometry changes, remove its TerraTools tag and rerun the command to recalculate. TTHYDRAULICMETRIC converts SI inputs through the same hydraulic core. Read HYDRAULICS.md for assumptions and limits. Irrigation schedules support station or Work Area scope and use TTUPDATEEQUIPMENTSCHEDULE for refresh.

## Recovery and exchange

Home > Recovery explains Inspect, Open moved project, Restore backup and Package before each task starts. TTRECOVERPROJECT offers deliberate restoration from a validated .bak file. It preserves the current file under a unique unrecovered name and retains the backup. Inspect paths and UUID before confirming. TTPROJECTMIGRATE checks schema 1; unsupported schemas are refused.

TTPACKAGE Create writes a new folder, manifest and only selected resources. The source project remains active. Copy the DWG separately. Explicitly packaged detail paths become relative; unselected external links are unchanged. Open selects the package manifest and validates it before changing the DWG link. Moved ordinary project folders must be reopened explicitly.

TTADOPT accepts only supported foreign plants/fixtures/equipment when their project record IDs already resolve. It gives adopted instances fresh UUIDs, clears station/circuit assignments and unresolved Work Area links, and refuses dependent composites such as labels, mixes and pipes. Reassign those operational links in the current project. Xrefs remain read-only.

## Checks before issue

Run TTRELOAD, TTDEVSMOKE, TTQACHECK, TTVERIFY and relevant module checks. Smoke and QA do not create drawing objects or alter the project. Reconciliation is an explicit repair operation.

LT 2027 Core Console checks passed during closure. DCL rendering, actual selection workflows, Undo, multiple open drawings, trusted loading and LT 2024-2026 remain acceptance gates. Follow the 80 engineering scenarios and 15 UX scenarios in ../ACCEPTANCE_TESTS.md. Deferred features and limits are recorded in ../PARITY_MATRIX.md.

## Work Areas and manager feedback

Home and placement managers show "New placements" with the active Work Area name. Change Work Area opens the existing selector; Enter clears the active area. This affects subsequent supported placements, not existing objects. Use Assign for existing objects; schedules filter those explicit assignments.

Empty Work Area, reference, detail, fixture, equipment, station and controller managers explain how to start. Clear removes a search filter without removing data. Remove names the selected record and asks for confirmation; dependency checks remain in place. Placement/assignment feedback counts only successful object changes and reports skipped objects. Record changes are reported only after saved project data changes. Technical fields are available in Details, not in normal list rows.

Planting Tools exposes path/fill/array/area placement, mixes, labels, selection/count tools, symbols, styles and verification. Home > Schedules / Reports provides both creation and refresh tasks. Home > Verify / Diagnostics puts read-only verification before repair actions. TTHELP lists current workflow commands with explanations.

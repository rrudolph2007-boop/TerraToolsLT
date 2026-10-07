# TerraTools LT User Guide

Version 0.12.0-rc1. Load TerraTools.lsp with APPLOAD, then type TT. The main DCL launcher opens the product areas. TTRELOAD loads the same installation after source changes. See README.md for trusted paths and startup loading.

## Projects and production settings

TTPROJECT offers Create, Open, Info and Close. Each project owns an external terratools-project.dat file. Save the DWG to preserve its project UUID/path. Close disassociates the drawing without deleting the project. TTPROJECTINFO and TTDEBUG read the actual external file; missing files and UUID mismatches remain unresolved until corrected or explicitly reopened.

TTPREFERENCES, TTLAYERS, TTSCALE and TTUNITS control project settings. TTSTANDARDS exchanges validated user office standards, including plant label/schedule styles. Most geometry commands still use drawing units; setting scale does not automatically scale every annotation.

TTWORKAREAS opens the Work Area manager. Add creates a closed boundary record; Place/Assign assigns selected current-project objects. Referenced areas cannot be removed. Manager removal keeps boundary geometry and removes its TerraTools tag. The older TTWORKAREASCLI Delete action can erase the boundary after confirmation. TTACTIVEWORKAREA selects the area inherited by subsequent supported placements; Enter clears it. TTUNASSIGNWORKAREA clears selected current-project assignments. Work Areas use explicit assignment, not inferred containment.

## Plant data and Project Palette

TTPLANTS opens the Plant Manager. Choose Project Plants, Plant Sources, Favorites or Recent Plants, enter search text and use pages to choose a record. Add makes a project-owned copy. Edit changes that copy. Variant retains source provenance but creates a new project identity and distinct plant code. Every palette write rejects duplicate project IDs or case-insensitive plant codes. Multiple variants may share a Master Plant ID.

The distributed catalog contains 15 fictional samples. The optional WFO package contains 435,702 accepted taxa, searchable by name/family/synonym token prefixes. It has taxonomy-only descriptions, not horticultural recommendations. Install it as described in PLANT_DATABASE.md. TTPLANTDATABASE reports its manifest. TTPLANTSEARCH remains a command-line search entry point. Broad WFO queries cap displayed matches; refine the words.

TTPLANTUSER manages custom source plants. TTIMPORTUSDA accepts CSV and normalizes supplied checklist facts. TTPLANTDATA attaches/detaches normalized catalogs. Adding a source with no usable category asks you to classify its project copy. Detaching or deleting a source does not invalidate existing project plants or placed instances. Reattaching restores provenance resolution. Project edits remain authoritative. Reload after editing a catalog externally.

## Planting output

TTPLACEPLANT supports repeated point placement. TTPLANTPATH places along LINE, ARC and supported bulged polylines. TTPLANTARRAY and TTPLANTRANDOM provide rectangular patterns. TTPLANTFILL uses a bounded seeded fill inside a supported closed WCS XY boundary; it refuses unsupported tilted boundaries. TTGROUND uses square or triangular spacing; TTDENSITYAREA uses density. Dimension prompts support explicit units. TTMIX, TTMIXEDIT and TTMIXAREA create and apply project mixes.

TTSELECTSIMILAR and TTCOUNTSELECTED operate on selected plant identity. TTPLANTSYMBOLS changes project symbol scale or repairs default assignments. Missing custom artwork must be supplied by the user.

TTLABELSTYLE and TTSCHEDULESTYLE edit plant output styles. TTUPDATEPLANTLABELS and TTUPDATEPLANTSCHEDULE rebuild derived output. Optional label leaders are static lines and do not follow a moved label automatically. Schedules are ordinary MTEXT. Run TTVERIFYPLANTS and TTRECONCILE before issue. Sample costs are demonstration values.

## Shared managers, Site and Details

Shared searchable managers are TTWORKAREAS, TTREFNOTES, TTDETAILS, TTLIGHTING, TTIRRIGATION, TTSTATIONS and TTCONTROLLERS. Select a record before Edit, Remove, Place/Assign or Highlight. More opens additional commands where supplied. Details, Lighting and Irrigation managers have a Library action for validated, separate user records and project-owned copies.

TTREFNOTE creates a reference record and tags geometry. TTREFNOTELABEL places a callout, TTUPDATEREFNOTELABELS refreshes callouts, and TTREFNOTESCHEDULE produces cost/quantity output with optional Work Area scope. Callout entities do not count as source quantities. TTAREA, TTLENGTH, TTVOLUME, TTSLOPE, TTBEARINGDIST and TTUNITCONVERT are measurement helpers, not a Civil 3D surface engine.

TTDETAILS manages searchable metadata, category, keywords, source paths and numbers. Verification reports missing sources and duplicate numbers. TTDETAILRENUMBER refuses collisions. Placement currently produces an original sample frame, not the contents of the source DWG. TTCALLOUT and TTDETAILINDEX create derived output. Source relinking does not replace already placed graphics.

## Lighting

TTLIGHTING manages fixtures and supports continuous manager placement. TTMATCHFIXTURE copies a project fixture choice onto selected current-project fixtures while retaining instance identity and transforms. TTCOUNTLIGHTING reports counts; the manager highlights a selected record. Circuit and transformer commands calculate connected watt totals and capacity. TTVOLTAGEDROP is a copper two-conductor estimate, not an electrical-code determination.

TTLIGHTINGSCHEDULE creates a derived schedule with optional Work Area scope. TTUPDATEEQUIPMENTSCHEDULE rebuilds an existing equipment schedule from its stored scope. Its columns are fixed. Lighting catalog values are fictional and need project verification.

## Irrigation

Use TTIRRIGATION for project equipment and user libraries. Draw pipes from upstream to downstream. TTREVERSEPIPE deliberately reverses a selected pipe. TTNETWORKTOLERANCE controls endpoint matching in resolved drawing units. TTIRRIGATIONANALYZE builds the directed graph and derives each edge's downstream TO-node flow. Loops, merges, disconnected demand, multiple sources and unresolved units stop automatic engineering output.

TTPIPECLASSES stores material, C factor and nominal:inside diameter pairs. TTPIPE creates class-based pipes. TTSIZEPIPE recommends a class size from explicit inputs. TTIRRIGATIONSIZE supports Recommend, Single, Selection, Station and Network. TTPIPEAUTO explicitly enables or disables automatic sizing on selected pipes. Manual sizes are retained. A class with no passing size reports failure rather than silently choosing an inadequate diameter.

TTSTATIONS and TTCONTROLLERS manage names, outputs and capacities. Duplicate outputs and insufficient capacity are rejected. Rename is refused because names are references; create a new record and explicitly reassign uses. Referenced records cannot be removed. TTZONEINFO and TTCRITICALPATH route to graph-based reports; TTAUTOCRITICALPATH reports node pressure and the limiting terminal route. Pressure includes friction, elevation and inline equipment loss.

TTIRRIGATIONCOVERAGE stores radius and sweep; TTUPDATECOVERAGE rebuilds circles/arcs from head position/rotation. TTDRIPAREA derives demand from boundary area, row/emitter spacing and emitter flow. After geometry changes, remove its TerraTools tag and rerun the command to recalculate. TTHYDRAULICMETRIC converts SI inputs through the same hydraulic core. Read HYDRAULICS.md for assumptions and limits. Irrigation schedules support station or Work Area scope and use TTUPDATEEQUIPMENTSCHEDULE for refresh.

## Recovery and exchange

TTRECOVERPROJECT offers deliberate restoration from a validated .bak file. It preserves the current file under a unique unrecovered name and retains the backup. Inspect paths and UUID before confirming. TTPROJECTMIGRATE checks schema 1; unsupported schemas are refused.

TTPACKAGE Create writes a new folder, manifest and only selected resources. The source project remains active. Copy the DWG separately. Explicitly packaged detail paths become relative; unselected external links are unchanged. Open selects the package manifest and validates it before changing the DWG link. Moved ordinary project folders must be reopened explicitly.

TTADOPT accepts only supported foreign plants/fixtures/equipment when their project record IDs already resolve. It gives adopted instances fresh UUIDs, clears station/circuit assignments and unresolved Work Area links, and refuses dependent composites such as labels, mixes and pipes. Reassign those operational links in the current project. Xrefs remain read-only.

## Checks before issue

Run TTRELOAD, TTDEVSMOKE, TTQACHECK, TTVERIFY and relevant module checks. Smoke and QA do not create drawing objects or alter the project. Reconciliation is an explicit repair operation.

LT 2027 Core Console checks passed during closure. DCL rendering, actual selection workflows, Undo, multiple open drawings, trusted loading and LT 2024-2026 remain acceptance gates. Follow the 80 scenarios in ../ACCEPTANCE_TESTS.md. Deferred features and limits are recorded in ../PARITY_MATRIX.md.

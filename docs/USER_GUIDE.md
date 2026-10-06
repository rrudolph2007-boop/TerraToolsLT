# TerraTools LT User Guide

Load `TerraTools.lsp` with APPLOAD, then run `TT`. The main dialog opens Project, Planting, Site, Details, Lighting, Irrigation, Schedules, Standards, Data, Diagnostics, and Help. If DCL cannot load, the same choices remain available at the command line.

## Start a project

Run `TTPROJECT` and choose Create or Open. A project is an external `terratools-project.dat` file associated with the current DWG. `TTPROJECTINFO` reports its status. `TTPREFERENCES`, `TTLAYERS`, `TTSCALE`, and `TTUNITS` set or inspect project production values.

`TTSTANDARDS` saves the active project preferences as a roaming user standard, applies that standard, or exchanges a validated standard file. Use `TTWORKAREAS` to list, create, assign, rename, delete, highlight, and count Work Areas. Deletion is refused while smart objects depend on the area. Explicit assignment is authoritative.

## Plant data and palettes

The shipped Master Catalog contains 15 fictional test records. `TTPLANTSEARCH` searches code, botanical name, common name, family, source, notes, and other normalized fields. Results are limited to 20 per page. Add copies the selected stable Master Plant identity into the Project Plant Palette. Favorite and recent IDs are stored in the project.

`TTPLANTUSER` adds custom records to a user library under the Windows roaming application-data folder. It never edits the distributed catalog. `TTIMPORTUSDA` converts a user-downloaded USDA Complete PLANTS Checklist CSV to a normalized TerraTools file. `TTPLANTDATA` attaches or detaches normalized catalogs. If a source lacks a TerraTools category, the user classifies a plant before adding it to a project.

The in-memory search index is built on first use. Reload TerraTools after editing an attached file outside the application.

## Planting production

`TTPLACEPLANT` places individual smart INSERTs. `TTPLANTPATH` supports LINE, ARC, and straight or bulged LWPOLYLINE paths with fixed or equal spacing. `TTPLANTARRAY` makes rectangular arrays. `TTPLANTRANDOM` scatters plants in a rectangle with controlled symbol scale and rotation.

`TTGROUND` attaches a project plant to a closed LWPOLYLINE using square or triangular spacing. Spacing strings can use inches, feet, millimeters, centimeters, or meters. Numeric legacy spacing remains drawing units. Curved boundaries use bulge-aware area and perimeter math.

`TTMIX` creates reusable mixes with 2 through 20 unique project plants. Percent mode requires a total of 100. Ratio mode normalizes positive ratios to percentages. `TTMIXEDIT` replaces a composition while retaining its identity. `TTMIXAREA` assigns it to a boundary.

Plant labels and schedules are derived. Refresh them with `TTUPDATEPLANTLABELS` and `TTUPDATEPLANTSCHEDULE`. Run `TTVERIFYPLANTS` and `TTRECONCILE` before issue. Costs stay in project records; sample values are demonstrations.

## Site and details

`TTREFNOTE` creates notation, count, length, area, volume, amenity, material, or hardscape records. A reference schedule can cover the drawing or one Work Area and includes project cost subtotals. `TTREFNOTEEDIT` changes code, description, and unit cost.

`TTAREA`, `TTLENGTH`, and `TTVOLUME` read current geometry. `TTSLOPE` reports percent and ratio. `TTBEARINGDIST` reports distance and azimuth clockwise from north. `TTUNITCONVERT` uses the central unit engine.

`TTDETAILS` lists, adds, edits, removes, and verifies project detail records. Records can include category, keywords, notes, and a source DWG. Duplicate numbers are refused on Add. Verification reports duplicates and missing source files. Referenced details cannot be removed. `TTPLACEDETAIL`, `TTCALLOUT`, `TTDETAILRENUMBER`, and `TTDETAILINDEX` produce drawing output.

## Lighting

`TTLIGHTING` manages the Project Fixture Palette and provides placement, replacement, wires, transformers, circuits, loads, schedules, and verification. `TTTRANSFORMERLOAD` compares fixture watts with transformer capacity on the same circuit. `TTVOLTAGEDROP` is a transparent copper two-conductor estimate for supported AWG sizes. Included fixture data is fictional.

## Irrigation

Draw each smart LINE from upstream to downstream. Equipment contributes explicit demand at snapped endpoints. `TTIRRIGATIONANALYZE` derives downstream flow separately for every pipe. Loops, merged incoming paths, disconnected demand, and unresolved units are reported. `TTIRRIGATIONSIZE` stops on ambiguous topology and asks before applying a diameter. `TTCRITICALPATH` uses each selected pipe's actual downstream flow, but path selection remains user-assisted.

Hydraulic calculations use US customary engineering units. Drawing lengths are converted to feet through the central unit system. Read `HYDRAULICS.md` before relying on results.

## Diagnostics

`TTVERIFY` reports malformed metadata, duplicate UUIDs, unknown types, missing project UUIDs, and foreign-project objects. `TTRECONCILE` gives duplicated instances fresh UUIDs. It does not guess how foreign catalog links should be reassociated.

`TTQACHECK` runs deterministic read-only math, unit, CSV, geometry, density, and hydraulic checks. `TTDEVSMOKE` checks installed modules and the current project. `TTRELOAD` reloads the exact installation root. `TTHELP` prints short module command lists.

Schedules use ordinary MTEXT. Symbols are original simple blocks generated in the DWG. Xrefs remain read-only. New parity-sprint code has not been claimed as runtime-tested in AutoCAD LT; use `ACCEPTANCE_TESTS.md` as the release gate.

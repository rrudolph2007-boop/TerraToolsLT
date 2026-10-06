# Completion sprint state

Branch: feature/terratools-full-build. Baseline working tree was clean.
No commit, push, merge, rebase, reset, or discard is authorized.

Request: 108-phase completion sprint in the 2026-10-06 attachment. Engineering
and product requirements remain authoritative. Runtime completion must not be
inferred from static checks. Existing source-independent project copies must survive.

## Active queue

1. Audit existing implementation and all remaining parity rows.
2. Correct identity variants, strict input parsing, geometry/coordinate safety,
   hydraulic units, persistence and cache isolation before adding breadth.
3. Build reproducible licensed plant data, descriptions, compact search index,
   manifest and lazy record access; measure actual results.
4. Productize plant search/palette and shared managers with DCL and CLI fallbacks.
5. Complete feasible geometry, planting, shared schedules and network workflows.
6. Add migration/recovery and safe portability where verified.
7. Audit Lisp syntax, loader, commands and DCL; run deterministic tests and real
   AutoCAD LT Core Console checks where available. GUI acceptance stays separate.
8. Update parity, acceptance, guides, release checklist and final report with
   exact remaining blockers. Do not mark placeholders complete.

## Resume reconciliation, checkpoint 519d92d

The working tree was clean on resume. The production database DOES exist locally:
435,702 accepted taxa, 999,746 linked aliases, 435,702 taxonomy-only descriptions.
Previous LT 2027 Core Console runs passed core QA, smoke, project lifecycle,
source-independent variants, backup recovery, branched graph and pressure tests.
WFO name search measured 484 ms once. DCL load returned -1 in Core Console;
GUI rendering and interaction are not verified.

| Capability | Stale matrix | Actual code | Remaining integration/UX/test/docs |
|---|---|---|---|
| Plant manager | MISSING | DCL browser/editor exists | GUI acceptance; retain filters after actions |
| Variants | one master per project | project IDs unique, master IDs may repeat | CLI Add and write-wide code guards |
| Duplicate code | MISSING | DCL save guard | CLI/import/verification coverage |
| Polygon fill | MISSING | bounded seeded XY fill | GUI/Undo/curved-boundary acceptance |
| Select Similar / Count Selected | PARTIAL/MISSING | commands loaded | document and add acceptance |
| Directed graph / pressure / critical path | MISSING | operation-local graph and command | broaden pure QA and integration |
| Pipe reversal / tolerance | MISSING/fixed | commands loaded | documentation and acceptance |
| Recovery | automatic backup only | deliberate recovery command | more failure/UUID tests and docs |
| Open database | whole-file index | real sharded build installed | checksums/package/search ranking tests |

Remaining queue includes labels/schedules/styles, module managers, layer roles,
irrigation classes/sizing/stations/controllers, migration/portability, expanded QA,
60-90 acceptance scenarios, and truthful final parity/release documentation.

## Original audit findings (resolved items retained as history)

- Palette source independence exists, but duplicate MASTER_PLANT_ID validation
  still blocks deliberate project variants.
- Search eagerly materializes all records on first search; no production artifact.
- Hazen-Williams uses 4.52 as feet of head, then divides by 2.31. Review units.
- Dimension parser uses atof and accepts malformed numeric prefixes.
- Storage reads a single expression without rejecting trailing expressions.
- GUI acceptance, version coverage and large-drawing performance are unverified.

## Verification

Optional build tooling may use Node.js; AutoCAD LT runtime remains AutoLISP/DCL.
Continue from this checkpoint, do not restart or discard working systems.

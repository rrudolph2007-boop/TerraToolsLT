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

## Audit findings

- Palette source independence exists, but duplicate MASTER_PLANT_ID validation
  still blocks deliberate project variants.
- Search eagerly materializes all records on first search; no production artifact.
- Hazen-Williams uses 4.52 as feet of head, then divides by 2.31. Review units.
- Dimension parser uses atof and accepts malformed numeric prefixes.
- Storage reads a single expression without rejecting trailing expressions.
- GUI acceptance, version coverage and large-drawing performance are unverified.

## Verification

No new implementation tests have run yet. Optional build tooling may use Node.js;
AutoCAD LT runtime must remain AutoLISP/DCL only.

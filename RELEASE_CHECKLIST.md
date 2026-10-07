# Release checklist: 0.12.0-rc1

Closure date: 2026-10-06. This is a repository handoff for acceptance, not permission to publish or a GUI acceptance sign-off.

| Gate | Current evidence / required action |
|---|---|
| Git status/diff | Reviewed on feature/terratools-full-build against d1ea1e7; changes remain uncommitted. No commit, push or merge. |
| Lisp static audit | tools/check-lisp.mjs: 58 Lisp files, 652 unique functions, zero errors. Reader, definitions, direct TT calls and explicit loader file inventory checked. |
| Loader | All explicit modules exist; dependency order reviewed; exact-root reload and module diagnostics exercised in LT 2027 Core Console. Readiness cleared on failure. |
| TTRELOAD | Passed in LT 2027 Core Console. Repeat in trusted GUI installation with SECURELOAD enabled. |
| TTDEVSMOKE | Passed in LT 2027 Core Console; retain read-only behavior in GUI project/no-project cases. |
| TTQACHECK | Passed deterministic units, dimensions, geometry/bulges/containment, density, CSV, storage, hydraulics, sizing, graph, pressure, critical-path, migration and search checks. |
| Foundation regression | 27 checks passed, zero failures; DCL load separately SKIP. Includes lifecycle, source independence, recovery and real WFO search/lookup. |
| Completion regression | 23 checks passed, zero failures. Includes central duplicate-code save guard, package reopen, controller outputs, library normalization, duplicate reconciliation and coverage/pressure XData round trip. |
| DCL inventory | 3 files, 6 dialog definitions, zero static errors. Product and minimal control load_dialog both returned -1 in Core Console; visible rendering is NOT RUN. |
| Production database | Full verifier passed on current local WFO package; exact counts/checksums/install procedure in docs/PLANT_DATABASE.md. Generated data/raw cache remain ignored. |
| Source/license | WFO CC0 source manifest and checksums recorded; fictional samples distinguished. No software license selected: choose before public release. |
| Migration | Current schema identity/refusal tested; no fabricated legacy conversions. |
| Recovery | Valid-backup restoration tested; GUI cancel, damaged-current and wrong-UUID scenarios still required. |
| Packaging | New-folder creation/reopen/UUID and traversal rejection tested; explicit-resource selection and moved-package GUI workflow still required. |
| Multi-drawing | Project-sensitive state reviewed and project UUID guards added. Concurrent GUI A/B/A switching remains NOT RUN. |
| Network QA | Branch/TO-demand/three-terminal flow, loops/merges/disconnection/multiple sources, pressure and elevation tests passed. Real equipment placement/selection remains a GUI gate. |
| Benchmark | Actual LT 2027 Core Console scan/reconciliation times recorded in docs/CLOSURE_REPORT.md. Repeat in representative office drawings; no general speed guarantee. |
| Acceptance | 80 documented scenarios, each Setup/Actions/Expected/Pass criteria. GUI scenarios NOT RUN; record per-version evidence. |
| Version/docs/parity | 0.12.0-rc1 current; historical changelog values are historical. Every remaining partial/missing/limited row has a reason. |
| Release artifacts | Local optional WFO ZIP exists with checksum; no hosted download published. No raw data, temporary DWGs, credentials or crash logs staged. |

## GUI release gates

1. On LT 2024 and a current LT version, trust the exact install folder/subfolders, APPLOAD TerraTools.lsp, then run TTHELLO, TTRELOAD, TTDEVSMOKE and TTQACHECK. Keep SECURELOAD enabled for this test.
2. Open every dialog at ordinary and high-DPI display scaling. Test keyboard order, Enter, Esc, field validation, search/paging and return from each action.
3. Exercise project Create/Open/Close, save/close/restart persistence, missing paths, UUID mismatch and deliberate recovery on disposable copies.
4. Test project variants and source detach/reload/reattach with placed instances. Attempt duplicate codes through GUI, CLI and import.
5. Test placement, polygon fill, labels, schedules, Work Areas, failure rollback and one-operation Undo. Verify foreign-project objects are unchanged by current-project output operations.
6. Exercise actual branch drawings, reversed pipes, loops, manual size protection, station/controller validation, coverage refresh and drip demand after save/reopen.
7. Test project A/B/A with two visible drawings, distinct catalog paths, active areas, favorites and preferences.
8. Test selected-resource package creation/move/open and foreign adoption boundaries. Recheck paths and retained backups.

Use ACCEPTANCE_TESTS.md for the exact 80 scenarios. Mark a scenario PASS only after it ran in that environment. Decide software licensing and explicitly authorize any publication separately.

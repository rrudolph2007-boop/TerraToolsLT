# UX polish review, 2026-10-07

This pass changes native DCL presentation and access to existing workflows. Storage, identity, plant database formats and hydraulic calculations are unchanged. The product remains 0.12.0-rc1. UX polish is committed in 237212a and the shared manager empty-state repair in 42915ad, the current pushed repository state. Visible GUI evidence is limited to the two user confirmations below; full GUI acceptance remains pending.

## Confirmed visible GUI evidence

Recorded from the user's report on 2026-10-07:

| Workflow | Confirmed result | Remaining scope |
|---|---|---|
| WFO Plant Manager/database discoverability | Manually exercised successfully in visible AutoCAD LT. | Full UX1 criteria, adding/placing plants, state preservation, keyboard behavior and the visual matrix are not signed off by this report. |
| Work Areas with zero records | The consp nil regression was reproduced, then confirmed fixed in visible AutoCAD LT after the shared manager repair. | Populated-to-empty searches, Add/assignment/cancellation workflows and empty-list behavior in other shared managers still require acceptance evidence. |

The LT version, theme, scaling and screen resolution were not specified. These confirmations do not pass any unreported version/theme/scaling combination or the full acceptance suite.

## Problems and changes

| Observed in code / reported by user | Change |
|---|---|
| The initial short plant list hid the installed WFO database. | An always-visible database banner reads the installed manifest's real count and version. A separate sample notice and SAMPLE row labels distinguish fictional plants, including their project copies. |
| Source and project modes were easy to confuse. | Project Plants and Search Plant Library have direct buttons, scoped list text and different enabled actions. No-search and category-filter states explain why WFO results are absent. |
| Home exposed a flat set of commands with little context. | Grouped Home shows project, units, active Work Area and database availability. Project, production, output and recovery workflows are reachable there. |
| Important commands required memorization. | Tools choosers show named tasks and an explanation before running existing commands. Help uses those workflow groups. |
| Empty lists provided little direction. | Each manager names a next action. Filtered-empty views offer Clear; missing-project context directs users to Project or Recovery. |
| Manager actions reset browsing state or allowed irrelevant operations. | Search, mode, category, page and selected identity survive plant actions within the session. Shared managers retain their query and selection. Inapplicable actions are disabled. No persistent cross-project UI state was added. |
| Short confirmations did not identify the result. | Plant confirmations name the plant/code. Shared record changes compare saved records; placement and assignment count successful changes and skips. Favorite confirmation follows a successful save. |
| Layout and labels differed between managers. | Titles, search/list/selection layout, action groups, button widths and status placement now follow one native DCL pattern. |

## Visual rules implemented

Use `TerraTools | <workflow>` titles. Context appears above the working controls. Search sits immediately above the result list. The list has most of the working space; selected information has its own box below it. Routine actions are grouped before Library/Tools/Remove/Close. No theme-dependent colors, fonts or external rendering layer were added.

Plants has 12 visible result rows and paging; shared record managers have 14. Long technical records remain in Technical Details. Search is the manager default for Enter, Save is the editor default, and Esc uses Close/Cancel. Remove asks for a named confirmation and retains existing dependency guards. Controllers disable Place and Highlight because they are configured through station assignments.

Work Area context describes *new placements*. It does not imply that changing the active area reassigns existing objects. Built-in fixture/equipment guidance labels that data as fictional/sample content. Detail guidance states that current placement creates a sample frame.

Simple symbol previews were considered but not added. This pass uses existing native text/list controls and does not introduce a new rendering dependency.

## Interaction review still required

Perform the following checklist for **every row** below, in visible LT 2024 and a current LT version. Record version, Windows scaling, screen resolution and theme with results. Repeat at 100%, 125%, 150% and 200% Windows scaling, in light and dark AutoCAD themes. A successful Core Console run does not pass these checks.

1. Correct title, project context and selected domain context.
2. Aligned controls and consistent spacing; no clipped labels or status messages.
3. Long botanical names, project names, descriptions and codes remain understandable; Details can inspect complete records.
4. Sensible list height and overall size, with every button reachable on the test display.
5. Primary actions are obvious; Remove is distinct; unavailable actions are disabled.
6. Empty, filtered-empty, selected and unavailable-project states explain the next step.
7. Tab order follows the task; Enter does not accidentally mutate records; Esc/Cancel changes nothing.
8. Search, row selection, paging and return from actions preserve the expected state.
9. Status feedback is visible and matches actual saved/placed results.
10. No dependence on color; disabled labels remain legible in both themes.

| Dialog / workflow | Entry | Layout/text | Keyboard/cancel | State/actions | Light/dark | 100/125/150/200% |
|---|---|---|---|---|---|---|
| Home | TT | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Task chooser | Home > Project, Tools, Output, Recovery | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Plants | Home > Plants | PARTIAL: WFO discoverability confirmed | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Project Plant editor | Plants > Add / Edit / New Variant | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Work Areas manager | Home > Work Areas | NOT RUN | NOT RUN | PARTIAL: zero-record startup fixed | NOT RUN | NOT RUN |
| Reference Notes manager | Home > Site / Reference > Reference Notes manager | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Details manager | Home > Details | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Lighting manager | Home > Lighting | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Irrigation manager | Home > Irrigation | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Stations manager | Irrigation > Tools > Stations | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Controllers manager | Irrigation > Tools > Controllers | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Shared record editor | Each shared manager > Edit | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |
| Technical Details | Plants / shared manager > Details | NOT RUN | NOT RUN | NOT RUN | NOT RUN | NOT RUN |

PARTIAL cells record only the limited user confirmations above. They do not pass the other checks in that column. The seven shared managers use one dialog definition. They still need separate review because button meaning, guidance and field content differ. Project creation, preferences, library import, packages and engineering tools retain command-line prompts after a task chooser closes. That behavior is deliberate and must also be checked for a clear return to the parent manager.

## Verification scope

`tools/check-lisp.mjs` checks Lisp readers/definitions/references and loader inventory. `tools/check-dcl.mjs` checks DCL structure, keys, literal dialog/tile references and literal callback balance. Dynamic callbacks and runtime tile behavior still require manual review and GUI testing.

`tools/ux-regression.lsp` is an optional read-only development check. After loading TerraTools, load that file to check count formatting, database banner text, sample marking, action guards, empty-state messages and task targets. It now includes 17 focused shared-manager selection/empty-state checks. It does not open dialogs. The current file runs 39 checks with a valid WFO manifest, or 38 without one; the installed-banner check is conditional. All 39 passed in LT 2027 Core Console after the shared manager repair. Existing foundation/completion regressions and TTRELOAD/TTDEVSMOKE/TTQACHECK also passed; see the current release checklist for results.

Run the remaining coverage in UX1 through UX15 in ACCEPTANCE_TESTS.md on disposable projects, then complete the visual matrix above. The two confirmed workflows are limited evidence; no full multi-step scenario or complete visual-matrix row is marked passed.

# Changelog

## 0.12.0-rc1, 2026-10-06

Repository closure candidate. This entry includes completed work carried forward from the preceding completion sprint. It is not a claim that visible AutoCAD LT acceptance passed.

- Plant Manager browsing, source/favorite/recent views, project variants and central project-code/ID validation are integrated. Source detachment leaves project copies valid.
- Optional WFO June 2026 database was built and reverified: 435,702 accepted taxa, 999,746 aliases and 435,702 taxonomy-only descriptions. Runtime uses lazy shards; build/verification tools are optional.
- Planting includes bounded polygon fill, density areas, selection/count helpers, project symbol scale, plant label styles and schedule styles.
- Shared DCL managers cover Work Areas, reference notes, details, lighting, irrigation, stations and controllers. Closure fixed optional-field editing, library-copy validation and safe unused-record removal.
- Reference-note callouts now refresh from project records without inflating quantities. Failed note storage restores prior drawing metadata. Lighting gained match/count commands. Equipment schedules retain station or Work Area scope for refresh.
- Directed irrigation graph, downstream edge flow, pressure propagation and automatic critical route are wired into the public analyzer. Controller/sleeve records no longer create false hydraulic demand. Source-node losses are included.
- Pipe classes separate nominal and actual inside diameter; sizing uses actual ID and preserves manual sizes. Stations/controllers guard output/capacity conflicts. Coverage arcs, drip-area demand and metric input conversion are integrated. Closure fixed XData persistence of coverage sweep and drip pressure.
- Schema-1 migration boundary refuses unknown schemas. Deliberate recovery retains recoverable copies. New-folder packages validate paths and explicit resources. Foreign adoption accepts supported resolvable records only and clears foreign operational assignments.
- Logical module layer roles and office plant-output styles remain additive. Legacy commands that do not yet consume every role/scale preference are documented as partial.
- Duplicate UUID reconciliation uses an operation-local sorted scan. Measured LT 2027 Core Console checks, a 1k/5k/10k benchmark and the database verifier passed. Lisp/DCL static auditing and 80 acceptance scenarios cover the current repository.
- Loader failure clears readiness flags and reports the exact module. Documentation and parity were reconciled with code.

Visible DCL, selection/cancel/Undo behavior, multi-document isolation and LT 2024-2026 still require real acceptance. The optional data ZIP is local and unpublished. Software licensing remains a public-release decision.

## Earlier prerelease checkpoints

Core scaffold, UUID/XData persistence, external projects, preferences and sample plant palettes were user-tested before the completion work. The repository's Git history is the authoritative record of those checkpoints. No invented historical migration or release result is asserted here.

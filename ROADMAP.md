# TerraTools LT Roadmap

## 0.12.0-rc1: repository closure, GUI acceptance pending

Implemented code includes project persistence and recovery, source-independent plant variants, a lazy WFO database, Plant Manager and shared record managers, polygon fill and density areas, plant label/schedule styles, directed irrigation pressure analysis, pipe classes and sizing scopes, station/controller records, coverage refresh, drip-area demand, packaging and limited adoption.

The closure work unifies central palette code validation, repairs coverage/drip metadata persistence, routes public irrigation analysis through the graph, adds reference callouts and scoped equipment schedules, fixes manager dependencies, and reduces duplicate-UUID scanning cost.

## Release gates

- Run all 80 acceptance scenarios in visible AutoCAD LT, including 2024 and newer versions used by the team.
- Verify dialog rendering, keyboard/cancel behavior, Undo, secure/trusted loading and multi-drawing isolation.
- Check CAD persistence after saving and reopening newly created output.
- Review engineering inputs against project source data. Fictional sample values are not specifications.
- Choose a software license before public distribution. No license has been invented during closure.
- Publish the separately verified optional WFO data artifact through an approved release process.

## Deferred scope

The exact remaining capabilities and reasons are in PARITY_MATRIX.md. Main deferrals are presentation graphics, symbol-library preview/favorites, broad manufacturer adapters, source-DWG detail insertion, office engineering defaults, equipment schedule column customization and composite foreign-object adoption. These remain visible gaps, not claims of LT impossibility.

Version 1.0 requires real GUI/runtime acceptance and resolution of release-blocking results.

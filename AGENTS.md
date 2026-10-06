# TerraTools LT Agent Instructions

TerraTools LT is an original landscape architecture productivity system designed specifically for AutoCAD LT 2024+ on Windows.

The application is being developed incrementally. Existing functionality that has passed real AutoCAD LT testing should be treated as stable unless the user explicitly requests a redesign.

## Required First Steps

Before modifying the repository:

1. Read this `AGENTS.md`.
2. Read `README.md`.
3. Read `ROADMAP.md`.
4. Inspect the existing repository structure and relevant source files.
5. Determine which existing modules and interfaces the requested change depends on.
6. Preserve previously tested functionality unless a change is explicitly required.

Do not begin implementation before understanding the existing architecture.

## Platform

Target:

- AutoCAD LT 2024+ on Windows

Prefer:

- AutoLISP
- DCL
- standard AutoCAD LT commands
- DXF/entity manipulation
- XData
- ordinary supported DWG entities
- external local project storage

Do not require:

- Managed .NET
- ObjectARX
- VBA
- Civil 3D
- full AutoCAD
- unsupported third-party COM/ActiveX APIs

Do not assume that functionality available in full AutoCAD is available in AutoCAD LT.

If compatibility is uncertain, prefer a simpler documented AutoLISP, DXF, XData, DCL, or standard-command implementation.

## Coding Principles

- All public TerraTools commands use the `TT` prefix.
- Internal TerraTools functions use the `TT:` prefix.
- Preserve existing working architecture.
- Prefer surgical changes over broad rewrites.
- Never leave pseudocode in production source files.
- Do not leave requested core functionality as TODO placeholders.
- Separate storage, UI, CAD manipulation, validation, and calculation logic.
- Restore modified AutoCAD system variables after errors.
- Use Undo groups for drawing-changing operations where practical.
- Avoid machine-specific absolute paths.
- Keep source files modular.
- Avoid unnecessary global variables.
- Declare/localize variables wherever practical in AutoLISP.
- Do not silently swallow errors that could corrupt project or drawing state.
- Do not duplicate functionality that already exists in another core module.
- Prefer reusable core utilities over module-specific copies of the same logic.

## Module Boundaries

Keep major responsibilities separated.

Expected high-level areas include:

- `core/`
- `planting/`
- `site/`
- `details/`
- `lighting/`
- `irrigation/`
- `schedules/`
- `dialogs/`
- `data/`
- `blocks/`

Core infrastructure should not depend unnecessarily on higher-level feature modules.

For example:

- planting may depend on core
- irrigation may depend on core
- core should not depend on planting

Do not create circular module dependencies.

## Smart Object Architecture

Smart CAD entities should remain ordinary AutoCAD LT-supported entities whenever possible.

Examples include:

- INSERT
- LWPOLYLINE
- LINE
- ARC
- CIRCLE
- HATCH
- TEXT
- MTEXT
- supported leader entities
- supported table entities

TerraTools metadata should use the registered XData application:

`TERRATOOLS`

A smart placed entity may contain lightweight identifiers including:

- entity UUID
- project UUID
- module
- object type
- catalog ID
- Work Area ID
- schema/version information where necessary

Do not store complete catalog or project database records in XData.

Do not use AutoCAD entity handles as permanent TerraTools application IDs.

Entity handles may be used temporarily for drawing lookup, but persistent TerraTools identity must use application-generated UUIDs.

## Identity Rules

Catalog identity and placed-instance identity are different concepts.

Example:

A plant species may have:

`catalog_id = PLANT-102`

Ten placed copies of that plant must share the same catalog ID but each must have a different entity UUID.

Therefore:

- copying an object should preserve catalog identity
- copying an object must not permanently preserve placed-instance UUID
- reconciliation must be able to detect and repair duplicate instance UUIDs

Never infer catalog identity from a CAD block name.

A graphical block is a symbol.

The TerraTools data reference determines what the object represents.

## Data Hierarchy

Maintain the distinction between:

1. Master Catalog
2. Project Palette
3. Placed Instance

### Master Catalog

Reusable source records available across projects.

### Project Palette

Project-specific selections and specifications derived from the Master Catalog.

A Project Palette record may override fields such as:

- code
- size
- spacing
- cost
- symbol

without modifying the Master Catalog.

### Placed Instance

An actual CAD entity in a DWG referencing a Project Palette/catalog record.

Schedules and labels are derived views, not sources of truth.

Deleting a schedule must not delete design data.

Deleting a label must not delete design data.

Schedules should derive quantities from actual smart drawing entities whenever appropriate.

## Project Data

Project data should be stored externally using the repository's established project-storage abstraction.

Do not bypass the storage abstraction by having individual feature modules write arbitrary independent files.

Project writes should be designed to reduce corruption risk.

Where practical:

1. load existing data
2. validate it
3. modify it in memory
4. write safely
5. preserve or create a backup where appropriate

Do not change the persistent project schema casually.

If a schema change is necessary:

- document the change
- preserve backward compatibility where practical
- provide a migration path if existing project files would otherwise break

## AutoCAD LT Compatibility

AutoCAD LT 2024+ for Windows supports AutoLISP and DCL, but its extension/API environment is more limited than full AutoCAD.

Do not assume support for:

- full AutoCAD-only APIs
- Managed .NET APIs
- ObjectARX
- arbitrary COM automation
- Visual LISP/ActiveX functionality without confirming LT compatibility

Prefer:

- `entget`
- `entmod`
- `entmake` / `entmakex` where supported
- `ssget`
- standard AutoLISP list processing
- DXF group-code manipulation
- XData
- `command` / `command-s` where appropriate
- DCL
- standard drawing entities

If uncertain whether a function is LT-compatible, explicitly identify that uncertainty rather than pretending it has been verified.

## Runtime Testing

Real execution inside AutoCAD LT is the final authority.

Do not claim a feature has been tested in AutoCAD LT unless it was actually executed there.

Codex may:

- inspect code
- reason about compatibility
- perform static checks
- create test helpers
- inspect diffs

but this does not equal AutoCAD LT runtime verification.

When implementation is complete, provide exact manual tests for the user to perform inside AutoCAD LT.

If the user reports an AutoCAD error, treat the exact runtime error as authoritative and investigate it before adding more functionality.

## Error Handling

Drawing-changing commands should:

- handle cancellation gracefully
- restore changed system variables
- restore appropriate drawing state after failure
- use Undo grouping where practical
- avoid leaving partially created smart objects
- avoid corrupting external project data
- produce useful diagnostic messages

Do not use an error handler that hides the root cause during development.

## Public Interface Stability

Previously tested public `TT...` commands should be treated as stable interfaces.

Do not:

- rename them
- remove them
- substantially change their expected behavior
- change persistent data semantics

unless the requested task explicitly requires it.

If a breaking change is genuinely necessary, explain why before implementing it.

## Dependencies

Do not introduce new external runtimes, libraries, package managers, executables, or services unless they are clearly necessary and explicitly approved.

In particular, do not introduce:

- Python runtime requirements
- Node.js runtime requirements
- external databases
- background services
- compiled DLL dependencies

for functionality that can reasonably be implemented within the existing AutoLISP/DCL architecture.

Development utilities are acceptable only when they are not required by end users to run TerraTools.

## Path Handling

Do not hard-code paths such as:

`C:\Users\SomeUser\...`

Resolve application resources relative to the TerraTools installation root or through configured library paths.

Projects should remain portable when their containing directories are moved.

## Git Safety

Do not automatically commit or push changes unless explicitly requested.

Do not perform destructive Git operations without explicit approval.

Avoid commands such as:

- `git reset --hard`
- `git clean -fd`
- forced pushes
- history rewriting

unless the user specifically requests them and understands the consequences.

Do not delete or overwrite unrelated user work.

Use `git status` and `git diff` to understand the current state before substantial modifications.

## Scope Control

Implement only the requested roadmap milestone.

Do not opportunistically begin future modules.

For example, if the current task is the UUID/XData framework:

- do not begin planting
- do not begin irrigation
- do not redesign the entire project system

A smaller fully working milestone is better than a large partially implemented system.

## Change Safety

Do not rewrite the entire application to solve a local problem.

Before changing an existing interface:

1. locate its current implementation
2. identify modules that call it
3. determine what behavior those modules rely on
4. preserve those interfaces whenever possible
5. make the smallest safe change

Do not replace a working implementation simply because another approach appears stylistically preferable.

## Development Process

For each requested feature:

1. Read repository instructions.
2. Inspect the existing implementation.
3. Identify affected modules.
4. Implement the smallest complete solution.
5. Review changes for AutoCAD LT compatibility.
6. Review changes for unintended regressions.
7. List all files created or modified.
8. Explain what changed.
9. Provide exact AutoCAD LT commands/actions to test.
10. State the expected test results.
11. Identify known limitations or unverified assumptions.
12. Stop and wait for runtime test results before beginning the next roadmap milestone.

## Debugging Process

When the user reports a failure:

1. use the exact reported error message
2. inspect the current repository
3. identify the function producing the error
4. determine the root cause
5. determine whether it is:
   - syntax
   - AutoCAD LT compatibility
   - entity handling
   - storage/data handling
   - path handling
   - state management
   - another cause
6. implement the smallest safe fix
7. provide a focused regression test

Do not respond to a local defect by rewriting unrelated architecture.

## Completion Standard

A feature is not complete merely because code was generated.

A feature is complete only when:

- requested functionality is actually implemented
- source files contain no placeholder implementation for core behavior
- existing behavior has been preserved
- compatibility has been reviewed
- the user has been given a concrete AutoCAD LT test procedure

A feature becomes a tested/stable milestone only after successful real-world testing in AutoCAD LT.

## Critical Principle

Reliability in AutoCAD LT is more important than sophistication.

When choosing between a clever implementation that depends on questionable API support and a simpler implementation based on standard AutoLISP/DXF/XData behavior, prefer the simpler reliable implementation.
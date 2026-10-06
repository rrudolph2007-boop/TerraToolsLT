# TerraTools LT Agent Instructions

TerraTools LT is an original landscape architecture productivity system designed specifically for AutoCAD LT 2024+ on Windows.

## Platform

Prefer:

- AutoLISP
- DCL
- standard AutoCAD LT commands
- DXF/entity manipulation
- XData
- ordinary DWG entities
- external local project storage

Do not require:

- Managed .NET
- ObjectARX
- VBA
- Civil 3D
- full AutoCAD
- unsupported third-party COM/ActiveX APIs

## Coding Principles

- All public TerraTools commands use the TT prefix.
- Internal functions use TT: names.
- Preserve existing working architecture.
- Prefer surgical changes over rewrites.
- Never leave pseudocode in production source files.
- Do not leave requested core functionality as TODO placeholders.
- Separate storage, UI, CAD manipulation, and calculation logic.
- Restore modified AutoCAD system variables after errors.
- Use Undo groups where practical.
- Avoid machine-specific absolute paths.
- Keep source files modular.
- Target AutoCAD LT rather than assuming full AutoCAD functionality.

## Smart Object Architecture

Smart CAD entities remain ordinary AutoCAD-supported entities.

TerraTools metadata should use TERRATOOLS XData.

A smart entity may contain lightweight identifiers including:

- entity UUID
- project UUID
- module
- object type
- catalog ID
- Work Area ID

Do not store entire catalog database records in XData.

Do not use AutoCAD entity handles as the permanent application identity.

## Data Hierarchy

Maintain the distinction between:

1. Master Catalog
2. Project Palette
3. Placed Instance

Schedules and labels are derived views, not sources of truth.

## AutoCAD LT Compatibility

AutoCAD LT 2024+ for Windows supports AutoLISP and DCL.

Do not assume APIs supported only by full AutoCAD are available.

When uncertain, prefer standard AutoLISP, DXF/entity operations, XData, DCL, and ordinary supported DWG entities.

## Development Process

After each feature:

1. list the files modified
2. explain what changed
3. provide exact commands to test
4. provide expected test results
5. identify known limitations
6. do not begin the next roadmap feature unless requested

## Change Safety

Do not rewrite the entire application to solve a local problem.

Before changing an existing interface, determine what other modules depend on it.

Prefer the smallest safe change that solves the problem.
# TerraTools LT

TerraTools LT is an original landscape architecture CAD productivity system designed for AutoCAD LT 2024+ on Windows.

## Core Technologies

- AutoLISP
- DCL
- AutoCAD XData
- Standard AutoCAD LT entities
- External project data storage

## Development Status

Current phase: Core architecture.

## Platform Target

AutoCAD LT 2024 or newer on Windows.

## Core Scaffold 0.1.0

`TerraTools.lsp` loads the modules in `core/`. The scaffold provides
`TTHELLO`, read-only diagnostics through `TTDEBUG`, and command error reporting.
The UUID/XData foundation adds `TTTESTUUID`, `TTTAGTEST`, `TTINFOTEST`, and
`TTUNTAGTEST`, `TTPROJECT`, and `TTPROJECTINFO`. It does not create drawing
entities or change system variables. No external runtime or compiled extension
is required.

TerraTools smart-entity metadata uses the registered XData application
`TERRATOOLS`. Schema version 1 stores a `TT_ENTITY` marker, the schema version,
and named string fields for entity UUID, project UUID, module, object type,
catalog ID, and Work Area ID. Fields without values are omitted. Project and
catalog records are not stored in XData.

### Project storage

Each TerraTools project is stored outside the DWG in a file named
`terratools-project.dat`. The file contains one AutoLISP S-expression with a
format marker and keyed project fields. All file access goes through
`core/tt-storage.lsp`, which keeps the physical format separate from project
commands.

Before replacing an existing valid project file, TerraTools verifies a staging
file and writes `terratools-project.dat.bak`. The current drawing stores the
project UUID and project data path as `TERRATOOLS` XData on the drawing's Named
Object Dictionary. This creates no visible drawing entity and does not store the
complete project record in the DWG.

### Load in AutoCAD LT

1. Keep `TerraTools.lsp` and the `core/` folder together in the installation
   folder. Folder names may contain spaces.
2. Run `OPTIONS`. On the Files tab, add the installation folder to **Support
   File Search Path**. Under **Trusted Locations**, add the installation folder
   with `\...` at the end, for example `<TerraTools installation folder>\...`.
   The trailing backslash and three dots make its subfolders, including `core/`,
   trusted. Apply the changes. Keep the existing security settings.
3. If AutoCAD LT already reported `File load canceled` for a TerraTools file,
   close and restart AutoCAD LT after updating Trusted Locations. AutoCAD can
   remember a rejected load for the rest of the current session.
4. Run `APPLOAD`, select `TerraTools.lsp` in that installation, and click Load.
   Close the APPLOAD dialog. If a file picker asks you to locate the loader,
   select that same `TerraTools.lsp` file.
5. Expect `TerraTools LT 0.1.0 ready. Commands: TTHELLO, TTDEBUG.` in the command
   history. Press F2 if needed to see the complete output.

The loader finds `TerraTools.lsp` through AutoCAD's file search paths, or asks
for its location if it cannot be found. It loads every core module by explicit
path relative to that file's folder. Keep only one TerraTools installation on
the search paths, since the first matching loader determines the root.

### Manual checks

- Run `TTHELLO`. Expect exactly `TerraTools LT loaded successfully.` as the
  command's message.
- Run `TTDEBUG`. Expect TerraTools version `0.1.0`, AutoCAD product and version,
  drawing filename and directory, current layer, numeric `INSUNITS`, and
  `Core loaded successfully: Yes`. Values come from the current drawing and
  AutoCAD session. An unavailable value is printed as `Unavailable`; an empty
  string is printed as `(empty)`.
- Compare the diagnostic values with `(getvar "PRODUCT")`, `(getvar "ACADVER")`,
  `(getvar "DWGNAME")`, `(getvar "DWGPREFIX")`, `(getvar "CLAYER")`, and
  `(getvar "INSUNITS")`, entered separately at the command prompt.
- Run `APPLOAD` on the same loader again, then repeat `TTHELLO` and `TTDEBUG`.
  Expect the same successful results without duplicate output per command.
- For a portability check, copy the complete installation to a folder with
  spaces in its name. In a fresh LT session, update the support and trusted
  paths to that copy, remove the original TerraTools path entries, and load
  the copied loader. Both commands should still work. Enter `!*TT:Root*`
  to inspect the resolved installation folder.
- For a failure check, use a disposable installation copy. After a successful
  load, rename its `core/tt-debug.lsp` to `tt-debug.lsp.disabled`, then reload
  its loader. Expect a missing-file message naming that module, no readiness
  message, and `(if *TT:CoreLoaded* "Yes" "No")` to return `"No"`. `TTHELLO`
  must report that the core is not loaded. Restore the filename and reload;
  expect normal operation again.

Loading is per drawing; use `APPLOAD` in each drawing for these tests. Automatic
startup installation is not included. Failed reloads mark the core unavailable
but do not remove command definitions already loaded in that drawing.

Project management compatibility has been reviewed against the AutoCAD LT 2024
AutoLISP reference. Real execution in AutoCAD LT is still required before
treating the project management and storage milestone as tested. The reserved
feature directories are empty and are not tracked by Git until they contain
files.

# Install TerraTools LT

TerraTools LT targets AutoCAD LT 2024+ on Windows.

## 1. Download

Download the latest `TerraTools-LT-<version>.zip` release asset and extract it to a permanent local folder. Do not run TerraTools from inside the ZIP.

The optional World Flora Online package is separate. TerraTools works without it using the bundled fictional sample records.

## 2. Trust the installation

In AutoCAD LT, add the extracted TerraTools folder to:

- Support File Search Path
- Trusted Locations

Trust the TerraTools subfolders as well. Keep `SECURELOAD` enabled.

## 3. Load TerraTools

Run `APPLOAD`, select `TerraTools.lsp` from the extracted folder, then run:

```text
TTRELOAD
TTDEVSMOKE
TTQACHECK
TT
```

`TTDEVSMOKE` and `TTQACHECK` are read-only checks.

## 4. Optional automatic startup

After the folder is trusted, add that exact `TerraTools.lsp` file to AutoCAD LT's APPLOAD Startup Suite.

TerraTools does not install or rewrite `acaddoc.lsp`.

## 5. Optional WFO plant database

Download the matching `terratools-wfo-2026-06.zip` release asset and extract its `production` folder into:

```text
<TerraTools root>\data\plants\
```

The result must be:

```text
<TerraTools root>\data\plants\production\manifest.dat
```

Set `LISPSYS` to 1 or 2 and restart AutoCAD LT if Unicode plant data is not already enabled. Then run:

```text
TTPLANTDATABASE
TTPLANTSEARCH
```

Search for `Acer rubrum` as a quick database test.

## 6. Verify downloads

Each tagged release includes `SHA256SUMS.txt`. On Windows PowerShell:

```powershell
Get-FileHash .\TerraTools-LT-0.12.0-rc1.zip -Algorithm SHA256
```

Compare the result with the matching line in `SHA256SUMS.txt`.

## Updating

Keep project files separate from the TerraTools installation folder. Before replacing an installation, close AutoCAD LT and retain the previous release ZIP until the new version has passed `TTDEVSMOKE` and `TTQACHECK` in your environment.

Project data has its own backup/recovery workflow and is not stored in the application folder.

## Troubleshooting

Run `TTDEBUG` and include the non-sensitive output when filing a bug. Do not post client DWGs, project files, names, addresses, or other confidential project data to a public issue.

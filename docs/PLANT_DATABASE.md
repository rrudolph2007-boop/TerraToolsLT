# Open plant database

The local WFO June 2026 build contains 435,702 accepted species and infraspecific
taxa, with 999,746 linked synonym names. Synonyms are search aliases, not extra
accepted plants. The 15 fictional TerraTools samples remain separate.

Source: [World Flora Online Plant List, June 2026](https://zenodo.org/records/20782718).
The release metadata declares CC0. Exact source URLs and SHA-256 digests are in
`data/plants/sources/wfo-2026-06.json`. No images or source descriptions are included.

## Install without development tools

The database is an optional separate data package. Extract its `production`
folder into `data/plants/` beside the TerraTools installation, so that
`data/plants/production/manifest.dat` exists. Do not nest another production folder.
Set LISPSYS to 1 or 2 and restart LT before reading Unicode plant data.
Run `TTPLANTDATABASE`, then `TTPLANTSEARCH`, search `Acer rubrum`.
Node.js is not required to use the installed package.

Tagged public releases are configured to publish the verified production database
as the separate `terratools-wfo-2026-06.zip` release asset. The release workflow
downloads the recorded public WFO archive, verifies both recorded source SHA-256
digests, rebuilds the database, runs the full verifier, then publishes the ZIP and
`SHA256SUMS.txt`. Raw archives and generated production data remain intentionally
ignored by Git. Do not substitute the samples for a missing production package.

The original closure build produced `artifacts/terratools-wfo-2026-06.zip`,
190,947,344 bytes, SHA-256
`474360c38d3cc43a1fc1797eb09a9659459af5c122742738d40531781fa680b9`.
That checksum documents the closure artifact only. Public release ZIP metadata may
produce a different archive checksum even when the verified database contents are
equivalent; use the `SHA256SUMS.txt` published with the specific release.
Its extracted production directory has 1,474 files totaling 1,135,555,979 bytes.
The full verifier passed again during the 0.12.0-rc1 closure: 1,472 record/index
files plus two manifests; accepted 435,702, aliases 999,746, descriptions 435,702.
This is the same verified build from the previous sprint, not a fabricated new
dataset. The build took 118.315 seconds in the development environment; that is
one measured build, not a performance guarantee.

## Rebuild

Optional development dependency: Node.js 22 or newer. Download the archive URL in
the source manifest, verify its SHA-256, and extract `classification.csv` into an
ignored local raw directory. From the repository root:

```powershell
node tools/build-plants.mjs data/plants/raw/wfo-2026-06/classification.csv data/plants/build/wfo-new
node tools/verify-plants.mjs data/plants/build/wfo-new
```

The output directory must not exist. The builder streams tab-delimited quoted
source records, selects accepted species/subspecies/varieties/forms, preserves
WFO identity, and links synonyms only by the supplied accepted-name ID. It does
not merge similar names or infer cultivars. Unresolved aliases are counted separately.

Every accepted record receives original taxonomy-only text based on its name,
family or rank. All 435,702 descriptions are TAXONOMY_ONLY; BASIC and ENRICHED
counts are zero. They say nothing about hardiness, size, water, sun, toxicity,
native range or design suitability. Structured enrichment must have its own
verified source and must retain separate generated-content metadata.

Records are distributed among 1,024 ID shards. Compact search rows are indexed
under the first two letters of each searchable name/family/synonym token. Runtime
queries use token prefixes and all query words, selecting one corresponding
shard. Exact scientific names rank first; up to 500 other matches are displayed
in pages. Full records load only when selected. Startup never parses this database.
ASCII name matching is supported; diacritics are normalized by the build. Search
with unaccented letters. Arbitrary mid-word substrings are not indexed.

`manifest.json` records source, schema/build/index/description versions, actual
counts, input SHA-256 and every record/index file checksum. `manifest.dat` is the
small AutoLISP runtime summary. `tools/verify-plants.mjs` verifies every checksum,
record identity, alias count and description count without changing the package.
`TTPLANTDATABASE` is a runtime manifest/status check, not a cryptographic audit.

For updates, build and verify a separate folder, close TerraTools drawings, retain
the old package, then replace the production directory with the verified folder.
Reload TerraTools afterward. Project copies and their IDs are never rewritten by
a database update. A missing source changes provenance status only.

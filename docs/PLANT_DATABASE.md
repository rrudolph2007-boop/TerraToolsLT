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

No hosted download has been published by this sprint. Maintainers can distribute
the local generated directory as a separate ZIP release asset, with its manifest
and checksums. Raw archives and generated production data are intentionally ignored
by Git. Do not substitute the samples for a missing production package.

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

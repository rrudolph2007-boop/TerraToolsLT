# Data Sources and Provenance

## Bundled plant sample

`data/terratools-plant-master.dat` contains 15 original fictional records made for TerraTools testing. Names, codes, costs, sizes, and notes are examples. They are not horticultural recommendations or construction pricing. No third-party plant photos are bundled.

## Optional WFO production package

The World Flora Online Plant List June 2026 release is available at [Zenodo record 20782718](https://zenodo.org/records/20782718), whose release metadata declares CC0. The exact archive URL, input filename and SHA-256 digests are tracked in `data/plants/sources/wfo-2026-06.json`.

The locally built package contains 435,702 accepted species/infraspecific taxa and 999,746 linked synonyms. Synonyms are aliases, not extra accepted plants. All 435,702 generated descriptions are explicitly taxonomy-only. No images, horticultural recommendations or commercial descriptions are included. See `docs/PLANT_DATABASE.md` for installation, build, verification and distribution status. Generated data and raw downloads are ignored by Git; the optional package is separate from the software repository.

## USDA PLANTS import target

TerraTools includes `TTIMPORTUSDA`, an optional runtime importer for a user-downloaded Complete PLANTS Checklist CSV. The official [USDA PLANTS download page](https://plants.sc.egov.usda.gov/downloads) describes a comma-delimited checklist with plant symbol, synonym symbol, scientific name with authors, national common name, and family. The importer copies only those supplied fields and source metadata. It leaves horticultural and design fields empty.

The [USDA PLANTS help document](https://plants.sc.egov.usda.gov/DocumentLibrary/Pdf/PLANTS_Help_Document.pdf) states that PLANTS plant information, maps, lists, and text are not copyrighted and may be used freely. It separately warns that images may have their own copyright or permission conditions. TerraTools does not import or redistribute PLANTS images.

No USDA records are bundled in this repository. The import count for this sprint is zero because the official download could not be retrieved into the development workspace. A user can download the current checklist from USDA, run `TTIMPORTUSDA`, and attach the resulting normalized file with `TTPLANTDATA`.

The importer records:

- source: USDA PLANTS
- source ID: USDA plant symbol
- source URL and attribution
- scientific name exactly as supplied
- synonym symbol, common name, and family when present
- blank values for fields the checklist does not supply

Users must review the current USDA terms and downloaded fields before redistribution. The normalized file may be large and is intentionally not committed by default.

## Lighting and irrigation samples

`data/terratools-lighting-master.dat` and `data/terratools-irrigation-master.dat` contain original fictional example records. They do not claim manufacturer accuracy. Their costs and engineering values are demonstrations that must be replaced or verified for project use.

## Generated CAD resources

TerraTools generates its simple symbol blocks from original DXF geometry at runtime. The repository contains no copied commercial block, detail, logo, interface artwork, or proprietary database.

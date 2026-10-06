# Normalized plant data

Normalized files use the `TERRATOOLS_NORMALIZED_PLANTS` envelope and `NORMALIZED_PLANT` records. Optional fields remain blank or nil when a source does not provide them. Stable `PLANT_ID`, `SOURCE`, and `SOURCE_ID` fields preserve identity and provenance.

Attach a normalized file to a project with `TTPLANTDATA`. The path is stored in the project file. TerraTools reports an unreadable path instead of inventing replacement data.

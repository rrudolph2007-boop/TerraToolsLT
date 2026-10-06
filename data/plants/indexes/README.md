# Plant indexes

TerraTools currently builds a compact uppercase search index in memory from selected text fields. The index is created once per session and invalidated by user-library or attachment changes. No generated index is required in this folder yet.

For larger deployments, a future offline index generator may write lightweight records here. Any generated format must remain optional and must not become a Python or Node.js runtime dependency.

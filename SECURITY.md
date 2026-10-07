# Security Policy

## Reporting a vulnerability

Please do not publish exploitable security details, private project data, credentials, or confidential drawings in a public GitHub issue.

If GitHub private vulnerability reporting is enabled for this repository, use the repository's **Security > Report a vulnerability** flow.

If private reporting is not enabled, open a public issue containing only a minimal statement that a security-sensitive problem exists and request a private contact channel. Do not include exploit details or sensitive files.

## Scope

Security-relevant areas include:

- unsafe path handling or package traversal
- evaluation of imported/untrusted data
- arbitrary file overwrite or deletion
- project backup/recovery corruption
- unsafe handling of external library files
- release-package tampering or checksum mismatch

TerraTools runtime intentionally avoids external services and does not evaluate imported plant/project data as code.

## Supported versions

Until a stable 1.0 release, security fixes are provided only for the latest published release candidate unless a release note states otherwise.

# Public Release Checklist

This checklist is intentionally short and operational. The deeper engineering gates remain in `RELEASE_CHECKLIST.md` and `ACCEPTANCE_TESTS.md`.

## Already prepared in source

- [x] MIT software license
- [x] Separate WFO CC0 provenance/license
- [x] public installation guide
- [x] support policy
- [x] privacy statement
- [x] security-reporting policy
- [x] structured bug-report template
- [x] static product website
- [x] manual GitHub Pages deployment workflow
- [x] clean runtime ZIP workflow
- [x] optional WFO download/rebuild/verification workflow
- [x] SHA-256 checksum generation
- [x] release notes
- [x] explicit release-candidate limitations
- [x] no full Land F/X parity claim

## Final publication actions

- [ ] Make the GitHub repository public.
- [ ] Confirm GitHub Issues are enabled.
- [ ] Enable private vulnerability reporting if available.
- [ ] Enable GitHub Pages with **GitHub Actions** as the source.
- [ ] Create and push the signed/annotated release tag `v0.12.0-rc1`.
- [ ] Confirm **Build and publish TerraTools release** completes successfully.
- [ ] Verify the GitHub prerelease contains:
  - `TerraTools-LT-0.12.0-rc1.zip`
  - `terratools-wfo-2026-06.zip`
  - `SHA256SUMS.txt`
- [ ] Run the Pages deployment workflow.
- [ ] Test the website and every download link from a signed-out browser.
- [ ] Extract the runtime ZIP into a clean folder and perform the documented install flow in visible AutoCAD LT.
- [ ] Install the released WFO ZIP and verify `TTPLANTDATABASE` plus an `Acer rubrum` search.
- [ ] Keep the release marked **prerelease** until the remaining GUI acceptance gates justify a stable release.

## Recommended release tag commands

From an up-to-date local `main` after the productization changes are merged:

```powershell
git checkout main
git pull origin main
git tag -a v0.12.0-rc1 -m "TerraTools LT 0.12.0-rc1"
git push origin v0.12.0-rc1
```

Pushing that exact tag triggers the release workflow. The workflow refuses a tag whose version does not match `*TT:Version*`.

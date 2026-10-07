# TerraTools LT website

This folder contains the static public-facing TerraTools LT website.

## Local preview

Open `index.html` directly in a browser, or serve the folder with any static HTTP server.

## Deployment

The repository includes a manual GitHub Pages workflow at `.github/workflows/deploy-pages.yml`.

Before the first public deployment:

1. make the repository public;
2. create the first tagged GitHub prerelease so the Download buttons resolve;
3. enable GitHub Pages with **GitHub Actions** as its source;
4. run the **Deploy website to GitHub Pages** workflow;
5. verify the release/download/docs links from a signed-out browser session.

The software license, release packager, checksum generation, optional WFO build, privacy/support/security docs, and website are already tracked in the productization branch.

The site intentionally does **not** claim full Land F/X parity.

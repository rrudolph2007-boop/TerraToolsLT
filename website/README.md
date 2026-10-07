# TerraTools LT website

This folder contains the static public-facing TerraTools LT website.

## Local preview

Open `index.html` directly in a browser, or serve the folder with any static HTTP server.

## Deployment

The repository includes a GitHub Pages workflow at `.github/workflows/deploy-pages.yml`.

Before public deployment:

1. select and add a root software license;
2. make the repository public or otherwise configure Pages availability;
3. create a GitHub Release with the tested TerraTools runtime bundle;
4. verify all download links;
5. enable GitHub Pages with GitHub Actions as its source;
6. run the remaining release acceptance gates and keep the release-candidate wording until they pass.

The site intentionally does **not** claim full Land F/X parity.

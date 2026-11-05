# Asset provenance and licensing

This file tracks the provenance and redistribution terms for files bundled under `assets/`. A file being present in a public GitHub repository does not mean that it is available for unrestricted reuse.

## Current inventory

| Path | Material | Current evidence | Required action |
| --- | --- | --- | --- |
| `assets/fonts/KOOkies-*.otf` | Seven weights of the Kookies / KO Okies Arabic typeface | KO-Type lists Kookies by Ibrahim Hamdi. KO-Type's published terms state that redistribution of fonts without written permission is not allowed. See [Kookies Typeface](https://ko-type.com/products/kookies-typeface) and [KO-Type terms](https://ko-type.com/about). | Obtain written permission covering redistribution in this public source repository and embedding/distribution in APK builds, then add the permission/license and attribution. Otherwise remove the font files from the repository and app bundle and use a font with a license that permits both uses. |
| `assets/images/**/*.png` | App icon, backgrounds, cover, heading, and role illustrations | Creator, source, and license are not documented in this repository. | Record the creator/source and exact license or written permission for every image. |
| `assets/sounds/**/*.wav` | UI and game sound effects | Creator, source, and license are not documented in this repository. | Record the creator/source and exact license or written permission for every sound. |

## Required record for each third-party asset

For every asset that is not wholly original to the project maintainer, add:

- File path and asset name.
- Creator/copyright holder.
- Original source URL.
- Exact license name and version, or written permission.
- Required attribution text.
- Any restrictions, such as non-commercial use, no redistribution, or attribution requirements.

## Important

- The repository's `LICENSE` applies to original source code and project documentation only. It does not relicense bundled fonts, images, sounds, or other third-party files.
- Permission to use a font or image inside a built app does not necessarily permit publishing the original file in a public source repository. Verify both uses.
- Do not claim that assets are public domain, Creative Commons, MIT, or otherwise reusable unless the source license or written permission confirms it.
- If redistribution permission cannot be verified, remove the asset from the repository and replace it with an asset whose license permits the intended use.

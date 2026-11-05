# Asset provenance and licensing

This file tracks the provenance and redistribution terms for files bundled under assets/. It is intentionally explicit where the repository does not yet contain enough information to verify a license. Do not assume that a file is reusable merely because it is publicly visible in this repository.

## Current inventory

| Path | Material | Information currently available | Required action before redistribution |
| --- | --- | --- | --- |
| assets/fonts/KOOkies-*.otf | Seven weights of the KOOkies/Kookies typeface | The files appear to correspond to the Kookies typeface listed by [Ko-Type](https://ko-type.com/) and attributed there to Ibrahim Hamdi. The repository does not include the font EULA or proof of redistribution rights. | Confirm the actual font license and that it permits redistribution of the font files in a public source repository and in app builds. Add the license/EULA and attribution, or replace the font with a suitably licensed alternative. |
| assets/images/**/*.png | App icon, backgrounds, cover, heading, and role illustrations | Creator, source, and license are not documented in this repository. | Record the creator/source and exact license or written permission for every image. |
| assets/sounds/**/*.wav | UI and game sound effects | Creator, source, and license are not documented in this repository. | Record the creator/source and exact license or written permission for every sound. |

## Required record for each third-party asset

For every asset that is not wholly original to the project maintainer, add:

- File path and asset name.
- Creator/copyright holder.
- Original source URL.
- Exact license name and version, or written permission.
- Required attribution text.
- Any restrictions, such as non-commercial use, no redistribution, or attribution requirements.

## Important

- The repository's LICENSE applies to original source code and project documentation only. It does not relicense bundled fonts, images, sounds, or other third-party files.
- Permission to use a font or image inside a built app does not necessarily permit publishing the original file in a public source repository. Verify both uses.
- Do not claim that assets are public domain, Creative Commons, MIT, or otherwise reusable unless the source license or written permission confirms it.
- If redistribution permission cannot be verified, remove the asset from the repository and replace it with an asset whose license permits the intended use.

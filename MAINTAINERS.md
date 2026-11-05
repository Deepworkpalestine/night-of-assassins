# Maintainer guide

## Current project ownership

- Primary maintainer: [@Deepworkpalestine](https://github.com/Deepworkpalestine)
- Repository: https://github.com/Deepworkpalestine/night-of-assassins
- Default branch: main

## Routine maintenance

- Review new issues, reproduce reported defects, and label or close duplicates.
- Review every pull request for correctness, scope, test coverage, and asset licensing.
- Keep dependencies and Flutter compatibility under review.
- Keep CI green before merging changes.
- Respond to security reports privately.
- Maintain release notes and attach verified build artifacts to versioned releases.

## Release checklist

1. Confirm the intended version in pubspec.yaml.
2. Review changes and ensure CI passes.
3. Confirm that all bundled assets have documented redistribution rights in ASSET-LICENSES.md.
4. Create and push a matching version tag, for example v1.3.0.
5. Confirm that the Android APK and SHA-256 checksum were attached to the GitHub Release.
6. Publish concise release notes describing changes and known limitations.

## Branch and review practices

Protect main in repository settings when contributor activity makes this practical. Require passing CI and at least one maintainer review for pull requests. Do not self-approve a pull request merely to create review activity; keep the review record authentic.

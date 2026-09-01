---
name: apple-app-icon-generator
description: "Generate, replace, or visually differentiate app icons for Apple Xcode projects. Use for iOS or macOS AppIcon assets, including Debug and Release variants; not for in-app UI symbols or standalone logos."
---

# Apple App Icon Generator

Generate only the primary app-icon variants that the resolved install identities require. Treat the project's build settings, asset catalogs, source artwork, and brand guidance as the source of truth.

## Workflow

1. Inspect the app target, Xcode project or workspace, existing `.appiconset` directories, editable source artwork, and brand guidance before generating anything.
2. Resolve the effective `PRODUCT_BUNDLE_IDENTIFIER` for the development and release configurations using the project's actual scheme and configuration names. Scope the check to the requested app target when the project has more than one.
3. Choose the deliverables:
   - Same resolved bundle ID: create one primary app icon.
   - Different resolved bundle IDs: create one release icon and one Debug derivative.
   - An explicit user request for a particular set wins. If the IDs cannot be resolved and the choice changes the output, ask whether the builds install side by side.
4. Create one high-resolution release master. Reuse editable source art when it exists; otherwise use the available image-generation tool. Preserve established colors and glyphs, use bold forms that stay legible at small sizes, and derive required raster sizes from the master instead of generating each size independently.
5. When two variants are required, edit the release master into the Debug icon. Preserve its main glyph and composition, then add one obvious badge, tint, or border so the two remain related but cannot be confused.
6. Install the selected output according to the target's existing asset catalog rather than a hardcoded size table. Keep approved icon sets intact unless the user explicitly asked to replace them; otherwise create a sibling candidate set. For two variants, use separate primary icon sets such as `AppIcon` and `AppIcon-Dev` and specialize `ASSETCATALOG_COMPILER_APPICON_NAME` by build configuration.
7. Verify the affected configurations build without asset-catalog warnings. For two variants, inspect both masters and representative small previews side by side: the main glyph remains recognizable, the Debug marker is immediately distinct, and neither icon clips. For one variant, skip the comparison.

## Output

Report the saved master and asset-catalog paths, why one or two variants were produced, the build-setting wiring changed, and the verification performed.

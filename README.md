<h1 align="center">HTMLViewer</h1>

<p align="center">
  A local HTML viewer and editor for iOS — open a page, edit the source, see it render, all on-device.
</p>

---

Sometimes you just want to open an HTML file on your phone, tweak a line, and see what changes without emailing it to yourself or dragging a laptop into it. Files app can't render HTML, and there's no lightweight way to edit and preview a page side by side. HTMLViewer is that: a small, local, no-account, no-backend app for viewing and editing HTML files on iOS.

Everything runs on-device. There's no server, no analytics, no account. The only thing HTMLViewer will ever reach out to the internet for is an *optional*, manual check against this repo's GitHub releases from the Settings tab — nothing else, ever.

## What it does

**Browse and organize** — create folders, create new HTML pages from a blank template, import existing files from Files or iCloud Drive, rename, delete, multi-select.

**View and edit in one place** — tap a page to see it rendered in a real WebView. Tap Edit to drop into the raw HTML source, tap Preview to save and see the result immediately. No separate editor app, no round trip.

**Share Sheet ready in spirit, not yet wired up** — files can be shared out to other apps from the context menu already; receiving files in from other apps isn't built yet.

**Same look as my other apps** — same design system as [FileManager](https://github.com/xsxs18-dev/FileManager): four built-in themes (light blue/black, red/black, light blue/white, red/white), same spacing and type scale.

**Changelog and version, right in Settings** — the current version and build number are shown in Settings, along with a Changelog screen that pulls every past release's notes straight from GitHub. A manual "Check for Updates" button is there too.

## A note on the update checker

This repo is currently **private**, and GitHub's API returns nothing to unauthenticated requests for a private repo's releases. That means the in-app "Check for Updates" and "Changelog" features won't actually find anything until this repo goes public — no code changes needed when that happens, it'll just start working.

## Getting it running

You'll need a Mac with Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (the `.xcodeproj` isn't committed — it's generated from `project.yml`):

```bash
brew install xcodegen
git clone https://github.com/xsxs18-dev/HTMLViewer.git
cd HTMLViewer
xcodegen generate
open HTMLViewer.xcodeproj
```

Set your own signing team in Xcode and build to a device.

### Don't have Xcode?

Every push to `main` builds an **unsigned** `.ipa` on GitHub Actions and publishes it straight to a new [Release](https://github.com/xsxs18-dev/HTMLViewer/releases) — one release per build, tagged `build-N`, with the raw `.ipa` attached as a downloadable asset. Grab the latest one and sign it with your own free (or paid) Apple ID using [Sideloadly](https://sideloadly.io/) or [AltStore](https://altstore.io/).

## How it's built

| | |
|---|---|
| UI | SwiftUI throughout |
| HTML rendering | `WKWebView`, loading the file's own content with its own directory as the base URL so relative links and local assets work |
| Editing | A plain monospaced text editor over the raw file, no syntax highlighting yet |
| Localization | a String Catalog (`Localizable.xcstrings`), English source + German |

```
HTMLViewer/
├── App/            entry point
├── DesignSystem/   colors, spacing, type, theme definitions, shared styles
├── Models/         PageItem
├── Services/       FileSystemService, ThemeManager, UpdateChecker
├── Views/          file browser, preview/edit screen, Settings, Changelog
└── Resources/      Assets.xcassets, Info.plist, Localizable.xcstrings

project.yml         XcodeGen project definition
.github/workflows/  CI — builds an unsigned .ipa and cuts a GitHub Release for every push
```

## Known rough edges

- No Share Sheet support yet, either direction.
- No syntax highlighting in the editor — it's a plain text box.
- Only top-level HTML rendering; if a page pulls in resources from outside its own folder, they won't load.
- No iPad-specific layout yet.

This is a small side project, still early. Contributions and bug reports welcome once it's public.

## License

MIT — see [LICENSE](LICENSE). Do whatever you want with it.

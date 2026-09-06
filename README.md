# AxLoop Community Homebrew tap

**v0.2.0 is a Mac-only preview for Apple Silicon.** Clean-machine acceptance is
pending; local Mac mini install, scan and upgrade checks have passed.

## Install and open

```sh
brew tap axloop/axloop-community
brew install --cask axloop-community
axloop-crawler open
```

In the browser, click **Run first scan**. Select an item in **Inventory** or
**Findings** to inspect its evidence. **History** shows previous scans; **Export**
saves local evidence. Coverage limitations stay visible.

Keep Terminal running while using the interface. Press **Ctrl-C** when finished.
Closing a browser tab alone does not stop the server. Installation creates no
background service and requires no hosted account.

## Open it again

```sh
axloop-crawler open
```

Your previous results remain available. Use **Run scan** to refresh them.

## Upgrade

Export from the interface first if you want a backup, then run:

```sh
brew update
brew upgrade --cask axloop-community
axloop-crawler open
```

The store stays at `~/Library/Application Support/AxLoop Community/community.sqlite`,
outside the cask. For a custom store use
`axloop-crawler --store /absolute/path/community.sqlite open`.

## Troubleshooting and release information

If the command is missing, run `brew list --cask --versions axloop-community`.
Run `axloop-crawler doctor` to check for `integrity_verified`. If the browser does
not open, see the [Community launch help](https://github.com/axloop/axloop-community#if-the-browser-does-not-open).

The cask links both `axloop-crawler` and compatibility command `axloop-community`
to the same bundled executable. Activity and hosted enrollment are unavailable.

Homebrew checks the archive checksum; the application also checks integrity before
collection. Existing quarantine handling is unchanged; this is not a notarized installer.

[Preview release](https://github.com/axloop/axloop-community/releases/tag/v0.2.0) ·
[Full installation guide](https://github.com/axloop/axloop-community#readme)

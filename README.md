# AxLoop Community Homebrew tap

Install the published Community release on an Apple Silicon Mac:

```sh
brew tap axloop/axloop-community
brew install --cask axloop-community
```

The public release is currently v0.1.0. Launch its existing interface after a scan:

```sh
axloop_bundle="$(brew --caskroom axloop-community)/0.1.0"
axloop-community scan --bundle "$axloop_bundle"
axloop-community --store "$HOME/Library/Application Support/AxLoop Community/community.sqlite" open
```

## Prepared v0.2.0 update

This branch prepares v0.2.0; its download URL is not live yet. Do not merge the cask
until the matching release is available and installation acceptance is complete.
The update links both `axloop-crawler` and the compatibility command
`axloop-community` to the same bundled executable.

After v0.2.0 is published, update and launch with:

```sh
brew update
brew upgrade --cask axloop-community
axloop-crawler open
```

Use **Run first scan** in the browser. Keep the terminal command running; Ctrl-C
stops the local server. No hosted account is needed. Activity and hosted enrollment
are unavailable in this interface.

## Local data and release verification

The Mac store is `~/Library/Application Support/AxLoop Community/community.sqlite`.
It is separate from the installed cask. Export from the local interface before an
upgrade; do not delete the store to update the application. If you used a custom
store, use `axloop-crawler --store /absolute/path/community.sqlite open`.

Homebrew checks the pinned archive checksum. The application also verifies its
release integrity before collection. This cask retains its existing quarantine
handling; the archive is not a notarized installer.

[Community releases and current status](https://github.com/axloop/axloop-community/blob/main/docs/COMMUNITY_RELEASES.md)
are the distribution record. Ruby syntax and metadata checks alone do not establish
installation or upgrade acceptance.

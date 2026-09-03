# AxLoop Community Cask Xattr Postflight Design

**Date:** 2026-09-03  
**Repository:** `axloop/homebrew-axloop-community` only  
**Base:** tap `main` at `4c08efa51f3baf8e554b6fa313ecba27115c90ee` (squash of tap PR #1)  
**Status:** Proposed Gatekeeper-relevant cask correction; live postflight evidence is still required

## Purpose and Current Truth

Repair the existing Apple Silicon Homebrew journey without changing the released bytes. The cask is already on tap `main`. On Abe's Apple Silicon Mac on 2026-09-03, `brew install` reported success, but the resulting binary link did not survive first invocation. The release tarball still contained `bin/axloop-community`. Manually extracting the archive, recursively clearing extended attributes with `xattr -cr` on the extracted tree, and running `bin/axloop-community --help` succeeded.

The payload is an unsigned, un-notarized PyInstaller onedir bundle. Its launcher is beside `bin/_internal`, and it ships `osquery.app`. Quarantine on the staged payload breaks invocation through the linked binary; clearing quarantine restores invocation. This evidence identifies the proposed correction, but it does not prove that the corrected cask gives a stranger a working one-command install. That claim remains closed until the exact postflight SHA passes the clean live-Mac journey.

The current cask at the base SHA is:

```ruby
cask "axloop-community" do
  version "0.1.0"
  sha256 "27e993467ee3b57c891c416ab5963032020b38218f2c57d890f094f791ca2043"

  url "https://github.com/axloop/axloop-community/releases/download/v0.1.0/axloop-community-darwin-arm64-3a7bfeeb.tar.gz"
  name "AxLoop Community"
  desc "Community edition of AxLoop"
  homepage "https://github.com/axloop/axloop-community"

  depends_on arch: :arm64

  binary "bin/axloop-community"
end
```

## Global Constraints

- Scope is `axloop/homebrew-axloop-community` only, based on `4c08efa51f3baf8e554b6fa313ecba27115c90ee`.
- The eventual writer may modify only `Casks/axloop-community.rb`.
- This authoring change contains only the two files under `docs/superpowers/`; it does not edit the cask.
- Keep version `0.1.0`, the pinned release URL, and SHA-256 `27e993467ee3b57c891c416ab5963032020b38218f2c57d890f094f791ca2043` unchanged.
- Keep `depends_on arch: :arm64`; add no minimum macOS floor.
- Do not change Community documentation or anything in `axloop/axloop-community`.
- Do not add Developer ID work, notarization, a release, a tag, `.github`, workflows, or visitor instructions for manual quarantine removal.
- Do not claim the payload is signed or notarized.
- No merge occurs unless Abe explicitly says to merge.

## Alternatives and Decision

1. **Structured `postflight_steps` (recommended):** after declaring the `binary` artifact, run `/usr/bin/xattr` with literal arguments `-cr` and the install-time staged path. This automates the operation that restored invocation while preserving the archive, checksum, architecture gate, and PyInstaller onedir layout.
2. **Manual visitor `xattr -cr` after installation:** rejected because a stranger would need a rescue step after the advertised install command. That fails the one-command stranger bar and externalizes a security-sensitive workaround.
3. **Developer ID signing and notarization:** rejected for this correction. That is Nolan's later path, is outside this tap-only scope, and Abe did not request it here.
4. **Legacy Ruby `postflight` with `system`:** rejected. The [Homebrew Cask Cookbook](https://docs.brew.sh/Cask-Cookbook) says official taps must use structured `preflight_steps` and `postflight_steps`, with legacy Ruby flight blocks rejected there and retained only temporarily for third-party-tap compatibility. This third-party tap should choose the structured, future-facing form.

## Cask Contract

The eventual cask change is exactly one structured stanza after the `binary` artifact:

```ruby
  binary "bin/axloop-community"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-cr", "{{staged_path}}"]
  end
```

The [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook) defines `postflight_steps` as declarative preparation performed after artifact installation. A steps block accepts supported operations with literal arguments. Its `run` operation executes one executable with literal arguments rather than evaluating a shell command string, and a nonzero exit aborts installation by default. `{{staged_path}}` is a supported token expanded at install time. Although path-taking steps should prefer `base:` when available, this command needs the staged directory as an argument to `/usr/bin/xattr`; the explicit token makes that target unambiguous.

The resulting complete intended cask is:

```ruby
cask "axloop-community" do
  version "0.1.0"
  sha256 "27e993467ee3b57c891c416ab5963032020b38218f2c57d890f094f791ca2043"

  url "https://github.com/axloop/axloop-community/releases/download/v0.1.0/axloop-community-darwin-arm64-3a7bfeeb.tar.gz"
  name "AxLoop Community"
  desc "Community edition of AxLoop"
  homepage "https://github.com/axloop/axloop-community"

  depends_on arch: :arm64

  binary "bin/axloop-community"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-cr", "{{staged_path}}"]
  end
end
```

No other line changes. In particular, the URL and digest remain immutable, the ARM requirement remains, and no macOS version floor appears.

## Installation Flow and Failure Semantics

Homebrew fetches and verifies the existing pinned archive, stages the onedir tree, installs the `binary` artifact by linking `bin/axloop-community`, and then runs the structured postflight step against the staged tree. `/usr/bin/xattr -cr` recursively removes extended attributes from that tree before the stranger invokes the link. Its scope includes the launcher, `bin/_internal`, and the shipped `osquery.app`; clearing only the linked launcher would not match the successful manual experiment or the payload's sibling-dependent structure.

The operation deliberately clears `com.apple.quarantine` **and other extended attributes** on the entire staged tree. That is a Gatekeeper-relevant security change, not a neutral packaging cleanup. Nolan must score the exact proposed change before the writer lands it. If `xattr` returns nonzero, the structured `run` step fails the installation rather than reporting a misleading success. The implementation must not suppress failure with `must_succeed: false`.

No visitor-facing copy may describe the payload as signed, notarized, or equivalent to either. The correction automates attribute removal; it does not establish producer identity or replace signing and notarization.

## Verification Contract

Static cask inspection can prove the intended stanza, unchanged pin, and allowlist. It cannot prove the stranger journey. After the required review gates, Elena drives a clean Apple Silicon Mac against the writer's exact tap head SHA:

1. Remove an existing installation if present and establish the clean starting state.
2. Install the fully qualified cask from the new tap SHA.
3. Confirm `command -v axloop-community` resolves.
4. Confirm `com.apple.quarantine` is absent from the staged payload after installation: `xattr -p com.apple.quarantine` on the staged binary must produce no value and return nonzero.
5. Run `axloop-community --help` as the first visitor invocation. It must exit 0 without a prompt, denial, or manual rescue.
6. Uninstall and confirm cleanup.

Record the exact commands, stdout, stderr, and exit status; the full tap head SHA; Apple Silicon architecture; macOS and Homebrew versions; staged binary path; resolved command path and link destination; quarantine probe; invocation; and cleanup. Do not invent Homebrew error wording. Any missing field or failed assertion keeps the one-command claim closed.

## Review and Landing Authority

The authoring pull request is docs-only. Its execution gates are ordered: Imani supplies a dated pack, Reed attacks the plan and threat assumptions, then Kit posts a GitHub COMMENT on the plan's full head SHA. Reviewer cells stay blank in these artifacts. Any plan-head change invalidates Kit's SHA binding and requires the ordered gate to be refreshed.

Nolan separately scores the exact quarantine-clearing change before the writer lands it. Only after Kit's COMMENT may Elena launch Fable 5.1 at low reasoning to execute the plan. The writer changes only `Casks/axloop-community.rb`. No one merges unless Abe explicitly directs the merge.

## Execution Gate

| Reviewer | Evidence | Date | GitHub COMMENT / SHA |
| --- | --- | --- | --- |
| Imani |  |  |  |
| Reed |  |  |  |
| Kit |  |  |  |

## Acceptance and Handoff

Acceptance requires the one-file allowlist, exact structured stanza, unchanged URL/digest/ARM declaration, no macOS floor, Nolan's completed security score, ordered current-head gates, and Elena's complete successful clean-Mac record against the postflight SHA. Until then, state only that the manual experiment supports the design; do not claim a working one-command install.

Hand the design, blank gate table, Nolan requirement, exact writer SHA, live evidence, scope audit, and any blocker to Abe. Do not merge, publish, tag, release, edit visitor documentation, or turn missing evidence into optimistic copy.

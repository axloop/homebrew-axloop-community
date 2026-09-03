# AxLoop Community Cask Xattr Postflight Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add one structured postflight step that clears extended attributes from the staged AxLoop Community payload, then prove the linked command works without manual rescue on a clean Apple Silicon Mac.

**Architecture:** Preserve the existing pinned cask and append a structured `postflight_steps` operation after its binary artifact. Treat the change as Gatekeeper-relevant, require Nolan's score and ordered reviewer authorization before writing, and use Elena's live install as the acceptance test.

**Tech Stack:** Homebrew Cask Ruby DSL, `/usr/bin/xattr`, macOS Gatekeeper extended attributes, PyInstaller onedir payload.

**Spec:** `docs/superpowers/specs/2026-09-03-axloop-community-cask-xattr-postflight-design.md`

## Today's Truth

The cask is on `axloop/homebrew-axloop-community` tap `main` at `4c08efa51f3baf8e554b6fa313ecba27115c90ee`. On Abe's Apple Silicon Mac on 2026-09-03, `brew install` reported success, but the linked binary failed on first invocation. The release archive still contained `bin/axloop-community`. Manual extraction, `xattr -cr` on the extracted tree, and `bin/axloop-community --help` succeeded. Quarantine on the staged unsigned, un-notarized PyInstaller onedir payload is therefore the observed failure boundary; a postflight cask has not yet been proved live.

## Global Constraints

- Repository: `axloop/homebrew-axloop-community` only; base tap `main` SHA `4c08efa51f3baf8e554b6fa313ecba27115c90ee`.
- Writer allowlist: only `Casks/axloop-community.rb`. Every other path is forbidden.
- Do not edit Community docs or `axloop/axloop-community`; do not add Developer ID, notarization, a release, a tag, `.github`, or workflows.
- Keep version `0.1.0` unchanged.
- Keep URL `https://github.com/axloop/axloop-community/releases/download/v0.1.0/axloop-community-darwin-arm64-3a7bfeeb.tar.gz` unchanged.
- Keep SHA-256 `27e993467ee3b57c891c416ab5963032020b38218f2c57d890f094f791ca2043` unchanged.
- Keep `depends_on arch: :arm64`; do not add a minimum macOS floor.
- Use structured `postflight_steps`; do not use legacy Ruby `postflight`, `system`, a shell command string, or `must_succeed: false`.
- The step deliberately removes `com.apple.quarantine` and other extended attributes from the staged tree. Nolan scores this Gatekeeper-relevant change before the writer lands it.
- Visitor copy must not claim the payload is signed or notarized and must not prescribe manual `xattr` rescue.
- Do not claim a working one-command install until Elena's clean live-Mac evidence exists for the exact postflight head SHA.
- Gate order is Imani dated pack, Reed attack, then Kit GitHub COMMENT on the plan's full head SHA. Keep reviewer slots blank.
- No writer starts before Kit's COMMENT. After that COMMENT, Elena launches Fable 5.1 low.
- No merge unless Abe explicitly says to merge.

---

## Execution Gate

| Reviewer | Evidence | Date | GitHub COMMENT / SHA |
| --- | --- | --- | --- |
| Imani |  |  |  |
| Reed |  |  |  |
| Kit |  |  |  |

Do not begin Task 1 until Imani's dated pack exists, Reed has attacked it and this plan, and Kit has posted a GitHub COMMENT binding approval to the plan's full head SHA in that order. Any plan-head change reopens the gate. Do not fill this table in the authored plan.

### Task 1: Close the review and security gates

**Files:**

- Read: `docs/superpowers/specs/2026-09-03-axloop-community-cask-xattr-postflight-design.md`
- Read: `docs/superpowers/plans/2026-09-03-axloop-community-cask-xattr-postflight.md`
- Modify: none

**Interfaces:**

- Consumes: docs-only plan head SHA, Imani dated pack, Reed attack, Kit GitHub COMMENT, Nolan quarantine-clearing score.
- Produces: explicit authorization to launch one constrained writer, or a hard stop returned to Abe.

- [ ] **Step 1: Bind Imani's dated pack to the plan head**

Run: `gh pr view --repo axloop/homebrew-axloop-community --json headRefOid,comments,reviews`

Expected: output for the current branch's docs-only pull request identifies the full current plan head SHA and an Imani artifact with a date. If the branch has no pull request, stop; do not guess an identifier.

- [ ] **Step 2: Confirm Reed's attack follows Imani**

Run: `gh pr view --repo axloop/homebrew-axloop-community --json headRefOid,comments,reviews`

Expected: Reed's review challenges the quarantine-removal scope, whole-tree targeting, failure behavior, and live proof, and is timestamped after Imani's dated pack. A generic approval is insufficient.

- [ ] **Step 3: Confirm Kit's SHA-bound COMMENT follows Reed**

Run: `gh pr view --repo axloop/homebrew-axloop-community --json headRefOid,comments`

Expected: Kit's GitHub COMMENT names the same full `headRefOid`, appears after Reed's attack, and authorizes writer launch—not merge. If the head differs, stop and restart the ordered review.

- [ ] **Step 4: Obtain Nolan's security score before landing**

Give Nolan the exact proposed command and scope:

```ruby
postflight_steps do
  run "/usr/bin/xattr", args: ["-cr", "{{staged_path}}"]
end
```

Expected: Nolan records that `-c` clears all extended attributes, including `com.apple.quarantine`, recursively across the staged PyInstaller tree and shipped `osquery.app`; evaluates the Gatekeeper effect; and returns an explicit accept/block result. A missing or blocking score stops landing.

- [ ] **Step 5: Launch the constrained writer**

Elena launches Fable 5.1 with low reasoning only after Steps 1–4 pass. Provide the repository, base SHA, single-file allowlist, exact stanza, and no-merge instruction.

Expected: one writer is scoped to `Casks/axloop-community.rb`; it has no authority to merge, publish, tag, release, or touch another file.

### Task 2: Establish RED against the unchanged base cask

**Files:**

- Read: `Casks/axloop-community.rb`
- Modify: none

**Interfaces:**

- Consumes: base `4c08efa51f3baf8e554b6fa313ecba27115c90ee` and Task 1 authorization.
- Produces: recorded failure of the missing structured postflight contract before production editing.

- [ ] **Step 1: Confirm the exact base**

Run: `test "$(git rev-parse HEAD)" = "4c08efa51f3baf8e554b6fa313ecba27115c90ee"`

Expected: exit 0 and no output. Any other SHA stops execution for Abe rather than silently rebasing the plan.

- [ ] **Step 2: Confirm the writer allowlist starts clean**

Run: `git status --short`

Expected: no output. If the worktree has changes, stop; do not overwrite or absorb them.

- [ ] **Step 3: Write the failing structural assertion without editing the cask**

Run:

```bash
ruby -e 'p = "Casks/axloop-community.rb"; s = File.read(p); abort "missing structured xattr postflight" unless s.include?(%q{postflight_steps do\n    run "/usr/bin/xattr", args: ["-cr", "{{staged_path}}"]\n  end})'
```

Expected: nonzero exit and `missing structured xattr postflight`. This is RED because the required behavior is absent from the base cask. Do not edit production content before observing this result.

- [ ] **Step 4: Record today's live behavioral RED**

Attach the 2026-09-03 Abe-Mac record showing: install reported success; `command -v` resolved the linked command before invocation; first invocation failed with quarantine present; manual extraction plus recursive xattr clearing made `bin/axloop-community --help` exit 0.

Expected: the evidence identifies the original defect without inventing Homebrew error text. It is historical RED, not proof of the new postflight.

### Task 3: Add the minimal structured postflight

**Files:**

- Modify: `Casks/axloop-community.rb`
- Test: inline structural commands against `Casks/axloop-community.rb`

**Interfaces:**

- Consumes: the observed structural RED and exact base cask.
- Produces: a single-file cask change invoking `/usr/bin/xattr` with literal `-cr` and the install-time staged-path token after the binary artifact.

- [ ] **Step 1: Add only the intended stanza**

Make the cask exactly:

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

Expected: no other content or path changes.

- [ ] **Step 2: Run structural GREEN**

Run:

```bash
ruby -e 'p = "Casks/axloop-community.rb"; s = File.read(p); abort "missing structured xattr postflight" unless s.include?(%q{postflight_steps do\n    run "/usr/bin/xattr", args: ["-cr", "{{staged_path}}"]\n  end})'
```

Expected: exit 0 and no output.

- [ ] **Step 3: Assert immutable fields and forbidden forms**

Run:

```bash
ruby -e 's = File.read("Casks/axloop-community.rb"); required = [%q{version "0.1.0"}, %q{sha256 "27e993467ee3b57c891c416ab5963032020b38218f2c57d890f094f791ca2043"}, %q{url "https://github.com/axloop/axloop-community/releases/download/v0.1.0/axloop-community-darwin-arm64-3a7bfeeb.tar.gz"}, %q{depends_on arch: :arm64}, %q{binary "bin/axloop-community"}]; abort "immutable cask contract changed" unless required.all? { |v| s.include?(v) }; abort "forbidden flight form" if s.match?(/^\s*postflight\s+do/) || s.include?("system ") || s.include?("must_succeed: false") || s.match?(/depends_on\s+macos:/)'
```

Expected: exit 0 and no output.

- [ ] **Step 4: Run Homebrew syntax and style checks**

Run: `brew style --cask Casks/axloop-community.rb`

Expected: exit 0 with no offenses. If the installed Homebrew requires a fully qualified cask token for a check, record and use its exact accepted command; do not weaken the stanza.

- [ ] **Step 5: Audit the writer scope**

Run: `git diff --name-only`

Expected: exactly `Casks/axloop-community.rb`.

Run: `git diff -- Casks/axloop-community.rb`

Expected: only the blank line plus `postflight_steps` block after `binary "bin/axloop-community"`; the pin, architecture requirement, and all other lines are unchanged.

- [ ] **Step 6: Commit the isolated writer change**

Run: `git add Casks/axloop-community.rb && git commit -m "fix: clear staged cask quarantine"`

Expected: one commit containing only `Casks/axloop-community.rb`. This authorizes a reviewable head, not merge.

### Task 4: Prove the postflight SHA on Elena's clean Apple Silicon Mac

**Files:**

- Read: `Casks/axloop-community.rb` at the writer head SHA
- Modify: none
- Capture: live evidence outside the repository change

**Interfaces:**

- Consumes: Task 3 writer head SHA and Abe's Apple Silicon Mac.
- Produces: the only evidence capable of opening the one-command-install claim, or a hard stop.

- [ ] **Step 1: Record the exact test target and machine**

Run individually:

```text
git rev-parse HEAD
uname -m
sw_vers
brew --version
```

Expected: full writer head SHA recorded; `uname -m` prints `arm64`; macOS and Homebrew versions captured. Preserve exact stdout, stderr, and statuses.

- [ ] **Step 2: Uninstall if present and establish clean state**

Run: `brew uninstall --cask axloop/axloop-community/axloop-community`

Expected: if installed, exit 0 and uninstall output; if absent, record the actual nonzero result without inventing its text.

Run: `command -v axloop-community`

Expected: nonzero exit and no resolved command. If it resolves, remove only identified installation residue through normal Homebrew cleanup and repeat the check; do not delete unrelated paths.

- [ ] **Step 3: Install from the exact new tap SHA**

Confirm the local tap checkout is at the Task 3 head, then run: `brew install axloop/axloop-community/axloop-community`

Expected: exit 0 with the exact output captured. Record the cask SHA actually used. Do not treat `brew install` success alone as feature success.

- [ ] **Step 4: Assert command resolution**

Run: `command -v axloop-community`

Expected: exit 0 and an absolute resolved executable path. Record the path and resolve its symlink destination to the staged `bin/axloop-community`.

- [ ] **Step 5: Assert quarantine is absent after install**

Run: `/usr/bin/xattr -p com.apple.quarantine "$(readlink "$(command -v axloop-community)")"`

Expected: nonzero exit and no quarantine value. Record stdout, stderr, and status; do not invent or require exact diagnostic text. If a value is printed or status is zero, stop: the postflight did not establish the required state.

- [ ] **Step 6: Run the first stranger invocation without rescue**

Run: `axloop-community --help`

Expected: exit 0, help output, no macOS prompt, no denial, and no intervening `xattr`, Gatekeeper bypass, relink, re-extraction, or other manual rescue. Capture exact output and status.

- [ ] **Step 7: Uninstall and prove cleanup**

Run: `brew uninstall --cask axloop/axloop-community/axloop-community`

Expected: exit 0 with uninstall output captured.

Run: `command -v axloop-community`

Expected: nonzero exit and no resolved command. Record any remaining Caskroom state rather than deleting unrelated data.

- [ ] **Step 8: Apply the hard stop**

The live record must contain the writer head SHA, `arm64`, macOS/Homebrew versions, clean start, install command/output/status, resolved command and staged binary, quarantine probe/output/status, prompt-free `--help` output/status, and uninstall cleanup. If any field is missing or any assertion fails, report: `Blocked: the postflight SHA has not proved a working one-command install on the clean Apple Silicon Mac.`

### Task 5: Reverify scope and hand off without merging

**Files:**

- Verify: `Casks/axloop-community.rb`
- Verify unchanged: every other repository path
- Modify: none

**Interfaces:**

- Consumes: Task 3 static evidence, Task 4 live evidence, Nolan's score, and Abe's merge authority.
- Produces: a precise evidence packet for Abe; no merge or publication.

- [ ] **Step 1: Run fresh static verification**

Run the structural GREEN command, immutable/forbidden-form command, and `brew style --cask Casks/axloop-community.rb` from Task 3 again.

Expected: every command exits 0; structural commands print nothing; Homebrew reports no style offenses.

- [ ] **Step 2: Recheck the final allowlist**

Run: `git diff --name-only 4c08efa51f3baf8e554b6fa313ecba27115c90ee...HEAD`

Expected: exactly `Casks/axloop-community.rb`.

Run: `git diff 4c08efa51f3baf8e554b6fa313ecba27115c90ee...HEAD -- Casks/axloop-community.rb`

Expected: only the structured postflight addition shown in Task 3.

- [ ] **Step 3: Apply verification-before-completion**

Read every fresh exit status and the complete Task 4 record. Claim a working one-command install only if static checks pass and the exact writer SHA completed the live journey with no prompt, denial, or rescue. Otherwise state the precise blocker.

- [ ] **Step 4: Prepare Abe's handoff**

Include the base SHA, writer head SHA, sole changed path, exact diff, Imani/Reed/Kit ordered evidence, Nolan's score, style output, structural RED/GREEN record, Elena's full clean-Mac record, and any blocker.

Expected: the handoff asks Abe for an explicit merge decision and performs no merge.

## Handoff

Return to Abe the docs-only gate record, Nolan's Gatekeeper score, writer identity and exact head SHA, one-file scope audit, immutable-field checks, Homebrew style output, structural RED/GREEN evidence, and Elena's install/resolution/quarantine/`--help`/cleanup evidence. State plainly whether the hard stop is open or closed. Do not merge unless Abe says; do not push, open another pull request, publish, tag, release, edit visitor documentation, or describe the unsigned and un-notarized payload as signed or notarized.

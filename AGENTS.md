# Working on the AxLoop Community Homebrew tap

Read README.md, the cask, and the current issue/PR before changes. This repository
owns installation metadata for approved Community releases. It does not build the
application or define private product strategy. Community is the local entry point
to hosted; public installation claims must match published artifacts.

Use the public AxLoop Community release documentation as the distribution record.
Keep archive URL, version, digest, and installed commands aligned. Never silently
change quarantine handling or substitute an unverified candidate. Product work,
release approval, and native acceptance are separate from cask syntax checks.

Keep issue/PR handoffs factual and link public evidence. Do not include internal
repository links, private plans, credentials, or session material in this public tap.
Preserve unrelated work and existing owner approval boundaries.

This repo is onboarded through .agent-stack.toml. Run agent-stack-config to inspect
it and agent-stack-verify --repo <physical-repository-root> after changes, retaining
the receipt. The verifier checks Ruby syntax and pinned cask metadata offline;
actual archive digests and fresh/upgrade Homebrew acceptance need separate evidence.

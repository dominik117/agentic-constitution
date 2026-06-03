# agentic-constitution

Canonical, cross-system **agentic design charter** for Dominik Bacher's projects. `CONSTITUTION.md` here is the single source of truth (*Build it like a professional* — one source of truth per fact): every project references it instead of vendoring a copy, so the doctrine cannot drift between repos.

## Consumption pattern

A new project does **not** copy `CONSTITUTION.md` into its tree. Instead, its `CLAUDE.md` treats the canonical raw URL as authoritative for the full doctrine + rationale:

```
https://raw.githubusercontent.com/dominik117/agentic-constitution/main/CONSTITUTION.md
```

Each repo keeps only a lean **enforce-list** — the handful of Articles that actually bind locally, one line each on how they apply in that project. Full text and the *why* stay here; the per-repo `CLAUDE.md` stays short.

## Make the agent actually follow it

Only `CLAUDE.md` is auto-loaded into the agent's context every session. The canonical URL is **not** auto-fetched — the agent reads it only if it decides to, which is rare. So the **enforce-list in `CLAUDE.md` is the layer that actually binds the agent**; the URL is rationale and onboarding, not the working copy. When authoring a repo's `CLAUDE.md`:

1. **Make the enforce-list self-sufficient.** Every Article that binds locally gets an imperative one-liner + a one-line project application — enough to act on *without fetching anything*. The URL is for the *why*, the edge cases, and the Test.
2. **Don't "fix forgetting" by vendoring.** Copying `CONSTITUTION.md` into the repo does **not** help — a file in the tree is no more auto-loaded than the URL; the agent still has to choose to open it. If you need adherence stronger than the enforce-list, **inject it at session start** (a Claude Code `SessionStart` hook), don't copy a file the agent won't read.

**Ready-to-copy hook recipe** (optional): [`templates/hooks/inject-constitution.sh`](templates/hooks/inject-constitution.sh) + [`templates/settings.json`](templates/settings.json). Drop the script at `.claude/hooks/` (`chmod +x`), copy the settings to `.claude/settings.json`. It extracts the enforce-list **live from your `CLAUDE.md`** (no second copy to drift, ~a few hundred tokens) and re-injects it on **compaction** — the moment a long session's context gets summarized and the rules slip. For SessionStart, plain stdout is added to context, so no JSON plumbing is needed.

## Starting a new repo

Use [`templates/CLAUDE.template.md`](templates/CLAUDE.template.md) as the scaffold for any new repo's `CLAUDE.md`. Carry the reusable core (Owner, Communication, Working style, Definition of Ready/Done, universal Lessons) verbatim; fill the `{{PLACEHOLDER}}` tokens with project specifics.

## Design rationale

- **Reference-by-URL, not vendoring.** Copying the charter into each repo reintroduces drift the moment it changes — you'd have to chase N copies. One canonical URL is zero-drift by construction: every consumer fetches the same bytes.
- **Public, on purpose.** No-auth raw fetch (consumers need no token), and it doubles as portfolio. The charter is *principles only* — never secrets, hostnames, IPs, or private paths. A gitleaks pre-commit hook is light insurance against that line being crossed.

## License

Released under [CC-BY-4.0](LICENSE) — reuse freely with attribution.

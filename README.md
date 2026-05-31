# agentic-constitution

Canonical, cross-system **agentic design charter** for Dominik Bacher's projects. `CONSTITUTION.md` here is the single source of truth (Article 11): every project references it instead of vendoring a copy, so the doctrine cannot drift between repos.

## Consumption pattern

A new project does **not** copy `CONSTITUTION.md` into its tree. Instead, its `CLAUDE.md` treats the canonical raw URL as authoritative for the full doctrine + rationale:

```
https://raw.githubusercontent.com/dominik117/agentic-constitution/main/CONSTITUTION.md
```

Each repo keeps only a lean **enforce-list** — the handful of Articles that actually bind locally, one line each on how they apply in that project. Full text and the *why* stay here; the per-repo `CLAUDE.md` stays short.

## Starting a new repo

Use [`templates/CLAUDE.template.md`](templates/CLAUDE.template.md) as the scaffold for any new repo's `CLAUDE.md`. Carry the reusable core (Owner, Communication, Working style, Definition of Ready/Done, universal Lessons) verbatim; fill the `{{PLACEHOLDER}}` tokens with project specifics.

## Design rationale

- **Reference-by-URL, not vendoring.** Copying the charter into each repo reintroduces drift the moment it changes — you'd have to chase N copies. One canonical URL is zero-drift by construction: every consumer fetches the same bytes.
- **Public, on purpose.** No-auth raw fetch (consumers need no token), and it doubles as portfolio. The charter is *principles only* — never secrets, hostnames, IPs, or private paths. A gitleaks pre-commit hook is light insurance against that line being crossed.

## License

Released under [CC-BY-4.0](LICENSE) — reuse freely with attribution.

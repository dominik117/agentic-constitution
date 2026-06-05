# {{PROJECT_NAME}} — Claude Code project context

> Operational charter. **Rules + current truth only.** The *why* behind decisions lives in the canonical CONSTITUTION (linked below) and your project's design notes — read those for rationale; they are *not* auto-loaded, so this file stays lean. Keep under 200 lines.

## Project
{{ONE_LINE_PURPOSE}}

Source of truth:
{{SOURCE_OF_TRUTH_FILES}}

## Owner
Dominik Bacher (`dominik117`). PO at Lufthansa Group Digital Hangar, Zurich; ex-data-scientist. **ADHD** — structured output, no wasted cycles.

## Communication
1. Direct, concise. No preambles/fluff.
2. Numbered lists over bullets (referenceable: "do 3a").
3. Bold key terms/values. Tables for structured data.
4. One question at a time.
5. Honest pushback expected — flag suboptimal requests with reasoning.
6. Search before guessing present-day facts (versions, prices, current defaults).
7. No `# comments` inside copy-paste bash blocks — Dominik pastes line-by-line; comments break as separate input.

## Working style
1. Show diffs before applying to existing files.
2. Commit messages terse, imperative ("add cost ledger schema").
3. Branch per feature; main stays green.
4. Test locally before push; smoke-test the happy path.
5. Before writing/editing any file: propose the approach, list risks, argue against yourself, wait for approval.
6. Before adding or configuring any dependency, model, or tool: read its README/card/official docs and verify names, versions, and parameters against the source. After building: re-check your output against those sources and correct drift. Never configure from memory.

(Toolchain conventions — language/runtime, package manager, linter — go in {{PROJECT_SPECIFIC_SECTIONS}}.)

## Definition of Ready (before a task starts)
A task is ready to hand over when it states: **objective, scope (which files), constraints, and acceptance criteria.** If "done" can't be stated, it's not ready — clarify first.

## Definition of Done (before a task closes)
1. Compiles and lints clean.
2. Smoke test passes end-to-end — happy path, plus the cap path for anything billable.
3. Diff reviewed and approved.
4. Committed on a feature branch, terse imperative message; main green.
5. Any durable-fact change reflected here (CLAUDE.md) and in the session progress log.

## Constitution — enforce
Full text + rationale (canonical — do **not** vendor a copy):
https://raw.githubusercontent.com/dominik117/agentic-constitution/main/CONSTITUTION.md

> These one-liners are the working copy the agent always has in context — **act on them for the common case**. The linked Article is the full rule: fetch it for the rationale, the nuance, and the Test, or whenever a one-liner is ambiguous at an edge. Keep each line imperative and self-sufficient so adherence never depends on a fetch that may not happen.

{{CONSTITUTION_ENFORCE_LIST}}

## Operational context
{{OPERATIONAL_CONTEXT}}

## {{PROJECT_SPECIFIC_SECTIONS}}

## Lessons (don't repeat)
1. Long SSH commands (`ollama pull`, etc.) go in `tmux new -s <name>` — survive network drops.
2. Don't guess versions (Homebrew/tooling/packages) — search docs.
3. Never paste secrets in commands — use `$VAR`.
4. Update the session progress doc at session end — append a new "Session N" entry, don't edit in place.
5. Never delete content from Dominik's canonical docs without approval — reorganize/move, never silently drop. Show ADDED / UPDATED / REMOVED; say "Nothing removed" when true.
6. **Debugging / diagnosis:** check what you already know first (context, memory, logs) — the cause is often already there. Rank hypotheses by how common they are and test the cheapest / most-likely first. Never send the user to act (call support, change a setting, move money) on an unverified guess; state your confidence. (Constitution: *When you think, think like a scientist and an engineer*.)
7. **After a caught mistake:** don't promise "it won't happen again" — that's empty for an LLM. Propose the durable fix: a rule, a check, or a test, recorded in `design-notes.md`. Lessons become artifacts. (Constitution: *Lessons become checked artifacts*.)

## Layout
{{LAYOUT}}

---
_Keep under 200 lines. Update when conventions change._

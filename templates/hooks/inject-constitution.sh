#!/bin/bash
# OPTIONAL Claude Code SessionStart hook — re-inject the enforce-list into the agent's
# context on every session start, INCLUDING after compaction (when CLAUDE.md gets
# summarized and the rules drift). For SessionStart, plain stdout is added to context.
#
# Single source of truth: the "## Constitution — enforce" section of the project's
# CLAUDE.md — this extracts it live, so there is no second copy to drift. Costs only a
# few hundred tokens/session. Wire it up via templates/settings.json (copy to
# .claude/settings.json) and `chmod +x` this script under .claude/hooks/.
root="${CLAUDE_PROJECT_DIR:-.}"
md="$root/CLAUDE.md"
[ -f "$md" ] && awk '
  /^## Constitution/ {
    f=1
    print "[Constitution enforce-list — re-asserted at session start; act on these one-liners; full text at the canonical URL in CLAUDE.md]"
    print; next
  }
  /^## / { if (f) exit }
  f { print }
' "$md"
exit 0

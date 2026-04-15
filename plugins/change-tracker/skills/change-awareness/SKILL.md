---
name: change-awareness
description: >
  Use when the developer asks about recent changes, what was modified,
  or needs to understand the scope of edits in the session.
  Auto-triggers on: "what changed", "what did I edit", "show changes",
  "change summary", "what files were touched".
allowed-tools:
  - Read
  - Grep
  - Bash
---

<purpose>
Help the developer understand what Claude changed and why.
Translate raw change data into semantic summaries.
Group by intent, not by file. Show impact radius.
</purpose>

<constraints>
1. NEVER fabricate changes — only report from changes.jsonl.
2. NEVER list raw diffs — always summarize semantically.
3. ALWAYS show change type classification (source_code, config_change, test_change, etc.).
4. ALWAYS show cluster relationships when multiple files changed together.
</constraints>

<decision_tree>
IF user asks about a specific file:
  → Read ${CLAUDE_PLUGIN_ROOT}/state/changes.jsonl
  → grep for that file path
  → Show: change type, number of edits, hash history
  → If file has been reverted (hash matches previous): flag it

IF user asks about session scope:
  → Read ${CLAUDE_PLUGIN_ROOT}/state/changes.jsonl
  → Group changes by type
  → Show: N files changed, grouped by type, with counts
  → Show impact radius: local (1 file), module (2-5), systemic (6+)

IF user asks about clusters:
  → Read ${CLAUDE_PLUGIN_ROOT}/state/changes.jsonl
  → Group by cluster_id
  → Explain: "These files were changed together because they're in the same directory"

IF no changes tracked:
  → "No changes tracked yet. Changes are recorded after Write/Edit operations."
</decision_tree>

<output_format>
## Session Changes ([N] turns)

### [Cluster/Intent Name] ([N] files, [impact radius])
[Semantic summary of what changed and why]
Trust: [score] ([high/medium/low])

### [Next cluster...]
...

Summary: [N] files changed | [N] clusters | [high-risk count] need review
</output_format>

<escalate_to_sonnet>
IF change pattern is complex (many clusters, mixed types):
  "ESCALATE_TO_SONNET: complex change pattern needs deeper analysis"
IF user needs semantic explanation of WHY changes were made:
  "ESCALATE_TO_SONNET: intent analysis needed"
</escalate_to_sonnet>

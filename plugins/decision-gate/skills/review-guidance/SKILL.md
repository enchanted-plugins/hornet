---
name: review-guidance
description: >
  Use when a review advisory fires or developer wants to understand
  what to review and why. Explains information-gain prioritization.
  Auto-triggers on: "review advisory", "what should I review",
  "which changes matter", "priority review", "adversarial review".
allowed-tools:
  - Read
  - Grep
  - Bash
---

<purpose>
Help the developer focus review on the changes that matter most.
Use information-gain ordering to prioritize.
Present adversarial questions for low-trust changes.
</purpose>

<constraints>
1. NEVER skip adversarial questions for critical-trust changes.
2. NEVER claim a change is safe without trust data to support it.
3. ALWAYS explain the IG ranking — why this change was surfaced first.
4. ALWAYS present changes in IG order, not file order.
</constraints>

<decision_tree>
IF single file flagged for review:
  → Read trust score from ${CLAUDE_PLUGIN_ROOT}/../trust-scorer/state/trust.json
  → Show: file, trust score, change type, IG value
  → Show adversarial questions (type-specific)
  → "Review this change. The questions above highlight what could go wrong."

IF multiple files need review:
  → Read all trust scores
  → Rank by information gain (highest entropy = most uncertain = review first)
  → Present top 3 with trust scores and adversarial questions
  → "Start with [file1] — it has the highest information gain (most uncertain trust)."

IF all files have high trust:
  → "No files currently need review. All tracked files are above the trust threshold (0.8)."
  → Show summary: [N] files tracked, average trust [score].

IF no trust data available:
  → "No trust scores computed yet. Trust scoring begins after the first Write/Edit operation."
</decision_tree>

<information_gain_explanation>
Information gain = binary entropy of the trust score.
- Trust 0.5 → IG 1.0 (maximum uncertainty — review this first)
- Trust 0.1 → IG 0.47 (clearly bad — but you already know it's bad)
- Trust 0.9 → IG 0.47 (clearly good — low review value)
The most valuable review targets are files where trust is uncertain (0.3-0.7).
</information_gain_explanation>

<escalate_to_sonnet>
IF complex multi-file review with conflicting trust signals:
  "ESCALATE_TO_SONNET: multi-file review needs cross-reference analysis"
IF user needs help understanding adversarial questions:
  "ESCALATE_TO_SONNET: adversarial question context needed"
</escalate_to_sonnet>

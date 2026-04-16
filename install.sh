#!/usr/bin/env bash
# Hornet installer. The 4 plugins are a coordinated bundle — they install
# together or not at all (see .claude-plugin/plugin.json → dependencies).
set -euo pipefail

REPO="https://github.com/enchanted-plugins/hornet"
HORNET_DIR="${HOME}/.claude/plugins/hornet"

step() { printf "\n\033[1;36m▸ %s\033[0m\n" "$*"; }
ok()   { printf "  \033[32m✓\033[0m %s\n" "$*"; }

step "Hornet installer"

# 1. Clone (or update) the monorepo so shared/*.sh and shared/scripts/*.py are
#    available locally. Plugins themselves are served via the marketplace
#    command below — the clone is just for supporting scripts.
if [[ -d "$HORNET_DIR/.git" ]]; then
  git -C "$HORNET_DIR" pull --ff-only --quiet
  ok "Updated existing clone at $HORNET_DIR"
else
  git clone --depth 1 --quiet "$REPO" "$HORNET_DIR"
  ok "Cloned to $HORNET_DIR"
fi

# 2. Ensure hook scripts are executable (fresh clones on some filesystems lose +x).
chmod +x "$HORNET_DIR"/plugins/*/hooks/*/*.sh 2>/dev/null || true
chmod +x "$HORNET_DIR"/shared/*.sh 2>/dev/null || true
chmod +x "$HORNET_DIR"/shared/scripts/*.py 2>/dev/null || true
ok "Hook scripts marked executable"

cat <<'EOF'

─────────────────────────────────────────────────────────────────────────
  Hornet is a bundle. The 4 plugins feed each other at runtime —
  change-tracker emits the semantic diffs that trust-scorer rates with
  a Bayesian prior, decision-gate reviews changes in information-gain
  order using those scores, and session-memory preserves the decision
  graph across compactions. Installing only one breaks the pipeline,
  so every plugin.json lists the other three as dependencies and
  Claude Code pulls them in together.
─────────────────────────────────────────────────────────────────────────

  Finish in Claude Code with TWO commands:

    /plugin marketplace add enchanted-plugins/hornet
    /plugin install hornet-change-tracker@hornet

  The second command installs all 4 plugins via dependency resolution.
  (Any of the 4 names works — they're peers. change-tracker is the
  natural entry point because every other plugin reads its output.)

  Verify with:   /plugin list
  Expected:      4 plugins installed under the hornet marketplace.

EOF

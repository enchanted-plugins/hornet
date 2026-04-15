#!/usr/bin/env bash
set -euo pipefail

HORNET_DIR="${HOME}/.claude/plugins/hornet"

if [[ -d "$HORNET_DIR" ]]; then
  echo "Hornet already installed at $HORNET_DIR"
  echo "To update: cd $HORNET_DIR && git pull"
  exit 0
fi

echo "Installing Hornet..."
git clone https://github.com/enchanted-plugins/hornet "$HORNET_DIR"
chmod +x "$HORNET_DIR"/plugins/*/hooks/*/*.sh
chmod +x "$HORNET_DIR"/shared/*.sh
chmod +x "$HORNET_DIR"/shared/scripts/*.py

echo ""
echo "Done. Run in Claude Code:"
echo ""
echo "  /plugin add $HORNET_DIR/plugins/change-tracker"
echo "  /plugin add $HORNET_DIR/plugins/trust-scorer"
echo "  /plugin add $HORNET_DIR/plugins/decision-gate"
echo "  /plugin add $HORNET_DIR/plugins/session-memory"
echo ""
echo "Or add the marketplace:"
echo "  /plugin marketplace add $HORNET_DIR"
echo ""
echo "Start with change-tracker + trust-scorer — they're the foundation."

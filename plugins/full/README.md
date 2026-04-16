# full

**Meta-plugin. Installs every Hornet plugin at once.**

This plugin has no hooks, skills, or agents of its own. It exists so you can install the whole 4-plugin pipeline with one command:

```
/plugin marketplace add enchanted-plugins/hornet
/plugin install full@hornet
```

Claude Code resolves the four dependencies and installs:

- `hornet-change-tracker` — semantic diff compression + classification
- `hornet-decision-gate` — information-gain review + adversarial questions
- `hornet-session-memory` — continuity graph, compaction survival
- `hornet-trust-scorer` — Bayesian posterior per file change

If you want to cherry-pick a single plugin (e.g. just `hornet-trust-scorer`), you can — but the plugins feed each other at runtime (change-tracker → trust-scorer → decision-gate → session-memory), so you'll typically want them all.

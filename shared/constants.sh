#!/usr/bin/env bash
# Vigil shared constants — sourced by all hooks and utilities

VIGIL_VERSION="1.0.0"

# State file names
VIGIL_CHANGES_FILE="state/changes.jsonl"
VIGIL_TRUST_FILE="state/trust.json"
VIGIL_METRICS_FILE="state/metrics.jsonl"
VIGIL_SESSION_GRAPH="state/session-graph.json"
VIGIL_SESSION_SUMMARY="state/session-summary.md"
VIGIL_LEARNINGS_FILE="state/learnings.json"

# Size limits
VIGIL_MAX_CHANGES_BYTES=10485760       # 10MB
VIGIL_MAX_METRICS_BYTES=10485760       # 10MB (rotate at 10MB)
VIGIL_MAX_GRAPH_BYTES=51200            # 50KB (compaction survival)

# Trust thresholds
VIGIL_TRUST_HIGH="0.8"
VIGIL_TRUST_LOW="0.4"
VIGIL_TRUST_CRITICAL="0.2"

# Bayesian priors — Beta(2,2) uniform-ish prior
VIGIL_PRIOR_ALPHA=2
VIGIL_PRIOR_BETA=2

# Trust likelihoods by change type
VIGIL_LIKELIHOOD_DOCUMENTATION="0.95"
VIGIL_LIKELIHOOD_TEST="0.85"
VIGIL_LIKELIHOOD_SOURCE_SMALL="0.7"
VIGIL_LIKELIHOOD_SOURCE_LARGE="0.5"
VIGIL_LIKELIHOOD_SCHEMA="0.55"
VIGIL_LIKELIHOOD_DEPENDENCY="0.5"
VIGIL_LIKELIHOOD_CONFIG_SENSITIVE="0.3"
VIGIL_LIKELIHOOD_CONFIG_NORMAL="0.5"

# EMA learning rate (Gauss Accumulation)
VIGIL_GAUSS_ALPHA="0.3"

# Review cooldown
VIGIL_REVIEW_COOLDOWN_TURNS=3

# Lock config
VIGIL_LOCK_SUFFIX=".lock"

# Session cache prefix
VIGIL_CACHE_PREFIX="/tmp/vigil-"

# Information-gain entropy lookup table (trust → binary entropy)
# Precomputed: H(p) = -p*log2(p) - (1-p)*log2(1-p)
# Used by gate-change.sh since bash cannot compute log2
VIGIL_IG_TABLE_05="0.29"
VIGIL_IG_TABLE_10="0.47"
VIGIL_IG_TABLE_15="0.61"
VIGIL_IG_TABLE_20="0.72"
VIGIL_IG_TABLE_25="0.81"
VIGIL_IG_TABLE_30="0.88"
VIGIL_IG_TABLE_35="0.93"
VIGIL_IG_TABLE_40="0.97"
VIGIL_IG_TABLE_45="0.99"
VIGIL_IG_TABLE_50="1.00"
VIGIL_IG_TABLE_55="0.99"
VIGIL_IG_TABLE_60="0.97"
VIGIL_IG_TABLE_65="0.93"
VIGIL_IG_TABLE_70="0.88"
VIGIL_IG_TABLE_75="0.81"
VIGIL_IG_TABLE_80="0.72"
VIGIL_IG_TABLE_85="0.61"
VIGIL_IG_TABLE_90="0.47"
VIGIL_IG_TABLE_95="0.29"

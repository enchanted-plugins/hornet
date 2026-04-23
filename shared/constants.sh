#!/usr/bin/env bash
# Crow shared constants — sourced by all hooks and utilities

CROW_VERSION="1.0.0"

# State file names
CROW_CHANGES_FILE="state/changes.jsonl"
CROW_TRUST_FILE="state/trust.json"
CROW_METRICS_FILE="state/metrics.jsonl"
CROW_SESSION_GRAPH="state/session-graph.json"
CROW_SESSION_SUMMARY="state/session-summary.md"
CROW_LEARNINGS_FILE="state/learnings.json"

# Size limits
CROW_MAX_CHANGES_BYTES=10485760       # 10MB
CROW_MAX_METRICS_BYTES=10485760       # 10MB (rotate at 10MB)
CROW_MAX_GRAPH_BYTES=51200            # 50KB (compaction survival)

# Trust thresholds
CROW_TRUST_HIGH="0.8"
CROW_TRUST_LOW="0.4"
CROW_TRUST_CRITICAL="0.2"

# Bayesian priors — Beta(2,2) uniform-ish prior
CROW_PRIOR_ALPHA=2
CROW_PRIOR_BETA=2

# Trust likelihoods by change type
CROW_LIKELIHOOD_DOCUMENTATION="0.95"
CROW_LIKELIHOOD_TEST="0.85"
CROW_LIKELIHOOD_SOURCE_SMALL="0.7"
CROW_LIKELIHOOD_SOURCE_LARGE="0.5"
CROW_LIKELIHOOD_SCHEMA="0.55"
CROW_LIKELIHOOD_DEPENDENCY="0.5"
CROW_LIKELIHOOD_CONFIG_SENSITIVE="0.3"
CROW_LIKELIHOOD_CONFIG_NORMAL="0.5"

# EMA learning rate (Gauss Accumulation)
CROW_GAUSS_ALPHA="0.3"

# Review cooldown
CROW_REVIEW_COOLDOWN_TURNS=3

# Lock config
CROW_LOCK_SUFFIX=".lock"

# Session cache prefix
CROW_CACHE_PREFIX="/tmp/crow-"

# Information-gain entropy lookup table (trust → binary entropy)
# Precomputed: H(p) = -p*log2(p) - (1-p)*log2(1-p)
# Used by gate-change.sh since bash cannot compute log2
CROW_IG_TABLE_05="0.29"
CROW_IG_TABLE_10="0.47"
CROW_IG_TABLE_15="0.61"
CROW_IG_TABLE_20="0.72"
CROW_IG_TABLE_25="0.81"
CROW_IG_TABLE_30="0.88"
CROW_IG_TABLE_35="0.93"
CROW_IG_TABLE_40="0.97"
CROW_IG_TABLE_45="0.99"
CROW_IG_TABLE_50="1.00"
CROW_IG_TABLE_55="0.99"
CROW_IG_TABLE_60="0.97"
CROW_IG_TABLE_65="0.93"
CROW_IG_TABLE_70="0.88"
CROW_IG_TABLE_75="0.81"
CROW_IG_TABLE_80="0.72"
CROW_IG_TABLE_85="0.61"
CROW_IG_TABLE_90="0.47"
CROW_IG_TABLE_95="0.29"

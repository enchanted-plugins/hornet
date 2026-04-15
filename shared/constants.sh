#!/usr/bin/env bash
# Hornet shared constants — sourced by all hooks and utilities

HORNET_VERSION="1.0.0"

# State file names
HORNET_CHANGES_FILE="state/changes.jsonl"
HORNET_TRUST_FILE="state/trust.json"
HORNET_METRICS_FILE="state/metrics.jsonl"
HORNET_SESSION_GRAPH="state/session-graph.json"
HORNET_SESSION_SUMMARY="state/session-summary.md"
HORNET_LEARNINGS_FILE="state/learnings.json"

# Size limits
HORNET_MAX_CHANGES_BYTES=10485760       # 10MB
HORNET_MAX_METRICS_BYTES=10485760       # 10MB (rotate at 10MB)
HORNET_MAX_GRAPH_BYTES=51200            # 50KB (compaction survival)

# Trust thresholds
HORNET_TRUST_HIGH="0.8"
HORNET_TRUST_LOW="0.4"
HORNET_TRUST_CRITICAL="0.2"

# Bayesian priors — Beta(2,2) uniform-ish prior
HORNET_PRIOR_ALPHA=2
HORNET_PRIOR_BETA=2

# Trust likelihoods by change type
HORNET_LIKELIHOOD_DOCUMENTATION="0.95"
HORNET_LIKELIHOOD_TEST="0.85"
HORNET_LIKELIHOOD_SOURCE_SMALL="0.7"
HORNET_LIKELIHOOD_SOURCE_LARGE="0.5"
HORNET_LIKELIHOOD_SCHEMA="0.55"
HORNET_LIKELIHOOD_DEPENDENCY="0.5"
HORNET_LIKELIHOOD_CONFIG_SENSITIVE="0.3"
HORNET_LIKELIHOOD_CONFIG_NORMAL="0.5"

# EMA learning rate (Gauss Accumulation)
HORNET_GAUSS_ALPHA="0.3"

# Review cooldown
HORNET_REVIEW_COOLDOWN_TURNS=3

# Lock config
HORNET_LOCK_SUFFIX=".lock"

# Session cache prefix
HORNET_CACHE_PREFIX="/tmp/hornet-"

# Information-gain entropy lookup table (trust → binary entropy)
# Precomputed: H(p) = -p*log2(p) - (1-p)*log2(1-p)
# Used by gate-change.sh since bash cannot compute log2
HORNET_IG_TABLE_05="0.29"
HORNET_IG_TABLE_10="0.47"
HORNET_IG_TABLE_15="0.61"
HORNET_IG_TABLE_20="0.72"
HORNET_IG_TABLE_25="0.81"
HORNET_IG_TABLE_30="0.88"
HORNET_IG_TABLE_35="0.93"
HORNET_IG_TABLE_40="0.97"
HORNET_IG_TABLE_45="0.99"
HORNET_IG_TABLE_50="1.00"
HORNET_IG_TABLE_55="0.99"
HORNET_IG_TABLE_60="0.97"
HORNET_IG_TABLE_65="0.93"
HORNET_IG_TABLE_70="0.88"
HORNET_IG_TABLE_75="0.81"
HORNET_IG_TABLE_80="0.72"
HORNET_IG_TABLE_85="0.61"
HORNET_IG_TABLE_90="0.47"
HORNET_IG_TABLE_95="0.29"

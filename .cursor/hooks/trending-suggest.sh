#!/bin/bash

# Cursor Agent Hook: Trending Repository Suggestions
# Suggests relevant trending repositories based on current project context
# This hook can be triggered by Cursor agents when working on specific topics

set -euo pipefail

# Get the project directory (current directory or passed as argument)
PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_CLI_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TRENDING_SCRIPT="$GH_CLI_DIR/scripts/gh-trending-discovery.sh"

# Check if trending script exists
if [ ! -f "$TRENDING_SCRIPT" ]; then
    echo "Trending discovery script not found at: $TRENDING_SCRIPT"
    exit 0
fi

# Detect project topics based on files and dependencies
TOPICS=""

# Check for AI/ML indicators
if [ -f "requirements.txt" ] && grep -qiE "(torch|tensorflow|transformers|langchain|openai)" requirements.txt 2>/dev/null; then
    TOPICS="${TOPICS}ai,llm,machine-learning,"
fi

# Check for frontend frameworks
if [ -f "package.json" ]; then
    if grep -qiE "(react|vue|angular|next)" package.json 2>/dev/null; then
        TOPICS="${TOPICS}frontend,web-development,"
    fi
    if grep -qiE "(typescript)" package.json 2>/dev/null; then
        TOPICS="${TOPICS}typescript,"
    fi
fi

# Check for specific technologies
if [ -f "firebase.json" ] || [ -f ".firebaserc" ]; then
    TOPICS="${TOPICS}firebase,"
fi

if [ -f "docker-compose.yml" ] || [ -f "Dockerfile" ]; then
    TOPICS="${TOPICS}docker,devops,"
fi

# Default topics if none detected
if [ -z "$TOPICS" ]; then
    TOPICS="ai,llm,programming"
fi

# Remove trailing comma
TOPICS="${TOPICS%,}"

echo "Suggesting trending repositories for topics: $TOPICS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run trending discovery with detected topics
"$TRENDING_SCRIPT" \
    --topics "$TOPICS" \
    --min-stars 100 \
    --days 30 \
    --limit 10 \
    --format table 2>/dev/null || true

echo ""
echo "💡 Tip: Use 'gh-trend-ai' or './scripts/gh-trending-discovery.sh' for more results"

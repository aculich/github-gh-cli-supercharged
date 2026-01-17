#!/bin/bash

# GitHub Trending Repository Discovery Script
# Searches for trending repos by topic, filters by recent updates and stars

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
TOPICS="${TOPICS:-ai,llm,machine-learning,artificial-intelligence}"
MIN_STARS="${MIN_STARS:-100}"
DAYS_SINCE_UPDATE="${DAYS_SINCE_UPDATE:-30}"
LIMIT="${LIMIT:-50}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-table}"

# Calculate date filter
if [[ "$OSTYPE" == "darwin"* ]]; then
    DATE_FILTER=$(date -v-${DAYS_SINCE_UPDATE}d +%Y-%m-%d)
else
    DATE_FILTER=$(date -d "${DAYS_SINCE_UPDATE} days ago" +%Y-%m-%d)
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --topics)
            TOPICS="$2"
            shift 2
            ;;
        --min-stars)
            MIN_STARS="$2"
            shift 2
            ;;
        --days)
            DAYS_SINCE_UPDATE="$2"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                DATE_FILTER=$(date -v-${DAYS_SINCE_UPDATE}d +%Y-%m-%d)
            else
                DATE_FILTER=$(date -d "${DAYS_SINCE_UPDATE} days ago" +%Y-%m-%d)
            fi
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        --help)
            cat <<EOF
Usage: $0 [OPTIONS]

Search for trending GitHub repositories by topic.

OPTIONS:
    --topics TOPICS          Comma-separated topics (default: ai,llm,machine-learning)
    --min-stars STARS        Minimum star count (default: 100)
    --days DAYS              Days since last update (default: 30)
    --limit LIMIT            Maximum results (default: 50)
    --format FORMAT          Output format: table, json, markdown (default: table)
    --help                   Show this help message

ENVIRONMENT VARIABLES:
    TOPICS                   Comma-separated topics
    MIN_STARS                Minimum star count
    DAYS_SINCE_UPDATE         Days since last update
    LIMIT                    Maximum results
    OUTPUT_FORMAT            Output format

EXAMPLES:
    $0 --topics "ai,llm" --min-stars 500 --days 7
    $0 --format json > trending.json
    TOPICS="python,data-science" $0
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check dependencies
if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI is not installed"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed (required for JSON parsing)"
    exit 1
fi

# Build search query
QUERY="topic:$(echo "$TOPICS" | tr ',' ' OR topic:')"
QUERY="$QUERY stars:>=$MIN_STARS"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}GitHub Trending Repository Discovery${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Topics:${NC} $TOPICS"
echo -e "${GREEN}Minimum Stars:${NC} $MIN_STARS"
echo -e "${GREEN}Updated Since:${NC} $DATE_FILTER (last $DAYS_SINCE_UPDATE days)"
echo -e "${GREEN}Limit:${NC} $LIMIT"
echo ""
echo "Searching..."

# Perform search
# Note: topics field is not available in gh search repos, so we exclude it
# Include all important metadata: createdAt, pushedAt, forksCount, etc.
RESULTS=$(NO_COLOR=1 gh search repos "$QUERY" \
    --updated ">=$DATE_FILTER" \
    --sort updated \
    --order desc \
    --limit "$LIMIT" \
    --json fullName,description,stargazersCount,updatedAt,createdAt,pushedAt,url,language,forksCount,openIssuesCount,isArchived,isPrivate,visibility,homepage,license,owner,watchersCount,size,defaultBranch)

if [ -z "$RESULTS" ] || [ "$RESULTS" = "[]" ]; then
    echo -e "${YELLOW}No repositories found matching the criteria.${NC}"
    exit 0
fi

# Filter by pushedAt date: must be >= Jan 1 of previous year
# If today is Jan 17 2026, previous year is 2025, so filter >= 2025-01-01
CURRENT_YEAR=$(date +%Y)
PREVIOUS_YEAR=$((CURRENT_YEAR - 1))
YEAR_START="${PREVIOUS_YEAR}-01-01T00:00:00Z"

echo -e "${GREEN}Filtering repositories pushed after:${NC} $YEAR_START"
RESULTS=$(echo "$RESULTS" | jq --arg cutoff "$YEAR_START" '[.[] | select(.pushedAt >= $cutoff)]')

FILTERED_COUNT=$(echo "$RESULTS" | jq 'length')
if [ "$FILTERED_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}No repositories found that were pushed after $YEAR_START.${NC}"
    exit 0
fi

echo -e "${GREEN}Repositories after date filter:${NC} $FILTERED_COUNT"
echo ""

# Format output based on format type
case "$OUTPUT_FORMAT" in
    json)
        echo "$RESULTS" | jq '.'
        ;;
    markdown)
        echo "# Trending Repositories"
        echo ""
        echo "| Repository | Stars | Created | Updated | Pushed | Language | Forks | Issues | Description |"
        echo "|------------|-------|---------|---------|--------|----------|-------|--------|-------------|"
        echo "$RESULTS" | jq -r '.[] | 
            "| [\(.fullName)](\(.url)) | \(.stargazersCount) | \(.createdAt) | \(.updatedAt) | \(.pushedAt) | \(.language // "N/A") | \(.forksCount) | \(.openIssuesCount) | \(.description // "No description" | gsub("\n"; " ") | .[0:60]) |"'
        ;;
    table|*)
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}Results:${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        echo "$RESULTS" | jq -r '.[] | 
            "\(.fullName)\n  ⭐ Stars: \(.stargazersCount)\n  📅 Created: \(.createdAt)\n  📅 Updated: \(.updatedAt)\n  📅 Pushed: \(.pushedAt)\n  💻 Language: \(.language // "N/A")\n  🍴 Forks: \(.forksCount)\n  📝 Issues: \(.openIssuesCount)\n  📝 \(.description // "No description")\n  🔗 \(.url)\n"'
        
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Summary:${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        TOTAL=$(echo "$RESULTS" | jq 'length')
        TOTAL_STARS=$(echo "$RESULTS" | jq '[.[] | .stargazersCount] | add')
        AVG_STARS=$(echo "$RESULTS" | jq '[.[] | .stargazersCount] | add / length | floor')
        
        echo "Total repositories: $TOTAL"
        echo "Total stars: $TOTAL_STARS"
        echo "Average stars: $AVG_STARS"
        ;;
esac

# Auto-save to trending/ directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TRENDING_DIR="$PROJECT_ROOT/trending"
mkdir -p "$TRENDING_DIR"

# Generate timestamp and search term for filename
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SEARCH_TERM=$(echo "$TOPICS" | tr ',' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | cut -c1-50)
JSONL_FILE="$TRENDING_DIR/trending-${SEARCH_TERM}-${TIMESTAMP}.jsonl"
MD_FILE="$TRENDING_DIR/trending-${SEARCH_TERM}-${TIMESTAMP}.md"

# Save JSONL format (one JSON object per line)
echo "$RESULTS" | jq -c '.[]' > "$JSONL_FILE"
echo -e "${GREEN}JSONL saved to:${NC} $JSONL_FILE"

# Save Markdown format
{
    echo "# Trending Repositories: $TOPICS"
    echo ""
    echo "Generated: $(date)"
    echo "Search Query: $QUERY"
    echo "Filter: Pushed after $YEAR_START"
    echo ""
    echo "## Summary"
    echo ""
    TOTAL=$(echo "$RESULTS" | jq 'length')
    TOTAL_STARS=$(echo "$RESULTS" | jq '[.[] | .stargazersCount] | add')
    AVG_STARS=$(echo "$RESULTS" | jq '[.[] | .stargazersCount] | add / length | floor')
    echo "- Total repositories: $TOTAL"
    echo "- Total stars: $TOTAL_STARS"
    echo "- Average stars: $AVG_STARS"
    echo ""
    echo "## Repositories"
    echo ""
    echo "| Repository | Stars | Created | Updated | Pushed | Language | Forks | Issues | Description |"
    echo "|------------|-------|---------|---------|--------|----------|-------|--------|-------------|"
    echo "$RESULTS" | jq -r '.[] | 
        "| [\(.fullName)](\(.url)) | \(.stargazersCount) | \(.createdAt) | \(.updatedAt) | \(.pushedAt) | \(.language // "N/A") | \(.forksCount) | \(.openIssuesCount) | \(.description // "No description" | gsub("\n"; " ") | .[0:80]) |"'
} > "$MD_FILE"
echo -e "${GREEN}Markdown saved to:${NC} $MD_FILE"
echo ""

# Also save to file if explicitly requested via SAVE_TO_FILE
if [ -n "${SAVE_TO_FILE:-}" ]; then
    case "$OUTPUT_FORMAT" in
        json)
            echo "$RESULTS" | jq '.' > "$SAVE_TO_FILE"
            echo -e "${GREEN}Also saved to:${NC} $SAVE_TO_FILE"
            ;;
        markdown)
            cp "$MD_FILE" "$SAVE_TO_FILE"
            echo -e "${GREEN}Also saved to:${NC} $SAVE_TO_FILE"
            ;;
    esac
fi

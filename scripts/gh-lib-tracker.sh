#!/bin/bash

# GitHub Library Update Tracker
# Tracks specific libraries/projects for recent releases and updates

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Default config file
CONFIG_FILE="${GH_CLI_CONFIG_DIR:-$HOME/.config/gh-cli}/tracked-libraries.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_CONFIG="$SCRIPT_DIR/../config/tracked-libraries.json"

# Use default config if custom one doesn't exist
if [ ! -f "$CONFIG_FILE" ] && [ -f "$DEFAULT_CONFIG" ]; then
    CONFIG_FILE="$DEFAULT_CONFIG"
fi

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Config file not found at: $CONFIG_FILE${NC}"
    echo "Create a config file or set GH_CLI_CONFIG_DIR environment variable"
    exit 1
fi

# Check dependencies
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: gh CLI is not installed${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed (required for JSON parsing)${NC}"
    exit 1
fi

# Parse command line arguments
CATEGORY_FILTER=""
SHOW_ALL=false
DAYS_THRESHOLD=30

while [[ $# -gt 0 ]]; do
    case $1 in
        --category)
            CATEGORY_FILTER="$2"
            shift 2
            ;;
        --all)
            SHOW_ALL=true
            shift
            ;;
        --days)
            DAYS_THRESHOLD="$2"
            shift 2
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --help)
            cat <<EOF
Usage: $0 [OPTIONS]

Track updates for libraries defined in config file.

OPTIONS:
    --category CATEGORY      Filter by category (e.g., ai-ml, frontend)
    --all                    Show all libraries, even without recent updates
    --days DAYS              Days threshold for "recent" updates (default: 30)
    --config FILE            Path to config file
    --help                   Show this help message

CONFIG FILE FORMAT:
{
  "libraries": [
    {
      "name": "library-name",
      "owner": "owner-name",
      "type": "repo",
      "description": "Description",
      "category": "category-name"
    }
  ]
}

EXAMPLES:
    $0 --category ai-ml
    $0 --all --days 7
    $0 --config ~/my-libs.json
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

# Calculate date threshold
if [[ "$OSTYPE" == "darwin"* ]]; then
    DATE_THRESHOLD=$(date -v-${DAYS_THRESHOLD}d +%Y-%m-%dT%H:%M:%SZ)
else
    DATE_THRESHOLD=$(date -d "${DAYS_THRESHOLD} days ago" -u +%Y-%m-%dT%H:%M:%SZ)
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}GitHub Library Update Tracker${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Config file:${NC} $CONFIG_FILE"
echo -e "${GREEN}Checking for updates in last:${NC} $DAYS_THRESHOLD days"
if [ -n "$CATEGORY_FILTER" ]; then
    echo -e "${GREEN}Category filter:${NC} $CATEGORY_FILTER"
fi
echo ""

# Get libraries from config
if [ -n "$CATEGORY_FILTER" ]; then
    LIBRARIES=$(jq -r --arg cat "$CATEGORY_FILTER" '.libraries[] | select(.category == $cat)' "$CONFIG_FILE")
else
    LIBRARIES=$(jq -r '.libraries[]' "$CONFIG_FILE")
fi

if [ -z "$LIBRARIES" ]; then
    echo -e "${YELLOW}No libraries found matching the criteria.${NC}"
    exit 0
fi

# Count libraries
LIB_COUNT=$(echo "$LIBRARIES" | jq -s 'length')
echo "Tracking $LIB_COUNT libraries..."
echo ""

UPDATED_COUNT=0
NO_UPDATE_COUNT=0
ERROR_COUNT=0

# Process each library
echo "$LIBRARIES" | jq -s '.' | jq -r '.[] | "\(.name)|\(.owner)|\(.type)|\(.description // "No description")|\(.category // "uncategorized")"' | while IFS='|' read -r name owner type description category; do
    repo="$owner/$name"
    
    echo -e "${BLUE}Checking:${NC} $repo"
    
    # Get latest release
    RELEASE_DATA=$(gh api "repos/$repo/releases/latest" 2>/dev/null || echo "")
    
    if [ -z "$RELEASE_DATA" ]; then
        # Try to get latest tag instead
        TAG_DATA=$(gh api "repos/$repo/tags" --jq '.[0]' 2>/dev/null || echo "")
        
        if [ -z "$TAG_DATA" ] || [ "$TAG_DATA" = "null" ]; then
            # Check last commit date
            COMMIT_DATA=$(gh api "repos/$repo/commits" --jq '.[0]' 2>/dev/null || echo "")
            
            if [ -z "$COMMIT_DATA" ] || [ "$COMMIT_DATA" = "null" ]; then
                echo -e "  ${RED}✗${NC} Could not fetch data"
                ((ERROR_COUNT++))
                echo ""
                continue
            else
                COMMIT_DATE=$(echo "$COMMIT_DATA" | jq -r '.commit.author.date')
                COMMIT_MSG=$(echo "$COMMIT_DATA" | jq -r '.commit.message' | head -n 1)
                
                if [[ "$COMMIT_DATE" > "$DATE_THRESHOLD" ]]; then
                    echo -e "  ${GREEN}✓${NC} Recent commit: $COMMIT_DATE"
                    echo -e "     Message: $COMMIT_MSG"
                    echo -e "     ${BLUE}URL:${NC} https://github.com/$repo/commit/$(echo "$COMMIT_DATA" | jq -r '.sha')"
                    ((UPDATED_COUNT++))
                else
                    if [ "$SHOW_ALL" = true ]; then
                        echo -e "  ${YELLOW}○${NC} Last commit: $COMMIT_DATE (older than threshold)"
                    fi
                    ((NO_UPDATE_COUNT++))
                fi
            fi
        else
            TAG_NAME=$(echo "$TAG_DATA" | jq -r '.name')
            TAG_DATE=$(gh api "repos/$repo/git/refs/tags/$TAG_NAME" --jq '.object.sha' 2>/dev/null | xargs -I {} gh api "repos/$repo/commits/{}" --jq '.commit.author.date' 2>/dev/null || echo "")
            
            if [ -n "$TAG_DATE" ] && [[ "$TAG_DATE" > "$DATE_THRESHOLD" ]]; then
                echo -e "  ${GREEN}✓${NC} Recent tag: $TAG_NAME ($TAG_DATE)"
                echo -e "     ${BLUE}URL:${NC} https://github.com/$repo/releases/tag/$TAG_NAME"
                ((UPDATED_COUNT++))
            else
                if [ "$SHOW_ALL" = true ]; then
                    echo -e "  ${YELLOW}○${NC} Latest tag: $TAG_NAME (older than threshold)"
                fi
                ((NO_UPDATE_COUNT++))
            fi
        fi
    else
        RELEASE_NAME=$(echo "$RELEASE_DATA" | jq -r '.name // .tag_name')
        RELEASE_DATE=$(echo "$RELEASE_DATA" | jq -r '.published_at')
        RELEASE_URL=$(echo "$RELEASE_DATA" | jq -r '.html_url')
        RELEASE_BODY=$(echo "$RELEASE_DATA" | jq -r '.body' | head -n 3)
        
        if [[ "$RELEASE_DATE" > "$DATE_THRESHOLD" ]]; then
            echo -e "  ${GREEN}✓${NC} Recent release: $RELEASE_NAME"
            echo -e "     Published: $RELEASE_DATE"
            echo -e "     ${BLUE}URL:${NC} $RELEASE_URL"
            if [ -n "$RELEASE_BODY" ] && [ "$RELEASE_BODY" != "null" ]; then
                echo -e "     Notes: $(echo "$RELEASE_BODY" | tr '\n' ' ' | cut -c1-100)..."
            fi
            ((UPDATED_COUNT++))
        else
            if [ "$SHOW_ALL" = true ]; then
                echo -e "  ${YELLOW}○${NC} Latest release: $RELEASE_NAME ($RELEASE_DATE)"
            fi
            ((NO_UPDATE_COUNT++))
        fi
    fi
    
    echo ""
done

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "${GREEN}  Libraries with recent updates:${NC} $UPDATED_COUNT"
echo -e "${YELLOW}  Libraries without recent updates:${NC} $NO_UPDATE_COUNT"
if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${RED}  Errors:${NC} $ERROR_COUNT"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

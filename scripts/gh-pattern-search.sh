#!/bin/bash

# GitHub Code Pattern Search Script
# Searches for code patterns across repositories

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
PATTERN=""
LANGUAGE=""
OWNER=""
LIMIT=50
OUTPUT_FORMAT="table"
USE_FZF=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--pattern)
            PATTERN="$2"
            shift 2
            ;;
        -l|--language)
            LANGUAGE="$2"
            shift 2
            ;;
        -o|--owner)
            OWNER="$2"
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
        --fzf)
            USE_FZF=true
            shift
            ;;
        --help)
            cat <<EOF
Usage: $0 [OPTIONS] [PATTERN]

Search for code patterns across GitHub repositories.

OPTIONS:
    -p, --pattern PATTERN    Code pattern to search for (required)
    -l, --language LANG     Filter by programming language
    -o, --owner OWNER        Filter by repository owner/organization
    --limit LIMIT            Maximum results (default: 50)
    --format FORMAT          Output format: table, json, markdown (default: table)
    --fzf                    Use fzf for interactive selection
    --help                   Show this help message

EXAMPLES:
    $0 --pattern "async def" --language python
    $0 --pattern "useState" --language typescript --owner facebook
    $0 --pattern "error handling" --fzf
    $0 -p "class.*extends" -l javascript --limit 20

PATTERN EXAMPLES:
    "async def"              - Python async functions
    "useState"               - React useState hook
    "error handling"         - Error handling patterns
    "class.*extends"         - Class inheritance (regex)
    "try.*catch"             - Try-catch blocks
EOF
            exit 0
            ;;
        *)
            if [ -z "$PATTERN" ]; then
                PATTERN="$1"
            else
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate pattern
if [ -z "$PATTERN" ]; then
    echo -e "${YELLOW}Error: Pattern is required${NC}"
    echo "Use --help for usage information"
    exit 1
fi

# Check dependencies
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}Error: gh CLI is not installed${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Error: jq is not installed (required for JSON parsing)${NC}"
    exit 1
fi

if [ "$USE_FZF" = true ] && ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}Warning: fzf not found, falling back to table format${NC}"
    USE_FZF=false
fi

# Build search query
QUERY="$PATTERN"

if [ -n "$LANGUAGE" ]; then
    QUERY="$QUERY language:$LANGUAGE"
fi

if [ -n "$OWNER" ]; then
    QUERY="$QUERY user:$OWNER"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}GitHub Code Pattern Search${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Pattern:${NC} $PATTERN"
if [ -n "$LANGUAGE" ]; then
    echo -e "${GREEN}Language:${NC} $LANGUAGE"
fi
if [ -n "$OWNER" ]; then
    echo -e "${GREEN}Owner:${NC} $OWNER"
fi
echo -e "${GREEN}Limit:${NC} $LIMIT"
echo ""
echo "Searching..."

# Perform search
RESULTS=$(gh search code "$QUERY" \
    --limit "$LIMIT" \
    --json repository,name,path,textMatches,htmlUrl 2>/dev/null)

if [ -z "$RESULTS" ] || [ "$RESULTS" = "[]" ]; then
    echo -e "${YELLOW}No code matches found.${NC}"
    exit 0
fi

RESULT_COUNT=$(echo "$RESULTS" | jq 'length')
echo "Found $RESULT_COUNT matches"
echo ""

# Format output based on format type
if [ "$USE_FZF" = true ]; then
    # Interactive fzf selection
    SELECTED=$(echo "$RESULTS" | jq -r '.[] | "\(.repository.fullName)|\(.path)|\(.htmlUrl)|\(.textMatches[0].fragment // "No preview" | gsub("\n"; "\\n"))"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2 \
            --preview='echo -e "Repository: {1}\nFile: {2}\nURL: {3}\n\nCode Preview:\n{4}"' \
            --preview-window=right:70% \
            --header="Select a match (Enter to open, Ctrl-C to cancel)" \
        | cut -d'|' -f3)
    
    if [ -n "$SELECTED" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "$SELECTED"
        else
            xdg-open "$SELECTED" 2>/dev/null || echo "$SELECTED"
        fi
    fi
else
    case "$OUTPUT_FORMAT" in
        json)
            echo "$RESULTS" | jq '.'
            ;;
        markdown)
            echo "# Code Pattern Search Results"
            echo ""
            echo "Pattern: \`$PATTERN\`"
            echo ""
            echo "| Repository | File | URL |"
            echo "|------------|------|-----|"
            echo "$RESULTS" | jq -r '.[] | 
                "| \(.repository.fullName) | \(.path) | [View](\(.htmlUrl)) |"'
            ;;
        table|*)
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${GREEN}Results:${NC}"
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            
            echo "$RESULTS" | jq -r '.[] | 
                "\(.repository.fullName)/\(.path)\n  🔗 \(.htmlUrl)\n  📝 \(.textMatches[0].fragment // "No preview" | gsub("\n"; " ") | .[0:200])\n"'
            
            echo ""
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}Summary:${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            
            UNIQUE_REPOS=$(echo "$RESULTS" | jq -r '.[].repository.fullName' | sort -u | wc -l | tr -d ' ')
            echo "Total matches: $RESULT_COUNT"
            echo "Unique repositories: $UNIQUE_REPOS"
            ;;
    esac
fi

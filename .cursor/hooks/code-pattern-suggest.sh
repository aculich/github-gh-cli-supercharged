#!/bin/bash

# Cursor Agent Hook: Code Pattern Suggestions
# Suggests code patterns and examples based on current file context
# This hook can be triggered by Cursor agents when working on specific code patterns

set -euo pipefail

# Get file path (from argument or current file)
FILE_PATH="${1:-}"

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    echo "Usage: $0 <file_path>"
    echo "This hook suggests code patterns based on the current file"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_CLI_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PATTERN_SCRIPT="$GH_CLI_DIR/scripts/gh-pattern-search.sh"

# Detect file language
LANGUAGE=""
case "$FILE_PATH" in
    *.py)
        LANGUAGE="python"
        ;;
    *.js|*.jsx|*.ts|*.tsx)
        LANGUAGE="javascript"
        if [[ "$FILE_PATH" == *.ts* ]]; then
            LANGUAGE="typescript"
        fi
        ;;
    *.java)
        LANGUAGE="java"
        ;;
    *.go)
        LANGUAGE="go"
        ;;
    *.rs)
        LANGUAGE="rust"
        ;;
    *.rb)
        LANGUAGE="ruby"
        ;;
    *)
        # Try to detect from shebang
        FIRST_LINE=$(head -n 1 "$FILE_PATH" 2>/dev/null || echo "")
        if [[ "$FIRST_LINE" == *python* ]]; then
            LANGUAGE="python"
        elif [[ "$FIRST_LINE" == *node* ]]; then
            LANGUAGE="javascript"
        fi
        ;;
esac

# Extract common patterns from file
PATTERNS=()

# Check for async/await patterns
if grep -qE "(async|await)" "$FILE_PATH" 2>/dev/null; then
    if [ "$LANGUAGE" = "python" ]; then
        PATTERNS+=("async def")
    elif [ "$LANGUAGE" = "javascript" ] || [ "$LANGUAGE" = "typescript" ]; then
        PATTERNS+=("async.*await")
    fi
fi

# Check for error handling
if grep -qE "(try|catch|except|error)" "$FILE_PATH" 2>/dev/null; then
    if [ "$LANGUAGE" = "python" ]; then
        PATTERNS+=("try.*except")
    elif [ "$LANGUAGE" = "javascript" ] || [ "$LANGUAGE" = "typescript" ]; then
        PATTERNS+=("try.*catch")
    fi
fi

# Check for React hooks
if grep -qE "(useState|useEffect|useCallback)" "$FILE_PATH" 2>/dev/null; then
    PATTERNS+=("useState")
fi

# If no patterns detected, suggest common patterns for the language
if [ ${#PATTERNS[@]} -eq 0 ]; then
    case "$LANGUAGE" in
        python)
            PATTERNS=("async def" "class.*def" "decorator")
            ;;
        javascript|typescript)
            PATTERNS=("function" "arrow function" "class.*extends")
            ;;
        *)
            PATTERNS=("function" "class")
            ;;
    esac
fi

echo "Suggesting code patterns for: $FILE_PATH"
echo "Language: ${LANGUAGE:-unknown}"
echo "Detected patterns: ${PATTERNS[*]}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Search for each pattern
for pattern in "${PATTERNS[@]}"; do
    echo "Searching for: $pattern"
    "$PATTERN_SCRIPT" \
        --pattern "$pattern" \
        --language "$LANGUAGE" \
        --limit 5 \
        --format table 2>/dev/null | head -20 || true
    echo ""
done

echo "💡 Tip: Use 'gh-code-pattern' or './scripts/gh-pattern-search.sh' for more searches"

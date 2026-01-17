#!/bin/bash

# Cursor Agent Hook: Library Update Check
# Automatically checks for library updates when opening projects
# This hook can be triggered by Cursor agents or run manually

set -euo pipefail

# Get the project directory (current directory or passed as argument)
PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR"

# Check if this is a git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "Not a git repository, skipping library update check"
    exit 0
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_CLI_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_TRACKER="$GH_CLI_DIR/scripts/gh-lib-tracker.sh"

# Check if library tracker exists
if [ ! -f "$LIB_TRACKER" ]; then
    echo "Library tracker script not found at: $LIB_TRACKER"
    exit 0
fi

# Detect project type and relevant categories
PROJECT_TYPE=""
if [ -f "package.json" ]; then
    PROJECT_TYPE="frontend"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    PROJECT_TYPE="ai-ml"
elif [ -f "Cargo.toml" ]; then
    PROJECT_TYPE="tools"
fi

# Run library tracker with relevant category
if [ -n "$PROJECT_TYPE" ]; then
    echo "Checking for updates in $PROJECT_TYPE libraries..."
    "$LIB_TRACKER" --category "$PROJECT_TYPE" --days 7 2>/dev/null || true
else
    echo "Checking for updates in tracked libraries..."
    "$LIB_TRACKER" --days 7 2>/dev/null || true
fi

# Also check for updates in dependencies if package.json exists
if [ -f "package.json" ]; then
    echo ""
    echo "Checking npm dependencies for updates..."
    if command -v npm &> /dev/null; then
        npm outdated 2>/dev/null | head -10 || true
    fi
fi

# Check for Python package updates if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo ""
    echo "Note: Check Python package updates with: pip list --outdated"
fi

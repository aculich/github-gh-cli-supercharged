#!/bin/bash
# Get workspace root directory
# Tries to find the workspace root by looking for .cursor or .git directories
# Falls back to current directory if not found

# Start from current directory
START_DIR="${1:-$(pwd)}"
CURRENT_DIR="$START_DIR"

# Try to find workspace root by looking for .cursor or .git
while [ "$CURRENT_DIR" != "/" ]; do
    # Check for .cursor directory (Cursor workspace indicator)
    if [ -d "$CURRENT_DIR/.cursor" ]; then
        echo "$CURRENT_DIR"
        exit 0
    fi
    
    # Check for .git directory (git repository root)
    if [ -d "$CURRENT_DIR/.git" ]; then
        echo "$CURRENT_DIR"
        exit 0
    fi
    
    # Move up one directory
    CURRENT_DIR="$(dirname "$CURRENT_DIR")"
done

# Fallback to current directory
echo "$START_DIR"

#!/usr/bin/env bash
# Install Cursor slash commands globally
# This script symlinks the commands from this repo to ~/.cursor/commands/

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/.cursor/commands"
GLOBAL_COMMANDS_DIR="$HOME/.cursor/commands"

echo -e "${BLUE}Installing Cursor slash commands globally...${NC}"
echo ""

# Check if commands directory exists
if [[ ! -d "$COMMANDS_DIR" ]]; then
    echo -e "${YELLOW}⚠️  Commands directory not found: $COMMANDS_DIR${NC}"
    exit 1
fi

# Create global commands directory if it doesn't exist
mkdir -p "$GLOBAL_COMMANDS_DIR"
echo -e "${GREEN}✓${NC} Global commands directory: $GLOBAL_COMMANDS_DIR"

# Count existing commands
EXISTING_COUNT=$(find "$GLOBAL_COMMANDS_DIR" -name "gh-*.md" 2>/dev/null | wc -l | tr -d ' ')

# Install each command
INSTALLED=0
SKIPPED=0

for cmd_file in "$COMMANDS_DIR"/gh-*.md; do
    if [[ -f "$cmd_file" ]]; then
        cmd_name=$(basename "$cmd_file")
        global_cmd="$GLOBAL_COMMANDS_DIR/$cmd_name"
        
        # Check if already exists
        if [[ -f "$global_cmd" ]] || [[ -L "$global_cmd" ]]; then
            # Check if it's already a symlink to our file
            if [[ -L "$global_cmd" ]] && [[ "$(readlink "$global_cmd")" == "$cmd_file" ]]; then
                echo -e "  ${BLUE}→${NC} $cmd_name (already linked)"
                SKIPPED=$((SKIPPED + 1))
            else
                # Backup existing file
                backup_name="${cmd_name}.backup.$(date +%s)"
                mv "$global_cmd" "$GLOBAL_COMMANDS_DIR/$backup_name"
                echo -e "  ${YELLOW}⚠${NC}  Backed up existing $cmd_name to $backup_name"
                ln -sf "$cmd_file" "$global_cmd"
                echo -e "  ${GREEN}✓${NC} Installed $cmd_name"
                INSTALLED=$((INSTALLED + 1))
            fi
        else
            # Create symlink
            ln -sf "$cmd_file" "$global_cmd"
            echo -e "  ${GREEN}✓${NC} Installed $cmd_name"
            INSTALLED=$((INSTALLED + 1))
        fi
    fi
done

echo ""
echo -e "${GREEN}✓${NC} Installation complete!"
echo ""
echo "Installed: $INSTALLED commands"
if [[ $SKIPPED -gt 0 ]]; then
    echo "Skipped (already linked): $SKIPPED commands"
fi
if [[ $EXISTING_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}Note:${NC} Found $EXISTING_COUNT existing gh-* commands (may have been backed up)"
fi

echo ""
echo -e "${BLUE}Available commands:${NC}"
echo "  /gh-trending-ai    - Find trending AI/LLM repositories"
echo "  /gh-find-tool      - Search for specific tools or libraries"
echo "  /gh-lib-updates    - Check for updates in tracked libraries"
echo "  /gh-code-pattern   - Search for code patterns"
echo "  /gh-find-snippet   - Find code snippets"
echo "  /gh-grep-repos     - Grep across repositories"
echo "  /gh-pr-review      - Review PRs with AI assistance"
echo "  /gh-issue-sync     - Sync and manage issues"
echo "  /gh-notify         - View GitHub notifications"
echo "  /gh-clone-trending - Clone trending repositories"

echo ""
echo -e "${YELLOW}Note:${NC} You may need to restart Cursor for commands to appear."
echo "Commands are now available globally in all Cursor workspaces!"

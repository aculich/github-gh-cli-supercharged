#!/bin/bash

# Oh My Zsh Plugin Installation Script
# Installs github-gh-cli-supercharged as an Oh My Zsh plugin

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="github-gh-cli-supercharged"

# Default Oh My Zsh location
OH_MY_ZSH="${OH_MY_ZSH:-$HOME/.oh-my-zsh}"
PLUGINS_DIR="$OH_MY_ZSH/custom/plugins"
PLUGIN_DIR="$PLUGINS_DIR/$PLUGIN_NAME"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}GitHub CLI Supercharged - Oh My Zsh Plugin Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if Oh My Zsh is installed
if [[ ! -d "$OH_MY_ZSH" ]]; then
    echo -e "${RED}Error: Oh My Zsh is not installed${NC}"
    echo ""
    echo "Please install Oh My Zsh first:"
    echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    exit 1
fi

echo -e "${GREEN}✓${NC} Oh My Zsh found at: $OH_MY_ZSH"
echo ""

# Create plugins directory if it doesn't exist
mkdir -p "$PLUGINS_DIR"

# Check if plugin already exists
if [[ -d "$PLUGIN_DIR" ]]; then
    echo -e "${YELLOW}⚠️  Plugin directory already exists: $PLUGIN_DIR${NC}"
    read -p "Do you want to update it? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo "Updating plugin..."
else
    echo "Creating plugin directory..."
    mkdir -p "$PLUGIN_DIR"
fi

# Copy files to plugin directory
echo ""
echo "Installing plugin files..."

# Copy main plugin file
if [[ -f "$SCRIPT_DIR/oh-my-zsh-plugin/github-gh-cli-supercharged.plugin.zsh" ]]; then
    cp "$SCRIPT_DIR/oh-my-zsh-plugin/github-gh-cli-supercharged.plugin.zsh" "$PLUGIN_DIR/"
    echo -e "${GREEN}✓${NC} Installed plugin file"
else
    echo -e "${RED}✗${NC} Plugin file not found"
    exit 1
fi

# Copy configuration files
FILES_TO_COPY=(
    "gh-config.zsh"
    "gh-functions.zsh"
    "install-extensions.sh"
    "scripts"
    "config"
)

for file in "${FILES_TO_COPY[@]}"; do
    if [[ -e "$SCRIPT_DIR/$file" ]]; then
        if [[ -d "$SCRIPT_DIR/$file" ]]; then
            cp -r "$SCRIPT_DIR/$file" "$PLUGIN_DIR/"
            echo -e "${GREEN}✓${NC} Installed $file/"
        else
            cp "$SCRIPT_DIR/$file" "$PLUGIN_DIR/"
            echo -e "${GREEN}✓${NC} Installed $file"
        fi
    fi
done

# Make scripts executable
chmod +x "$PLUGIN_DIR/install-extensions.sh" 2>/dev/null
find "$PLUGIN_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if plugin is already in .zshrc
if grep -q "plugins=.*$PLUGIN_NAME" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Plugin is already enabled in your .zshrc"
else
    echo -e "${YELLOW}⚠️  Plugin needs to be enabled in your .zshrc${NC}"
    echo ""
    echo "Add '${PLUGIN_NAME}' to your plugins array in ~/.zshrc:"
    echo ""
    echo -e "${BLUE}plugins=(${PLUGIN_NAME} ...)${NC}"
    echo ""
    echo "Or run this command to add it automatically:"
    echo ""
    echo -e "${BLUE}sed -i '' 's/^plugins=(/plugins=(${PLUGIN_NAME} /' ~/.zshrc${NC}"
    echo ""
    read -p "Do you want to add it automatically now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Try to add to plugins array
        if grep -q "^plugins=(" "$HOME/.zshrc" 2>/dev/null; then
            # Add to existing plugins array
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/^plugins=(/plugins=(${PLUGIN_NAME} /" "$HOME/.zshrc"
            else
                sed -i "s/^plugins=(/plugins=(${PLUGIN_NAME} /" "$HOME/.zshrc"
            fi
            echo -e "${GREEN}✓${NC} Added plugin to .zshrc"
            echo ""
            echo "Reload your shell with: ${BLUE}source ~/.zshrc${NC}"
        else
            echo -e "${YELLOW}⚠️  Could not find plugins array in .zshrc${NC}"
            echo "Please add it manually:"
            echo "  plugins=(${PLUGIN_NAME})"
        fi
    fi
fi

echo ""
echo "Next steps:"
echo "  1. Install extensions: ${BLUE}./install-extensions.sh${NC} (from plugin directory)"
echo "  2. Reload shell: ${BLUE}source ~/.zshrc${NC}"
echo "  3. Test: ${BLUE}gh-help${NC} or ${BLUE}gh-trend-ai${NC}"
echo ""
echo "Plugin location: $PLUGIN_DIR"

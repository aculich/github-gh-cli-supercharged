#!/bin/bash

# GitHub CLI Extension Installation Script
# Installs curated extensions for AI/LLM discovery, code search, and productivity

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Extension lists organized by category
AI_LLM_EXTENSIONS=(
    "github/gh-models"
    "github/gh-copilot"
    "githubnext/gh-aw"
)

CODE_SEARCH_EXTENSIONS=(
    "k1LoW/gh-grep"
    "LangLangBart/gh-find-code"
    "gennaro-tedesco/gh-s"
    "gennaro-tedesco/gh-f"
)

REPO_MANAGEMENT_EXTENSIONS=(
    "dlvhdr/gh-dash"
    "2KAbhishek/gh-repo-man"
    "samcoe/gh-repo-explore"
    "jrnxf/gh-eco"
)

PRODUCTIVITY_EXTENSIONS=(
    "mislav/gh-branch"
    "meiji163/gh-notify"
    "gennaro-tedesco/gh-i"
    "agynio/gh-pr-review"
    "sgoedecke/gh-standup"
)

ADDITIONAL_EXTENSIONS=(
    "kawarimidoll/gh-q"
    "kavinvalli/gh-repo-fzf"
    "benelan/gh-fzf"
    "kyhyco/gh-fh"
)

# Combine all extensions
ALL_EXTENSIONS=(
    "${AI_LLM_EXTENSIONS[@]}"
    "${CODE_SEARCH_EXTENSIONS[@]}"
    "${REPO_MANAGEMENT_EXTENSIONS[@]}"
    "${PRODUCTIVITY_EXTENSIONS[@]}"
    "${ADDITIONAL_EXTENSIONS[@]}"
)

# Statistics
INSTALLED=0
SKIPPED=0
FAILED=0
FAILED_EXTENSIONS=()

# Function to check if extension is already installed
is_installed() {
    local ext="$1"
    gh ext list 2>/dev/null | grep -q "$ext" || return 1
}

# Function to install a single extension
install_extension() {
    local ext="$1"
    local category="$2"
    
    echo -e "${BLUE}[${category}]${NC} Installing ${ext}..."
    
    if is_installed "$ext"; then
        echo -e "${YELLOW}  ⚠️  Already installed, skipping${NC}"
        ((SKIPPED++))
        return 0
    fi
    
    if gh ext install "$ext" 2>&1; then
        echo -e "${GREEN}  ✓  Successfully installed${NC}"
        ((INSTALLED++))
        return 0
    else
        echo -e "${RED}  ✗  Failed to install${NC}"
        ((FAILED++))
        FAILED_EXTENSIONS+=("$ext")
        return 1
    fi
}

# Main installation function
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}GitHub CLI Extension Installer${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Check if gh is installed
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: gh CLI is not installed${NC}"
        echo "Please install it first: https://cli.github.com/"
        exit 1
    fi
    
    # Check if gh is authenticated
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}Warning: gh is not authenticated${NC}"
        echo "Some extensions may require authentication."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo -e "${BLUE}Installing ${#ALL_EXTENSIONS[@]} extensions...${NC}"
    echo ""
    
    # Install AI/LLM extensions
    echo -e "${GREEN}━━━ AI/LLM & Model Management ━━━${NC}"
    for ext in "${AI_LLM_EXTENSIONS[@]}"; do
        install_extension "$ext" "AI/LLM"
    done
    echo ""
    
    # Install Code Search extensions
    echo -e "${GREEN}━━━ Code Search & Pattern Discovery ━━━${NC}"
    for ext in "${CODE_SEARCH_EXTENSIONS[@]}"; do
        install_extension "$ext" "Code Search"
    done
    echo ""
    
    # Install Repo Management extensions
    echo -e "${GREEN}━━━ Repository Management & Discovery ━━━${NC}"
    for ext in "${REPO_MANAGEMENT_EXTENSIONS[@]}"; do
        install_extension "$ext" "Repo Mgmt"
    done
    echo ""
    
    # Install Productivity extensions
    echo -e "${GREEN}━━━ Productivity & Workflow ━━━${NC}"
    for ext in "${PRODUCTIVITY_EXTENSIONS[@]}"; do
        install_extension "$ext" "Productivity"
    done
    echo ""
    
    # Install Additional extensions
    echo -e "${GREEN}━━━ Additional High-Value Extensions ━━━${NC}"
    for ext in "${ADDITIONAL_EXTENSIONS[@]}"; do
        install_extension "$ext" "Additional"
    done
    echo ""
    
    # Summary
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Installation Summary${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Installed:${NC} $INSTALLED"
    echo -e "${YELLOW}⚠ Skipped:${NC} $SKIPPED"
    echo -e "${RED}✗ Failed:${NC} $FAILED"
    
    if [ $FAILED -gt 0 ]; then
        echo ""
        echo -e "${RED}Failed extensions:${NC}"
        for ext in "${FAILED_EXTENSIONS[@]}"; do
            echo -e "  ${RED}✗${NC} $ext"
        done
        echo ""
        echo "You can try installing them manually:"
        for ext in "${FAILED_EXTENSIONS[@]}"; do
            echo "  gh ext install $ext"
        done
    fi
    
    echo ""
    echo -e "${GREEN}Done!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Source gh-functions.zsh in your .zshrc"
    echo "  2. Run 'gh ext list' to verify installations"
    echo "  3. Try 'gh dash' or 'gh f' to test extensions"
}

# Run main function
main "$@"

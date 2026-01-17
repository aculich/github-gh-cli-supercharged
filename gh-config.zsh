#!/usr/bin/env zsh
# GitHub CLI Configuration
# Source this file in your .zshrc:
#   source /path/to/github-gh-cli/gh-config.zsh
#
# Or use the install snippet in install-snippet.zshrc

# Get the directory where this script is located
# Handle both direct sourcing and symlinked files
if [[ -n "${ZSH_ARGZERO:-}" ]]; then
    # zsh-specific way
    GH_CLI_DIR="${${(%):-%x}:A:h}"
elif [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    # bash fallback
    GH_CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # Last resort - try to find from $0
    GH_CLI_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Guard: Check if directory exists and is valid
if [[ ! -d "$GH_CLI_DIR" ]]; then
    # Silently fail - don't echo during shell startup
    return 0 2>/dev/null || exit 0
fi

# Guard: Check if functions file exists before sourcing
if [[ ! -f "$GH_CLI_DIR/gh-functions.zsh" ]]; then
    # Silently fail - don't echo during shell startup
    return 0 2>/dev/null || exit 0
fi

# Export config directory for use in functions
export GH_CLI_CONFIG_DIR="${GH_CLI_CONFIG_DIR:-$HOME/.config/gh-cli}"

# Create config directory if it doesn't exist (silently)
mkdir -p "$GH_CLI_CONFIG_DIR" 2>/dev/null || true

# Source the functions file (with guard)
if [[ -f "$GH_CLI_DIR/gh-functions.zsh" ]]; then
    source "$GH_CLI_DIR/gh-functions.zsh"
fi

# ============================================================================
# fzf Configuration for GitHub CLI
# ============================================================================

# Configure fzf preview windows for gh commands
export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --preview-window=right:60%
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
    --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
"

# fzf key bindings for gh workflows
# Use Ctrl-G to trigger GitHub-related searches
if command -v fzf &> /dev/null 2>&1; then
    # Bind Ctrl-G + R for repo search (silently)
    bindkey -s '^Gr' 'gh-repo-fzf\n' 2>/dev/null &>/dev/null || true
    
    # Bind Ctrl-G + I for issue search (silently)
    bindkey -s '^Gi' 'gh-issue-fzf\n' 2>/dev/null &>/dev/null || true
    
    # Bind Ctrl-G + P for PR search (silently)
    bindkey -s '^Gp' 'gh-pr-fzf\n' 2>/dev/null &>/dev/null || true
    
    # Bind Ctrl-G + N for notifications (silently)
    bindkey -s '^Gn' 'gh-notify-fzf\n' 2>/dev/null &>/dev/null || true
    
    # Bind Ctrl-G + S for starred repos (silently)
    bindkey -s '^Gs' 'gh-star-fzf\n' 2>/dev/null &>/dev/null || true
    
    # Bind Ctrl-G + T for trending AI (silently)
    bindkey -s '^Gt' 'gh-trend-ai\n' 2>/dev/null &>/dev/null || true
fi

# ============================================================================
# Aliases
# ============================================================================

# Extension management
alias ghe='gh ext'
alias ghel='gh ext list'
alias ghes='gh ext search'
alias ghei='gh ext install'
alias gheu='gh ext upgrade'
alias gheua='gh ext upgrade --all'

# Quick GitHub operations
alias ghv='gh repo view --web'
alias gho='gh-open'
alias ghs='gh search'

# Repository operations
alias ghr='gh repo'
alias ghrl='gh repo list'
alias ghrc='gh repo clone'
alias ghrv='gh repo view'

# Pull requests
alias ghpr='gh pr'
alias ghprl='gh pr list'
alias ghprc='gh pr create'
alias ghprv='gh pr view'
alias ghprf='gh-pr-fzf'

# Issues
alias ghi='gh issue'
alias ghil='gh issue list'
alias ghic='gh issue create'
alias ghiv='gh issue view'
alias ghif='gh-issue-fzf'

# Code search
alias ghcs='gh search code'
alias ghcp='gh-code-pattern'
alias ghss='gh-snippet-search'

# Trending and discovery
alias ghta='gh-trend-ai'
alias ghtl='gh-trend-libs'
alias ghfa='gh-find-ai-tools'
alias ghlu='gh-lib-updates'

# Notifications
alias ghn='gh notify'
alias ghnf='gh-notify-fzf'

# Stars
alias ghsf='gh-star-fzf'

# Branch management (using gh-branch extension if available)
alias ghb='gh-branch-fzf'

# ============================================================================
# Environment Variables
# ============================================================================

# Set default GitHub CLI behavior
export GH_PAGER=""
export GH_FORCE_TTY=1

# Customize gh output format
export GH_NO_UPDATE_NOTIFIER=1  # Disable update notifications if desired

# ============================================================================
# Completion
# ============================================================================

# Enable gh completion if available (completely silent)
if command -v gh &> /dev/null 2>&1; then
    # Try to source gh completion
    local brew_prefix
    brew_prefix=$(brew --prefix 2>/dev/null) || brew_prefix=""
    if [[ -n "$brew_prefix" ]] && [[ -f "$brew_prefix/share/zsh/site-functions/_gh" ]] 2>/dev/null; then
        # Homebrew location - silently use it
        :
    elif [[ -f "/usr/share/zsh/site-functions/_gh" ]] 2>/dev/null; then
        # System location - silently use it
        :
    else
        # Generate completion if not found (silently, only if file doesn't exist)
        if [[ ! -f "$GH_CLI_CONFIG_DIR/_gh" ]]; then
            gh completion --shell zsh > "$GH_CLI_CONFIG_DIR/_gh" 2>/dev/null || true
        fi
        if [[ -f "$GH_CLI_CONFIG_DIR/_gh" ]]; then
            fpath=("$GH_CLI_CONFIG_DIR" $fpath) 2>/dev/null || true
        fi
    fi
fi

# ============================================================================
# Utility Functions
# ============================================================================

# Quick function to reload gh config
gh-reload() {
    if [[ -f "$GH_CLI_DIR/gh-config.zsh" ]]; then
        source "$GH_CLI_DIR/gh-config.zsh"
        echo "GitHub CLI configuration reloaded"
    else
        echo "Error: gh-config.zsh not found"
        return 1
    fi
}

# Show installed extensions
gh-extensions() {
    if command -v gh &> /dev/null; then
        echo "Installed GitHub CLI Extensions:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        gh ext list
    else
        echo "Error: gh CLI not found"
        return 1
    fi
}

# Quick help for gh functions
gh-help() {
    cat <<EOF
GitHub CLI Functions & Aliases
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Trending & Discovery:
  ghta, gh-trend-ai          - Search trending AI/LLM repos
  ghtl, gh-trend-libs       - Track updates for libraries
  ghfa, gh-find-ai-tools    - Discover emerging AI tools
  ghlu, gh-lib-updates      - Check updates in tracked libraries

Code Search:
  ghcp, gh-code-pattern     - Search code patterns across repos
  ghss, gh-snippet-search   - Find code snippets
  gh-grep-fzf              - Enhanced grep with fzf

Repository Management:
  gh-repo-fzf              - Fuzzy search and clone repos
  gh-branch-fzf            - Enhanced branch switching
  ghprf, gh-pr-fzf         - Interactive PR management

Quick Access:
  ghnf, gh-notify-fzf      - View notifications
  ghif, gh-issue-fzf       - Search issues interactively
  ghsf, gh-star-fzf        - Browse starred repos
  gho, gh-open             - Open repo in browser

Aliases:
  ghe                      - gh ext (extension commands)
  ghr                      - gh repo
  ghpr                     - gh pr
  ghi                      - gh issue
  ghcs                     - gh search code

Key Bindings:
  Ctrl-G + R              - Search repos
  Ctrl-G + I              - Search issues
  Ctrl-G + P              - Search PRs
  Ctrl-G + N              - View notifications
  Ctrl-G + S              - Browse stars
  Ctrl-G + T              - Trending AI repos

For more information, see: $GH_CLI_DIR/README.md
EOF
}

# ============================================================================
# Initialization
# ============================================================================

# Check if gh is authenticated (silently - don't echo during startup)
if command -v gh &> /dev/null; then
    # Silently check - functions will handle auth errors at runtime
    :
fi

# Display welcome message (only once per session)
if [[ -z "${GH_CLI_INITIALIZED:-}" ]]; then
    export GH_CLI_INITIALIZED=1
    # Silently initialize - no output during shell startup
    :
fi

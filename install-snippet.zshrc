# ============================================================================
# GitHub CLI Supercharged Configuration
# ============================================================================
# Add this snippet to your ~/.zshrc to enable GitHub CLI enhancements
#
# To ENABLE: Uncomment the lines below
# To DISABLE: Comment out the lines below (add # at the start)
#
# You can also set GH_CLI_ENABLED=0 in your .zshrc to disable without editing
# ============================================================================

# Set this to 0 to disable, or leave unset/1 to enable
# export GH_CLI_ENABLED=0

if [[ "${GH_CLI_ENABLED:-1}" == "1" ]]; then
    # Path to your github-gh-cli directory
    # Update this path to match your installation location
    local gh_cli_path="$HOME/tools/github-gh-cli"
    
    # Alternative common locations (uncomment if needed):
    # local gh_cli_path="$HOME/.local/share/github-gh-cli"
    # local gh_cli_path="/opt/github-gh-cli"
    # local gh_cli_path="$(dirname $(readlink -f ~/.zshrc))/../tools/github-gh-cli"
    
    # Guard: Only source if directory and config file exist
    if [[ -d "$gh_cli_path" ]] && [[ -f "$gh_cli_path/gh-config.zsh" ]]; then
        source "$gh_cli_path/gh-config.zsh"
    fi
    # If directory doesn't exist, silently skip (no errors)
fi

# ============================================================================
# End of GitHub CLI Configuration
# ============================================================================

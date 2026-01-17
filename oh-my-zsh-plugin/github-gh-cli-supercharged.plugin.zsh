# GitHub CLI Supercharged - Oh My Zsh Plugin
# This plugin supercharges your GitHub CLI with extensions, functions, and integrations

# Get the directory where this plugin is located
PLUGIN_DIR="${0:A:h}"

# Guard: Check if plugin directory exists
if [[ ! -d "$PLUGIN_DIR" ]]; then
    return 0 2>/dev/null || exit 0
fi

# Source the main configuration
# The plugin directory should contain the gh-config.zsh file
if [[ -f "$PLUGIN_DIR/gh-config.zsh" ]]; then
    source "$PLUGIN_DIR/gh-config.zsh"
elif [[ -f "$PLUGIN_DIR/../gh-config.zsh" ]]; then
    # Fallback: if plugin is in a subdirectory
    source "$PLUGIN_DIR/../gh-config.zsh"
fi

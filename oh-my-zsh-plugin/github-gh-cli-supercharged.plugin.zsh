# GitHub CLI Supercharged - Oh My Zsh Plugin
# This plugin supercharges your GitHub CLI with extensions, functions, and integrations

# Get the directory where this plugin is located
PLUGIN_DIR="${0:A:h}"

# Guard: Check if plugin directory exists
if [[ ! -d "$PLUGIN_DIR" ]]; then
    return 0 2>/dev/null || exit 0
fi

# Source the main configuration
# The plugin directory should contain the gh-config.zsh file (installed by install-oh-my-zsh.sh)
if [[ -f "$PLUGIN_DIR/gh-config.zsh" ]]; then
    # Standard installation: config file is in plugin directory
    source "$PLUGIN_DIR/gh-config.zsh"
elif [[ -f "$PLUGIN_DIR/../gh-config.zsh" ]]; then
    # Development/testing: config file is in parent directory
    source "$PLUGIN_DIR/../gh-config.zsh"
else
    # Silently fail if config not found
    return 0 2>/dev/null || exit 0
fi

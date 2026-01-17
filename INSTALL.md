# Installation Guide

## Quick Install

### Option 1: Add to .zshrc (Recommended)

1. **Copy the installation snippet:**

   ```bash
   cat install-snippet.zshrc >> ~/.zshrc
   ```

2. **Edit the path in your `.zshrc`:**

   Open `~/.zshrc` and find the line:
   ```zsh
   local gh_cli_path="$HOME/tools/github-gh-cli"
   ```
   
   Update it to match your actual installation path.

3. **Reload your shell:**

   ```bash
   source ~/.zshrc
   ```

### Option 2: Manual Installation

Add this to your `~/.zshrc`:

```zsh
# GitHub CLI Supercharged
if [[ -d "$HOME/tools/github-gh-cli" ]] && [[ -f "$HOME/tools/github-gh-cli/gh-config.zsh" ]]; then
    source "$HOME/tools/github-gh-cli/gh-config.zsh"
fi
```

**Update the path** to match where you installed this directory.

## Enable/Disable

### Method 1: Environment Variable

Add to your `~/.zshrc`:

```zsh
export GH_CLI_ENABLED=0  # Disable
# or
export GH_CLI_ENABLED=1  # Enable (default)
```

### Method 2: Comment Out

In your `~/.zshrc`, comment out the source line:

```zsh
# source "$HOME/tools/github-gh-cli/gh-config.zsh"
```

## Uninstall

Simply remove or comment out the installation snippet from your `~/.zshrc`:

```zsh
# GitHub CLI Supercharged
# if [[ -d "$HOME/tools/github-gh-cli" ]] && [[ -f "$HOME/tools/github-gh-cli/gh-config.zsh" ]]; then
#     source "$HOME/tools/github-gh-cli/gh-config.zsh"
# fi
```

Or set:

```zsh
export GH_CLI_ENABLED=0
```

## Verification

After installation, verify it's working:

```bash
# Check if functions are loaded
type gh-trend-ai

# View help
gh-help

# Test a function
gh-trend-ai 10
```

## Troubleshooting

### Functions not found

1. **Check the path is correct:**
   ```bash
   ls -la ~/tools/github-gh-cli/gh-config.zsh
   ```

2. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

3. **Check if it's enabled:**
   ```bash
   echo $GH_CLI_ENABLED
   ```

### No errors but functions don't work

The configuration is designed to fail silently if files don't exist. Check:

1. The directory exists
2. The `gh-config.zsh` file exists
3. The `gh-functions.zsh` file exists
4. You have `gh` CLI installed

### Shell startup is slow

The configuration is designed to be fast. If startup is slow:

1. Check if `gh` CLI is installed (it checks for it)
2. Make sure the path is correct (no failed file checks)
3. The config should load in < 100ms

## Custom Paths

If you installed this in a non-standard location, update the path in your `.zshrc`:

```zsh
local gh_cli_path="/your/custom/path/github-gh-cli"
```

The configuration will automatically:
- Check if the directory exists
- Check if the config file exists
- Fail silently if either is missing
- Load without errors if everything is present

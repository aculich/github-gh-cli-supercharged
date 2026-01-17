# Oh My Zsh Plugin Installation

This guide shows you how to install GitHub CLI Supercharged as an Oh My Zsh plugin.

## Prerequisites

- [Oh My Zsh](https://ohmyz.sh/) installed
- [GitHub CLI](https://cli.github.com/) (`gh`) installed
- [fzf](https://github.com/junegunn/fzf) (optional but recommended)
- [jq](https://stedolan.github.io/jq/) (required for scripts)

## Installation Methods

### Method 1: Automatic Installation (Recommended)

1. **Clone the repository:**

   ```bash
   git clone https://github.com/aculich/github-gh-cli-supercharged.git
   cd github-gh-cli-supercharged
   ```

2. **Run the installer:**

   ```bash
   ./install-oh-my-zsh.sh
   ```

   The installer will:
   - Copy files to `~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged/`
   - Optionally add the plugin to your `.zshrc`

3. **Enable the plugin:**

   If not added automatically, add to your `~/.zshrc`:

   ```zsh
   plugins=(
     github-gh-cli-supercharged
     # ... other plugins
   )
   ```

4. **Reload your shell:**

   ```bash
   source ~/.zshrc
   ```

### Method 2: Manual Installation

1. **Clone to Oh My Zsh plugins directory:**

   ```bash
   git clone https://github.com/aculich/github-gh-cli-supercharged.git \
     ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged
   ```

2. **Enable the plugin in `~/.zshrc`:**

   ```zsh
   plugins=(
     github-gh-cli-supercharged
     # ... other plugins
   )
   ```

3. **Reload your shell:**

   ```bash
   source ~/.zshrc
   ```

### Method 3: Using Oh My Zsh Custom Plugins

If you prefer to keep the plugin in a separate location:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/aculich/github-gh-cli-supercharged.git \
     ~/tools/github-gh-cli-supercharged
   ```

2. **Create a symlink:**

   ```bash
   ln -s ~/tools/github-gh-cli-supercharged \
     ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged
   ```

3. **Enable in `.zshrc`:**

   ```zsh
   plugins=(github-gh-cli-supercharged)
   ```

4. **Reload:**

   ```bash
   source ~/.zshrc
   ```

## Post-Installation

### Install Extensions

After installation, install the GitHub CLI extensions:

```bash
cd ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged
./install-extensions.sh
```

### Verify Installation

Test that everything works:

```bash
# Check if functions are loaded
type gh-trend-ai

# View help
gh-help

# Test a function
gh-trend-ai 10
```

## Updating the Plugin

### If Installed via Git Clone

```bash
cd ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged
git pull origin main
source ~/.zshrc
```

### If Installed via Installer

Re-run the installer:

```bash
cd /path/to/github-gh-cli-supercharged
./install-oh-my-zsh.sh
```

## Uninstalling

### Remove from .zshrc

1. **Edit `~/.zshrc`** and remove `github-gh-cli-supercharged` from the plugins array:

   ```zsh
   plugins=(
     # github-gh-cli-supercharged  # Commented out or removed
     # ... other plugins
   )
   ```

2. **Remove the plugin directory:**

   ```bash
   rm -rf ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged
   ```

3. **Reload shell:**

   ```bash
   source ~/.zshrc
   ```

## Troubleshooting

### Plugin Not Loading

1. **Check plugin is enabled:**

   ```bash
   grep "plugins=" ~/.zshrc | grep github-gh-cli-supercharged
   ```

2. **Check plugin directory exists:**

   ```bash
   ls -la ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged
   ```

3. **Check plugin file exists:**

   ```bash
   ls -la ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged/*.plugin.zsh
   ```

### Functions Not Found

1. **Reload shell:**

   ```bash
   source ~/.zshrc
   ```

2. **Check if gh-config.zsh exists:**

   ```bash
   ls -la ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged/gh-config.zsh
   ```

3. **Manually source to test:**

   ```bash
   source ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged/github-gh-cli-supercharged.plugin.zsh
   ```

### Oh My Zsh Not Found

If you get an error about Oh My Zsh not being found:

1. **Check Oh My Zsh installation:**

   ```bash
   ls -la ~/.oh-my-zsh
   ```

2. **Install Oh My Zsh if missing:**

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

## Benefits of Oh My Zsh Plugin

- **Easy enable/disable**: Just add/remove from plugins array
- **Automatic loading**: Oh My Zsh handles sourcing
- **Standard location**: Follows Oh My Zsh conventions
- **Easy updates**: Update via git pull
- **Clean .zshrc**: No need to manually source files

## Alternative: Direct Installation

If you prefer not to use Oh My Zsh, see [INSTALL.md](INSTALL.md) for direct installation instructions.

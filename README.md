# GitHub CLI Supercharged

A comprehensive setup to supercharge your GitHub CLI (`gh`) experience with extensions, zsh functions, fzf integration, and Cursor IDE automation.

## Features

- 🚀 **20+ Curated Extensions** - AI/LLM tools, code search, productivity extensions
- 🔍 **Interactive Functions** - Fuzzy search for repos, PRs, issues, and code patterns
- 📊 **Trending Discovery** - Automatically find trending AI/LLM tools and repositories
- 🔄 **Library Tracking** - Monitor updates for libraries you use
- 💻 **Cursor Integration** - Slash commands and agent hooks for IDE automation
- 🎯 **Code Pattern Search** - Find code snippets and patterns across GitHub

## Quick Start

### Installation Options

Choose one of the following installation methods:

#### Option 1: Oh My Zsh Plugin (Recommended)

If you use [Oh My Zsh](https://ohmyz.sh/), install as a plugin:

```bash
# Clone the repository
git clone https://github.com/aculich/github-gh-cli-supercharged.git
cd github-gh-cli-supercharged

# Run the installer
./install-oh-my-zsh.sh

# Add to your .zshrc plugins array (if not done automatically)
# plugins=(github-gh-cli-supercharged ...)

# Reload shell
source ~/.zshrc
```

See [INSTALL-oh-my-zsh.md](INSTALL-oh-my-zsh.md) for detailed instructions.

#### Option 2: Direct Installation

For non-Oh My Zsh users or custom setups:

```bash
# Copy the snippet to your .zshrc
cat install-snippet.zshrc >> ~/.zshrc

# Edit the path in ~/.zshrc to match your installation location
# Then reload:
source ~/.zshrc
```

See [INSTALL.md](INSTALL.md) for detailed instructions.

### Install Extensions

After installation, install the curated extensions:

```bash
./install-extensions.sh
```

This will install extensions for:
- AI/LLM & Model Management
- Code Search & Pattern Discovery
- Repository Management & Discovery
- Productivity & Workflow

### Verify Installation

```bash
# Check installed extensions
gh ext list

# Test a function
gh-trend-ai 20

# View help
gh-help
```

## Installation Methods

This project supports multiple installation methods:

1. **[Oh My Zsh Plugin](INSTALL-oh-my-zsh.md)** - Recommended for Oh My Zsh users
2. **[Direct Installation](INSTALL.md)** - For custom zsh setups
3. **Manual Setup** - Full control over configuration

Choose the method that best fits your setup!

## Installation

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- [fzf](https://github.com/junegunn/fzf) for interactive selection
- [jq](https://stedolan.github.io/jq/) for JSON parsing
- zsh shell

### Step-by-Step Installation

1. **Clone or navigate to this directory**

2. **Install extensions:**
   ```bash
   ./install-extensions.sh
   ```

3. **Add to your `.zshrc`:**
   
   **Quick method:**
   ```bash
   cat install-snippet.zshrc >> ~/.zshrc
   # Then edit the path in ~/.zshrc to match your installation
   ```
   
   **Or manually add:**
   ```bash
   # Add to ~/.zshrc (update path as needed)
   if [[ -d "$HOME/tools/github-gh-cli" ]] && [[ -f "$HOME/tools/github-gh-cli/gh-config.zsh" ]]; then
       source "$HOME/tools/github-gh-cli/gh-config.zsh"
   fi
   ```

4. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

### Enable/Disable

**To disable temporarily:**
```bash
export GH_CLI_ENABLED=0
```

**To re-enable:**
```bash
export GH_CLI_ENABLED=1
```

**To uninstall:** Simply remove or comment out the snippet from your `.zshrc`.

See [INSTALL.md](INSTALL.md) for detailed instructions.

## Usage

### Trending & Discovery

#### Find Trending AI/LLM Repositories

```bash
# Interactive search with fzf
gh-trend-ai 50

# Or use the script directly
./scripts/gh-trending-discovery.sh --topics "ai,llm" --min-stars 100 --days 30

# Get JSON output
./scripts/gh-trending-discovery.sh --format json > trending.json
```

#### Discover Emerging AI Tools

```bash
# Find tools updated in last 30 days
gh-find-ai-tools 30

# Find tools updated in last 7 days
gh-find-ai-tools 7
```

#### Track Library Updates

```bash
# Check all tracked libraries
gh-lib-updates

# Check specific category
./scripts/gh-lib-tracker.sh --category ai-ml

# Show all libraries (even without updates)
./scripts/gh-lib-tracker.sh --all --days 7
```

### Code Search

#### Search for Code Patterns

```bash
# Search for async functions in Python
gh-code-pattern "async def" python

# Search for React hooks
gh-code-pattern "useState" typescript

# Search in specific organization
gh-code-pattern "error handling" python facebook
```

#### Find Code Snippets

```bash
# Find useState examples
gh-snippet-search "useState" typescript

# Interactive search with fzf
gh-snippet-search "async await" javascript
```

#### Grep Across Repositories

```bash
# Search across all repos
gh-grep-fzf "error handling"

# Search in specific repo
gh-grep-fzf "useState" facebook/react

# Search by language
gh-grep-fzf "class.*extends" "" javascript
```

### Repository Management

#### Fuzzy Search and Clone Repos

```bash
# Search your own repos
gh-repo-fzf

# Search GitHub
gh-repo-fzf "next.js"

# Search with specific query
gh-repo-fzf "typescript framework"
```

#### Branch Management

```bash
# Interactive branch switching
gh-branch-fzf

# Or use the extension directly
gh-branch
```

#### PR Management

```bash
# List and review PRs interactively
gh-pr-fzf open

# In specific repo
gh-pr-fzf open owner/repo

# View specific PR
gh pr view <number> --web
```

### Quick Access

#### Notifications

```bash
# View notifications with fzf
gh-notify-fzf

# Or use the extension
gh notify
```

#### Issues

```bash
# Search issues interactively
gh-issue-fzf open

# In specific repo
gh-issue-fzf open owner/repo

# Or use the extension
gh-i
```

#### Starred Repos

```bash
# Browse starred repositories
gh-star-fzf

# For specific user
gh-star-fzf username
```

## Function Reference

### Trending & Discovery Functions

| Function | Description | Usage |
|----------|-------------|-------|
| `gh-trend-ai [limit] [query]` | Search trending AI/LLM repos | `gh-trend-ai 50` |
| `gh-trend-libs <lib1> <lib2> ...` | Track updates for libraries | `gh-trend-libs react vue` |
| `gh-find-ai-tools [days]` | Discover emerging AI tools | `gh-find-ai-tools 30` |
| `gh-lib-updates` | Check updates in tracked libraries | `gh-lib-updates` |

### Code Search Functions

| Function | Description | Usage |
|----------|-------------|-------|
| `gh-code-pattern <pattern> [lang] [owner]` | Search code patterns | `gh-code-pattern "async def" python` |
| `gh-snippet-search <pattern> [lang]` | Find code snippets | `gh-snippet-search "useState" typescript` |
| `gh-grep-fzf <pattern> [repo] [lang]` | Enhanced grep with fzf | `gh-grep-fzf "error handling"` |

### Repository Management Functions

| Function | Description | Usage |
|----------|-------------|-------|
| `gh-repo-fzf [query]` | Fuzzy search and clone repos | `gh-repo-fzf "next.js"` |
| `gh-branch-fzf` | Enhanced branch switching | `gh-branch-fzf` |
| `gh-pr-fzf [state] [repo]` | Interactive PR management | `gh-pr-fzf open` |

### Quick Access Functions

| Function | Description | Usage |
|----------|-------------|-------|
| `gh-notify-fzf` | View notifications | `gh-notify-fzf` |
| `gh-issue-fzf [state] [repo]` | Search issues | `gh-issue-fzf open` |
| `gh-star-fzf [user]` | Browse starred repos | `gh-star-fzf` |
| `gh-open [repo]` | Open repo in browser | `gh-open owner/repo` |

## Aliases

Quick aliases for common operations:

```bash
# Extension management
ghe          # gh ext
ghel         # gh ext list
ghes         # gh ext search
ghei         # gh ext install
gheu         # gh ext upgrade
gheua        # gh ext upgrade --all

# Quick operations
ghv          # gh repo view --web
gho          # gh-open
ghs          # gh search

# Repository
ghr          # gh repo
ghrl         # gh repo list
ghrc         # gh repo clone

# Pull requests
ghpr         # gh pr
ghprl        # gh pr list
ghprf        # gh-pr-fzf

# Issues
ghi          # gh issue
ghil         # gh issue list
ghif         # gh-issue-fzf

# Code search
ghcs         # gh search code
ghcp         # gh-code-pattern
ghss         # gh-snippet-search

# Trending
ghta         # gh-trend-ai
ghfa         # gh-find-ai-tools
ghlu         # gh-lib-updates
```

## Key Bindings

Custom key bindings for quick access (Ctrl-G + key):

- `Ctrl-G + R` - Search repos
- `Ctrl-G + I` - Search issues
- `Ctrl-G + P` - Search PRs
- `Ctrl-G + N` - View notifications
- `Ctrl-G + S` - Browse stars
- `Ctrl-G + T` - Trending AI repos

## Scripts

### Trending Discovery Script

```bash
./scripts/gh-trending-discovery.sh [OPTIONS]

Options:
  --topics TOPICS          Comma-separated topics
  --min-stars STARS        Minimum star count
  --days DAYS              Days since last update
  --limit LIMIT            Maximum results
  --format FORMAT          Output format (table, json, markdown)
```

**Example:**
```bash
./scripts/gh-trending-discovery.sh \
  --topics "ai,llm" \
  --min-stars 500 \
  --days 7 \
  --format json > trending.json
```

### Library Tracker Script

```bash
./scripts/gh-lib-tracker.sh [OPTIONS]

Options:
  --category CATEGORY      Filter by category
  --all                    Show all libraries
  --days DAYS              Days threshold
  --config FILE            Config file path
```

**Example:**
```bash
./scripts/gh-lib-tracker.sh --category ai-ml --days 7
```

### Pattern Search Script

```bash
./scripts/gh-pattern-search.sh [OPTIONS] [PATTERN]

Options:
  -p, --pattern PATTERN    Code pattern (required)
  -l, --language LANG      Programming language
  -o, --owner OWNER        Repository owner
  --limit LIMIT            Maximum results
  --format FORMAT          Output format
  --fzf                    Interactive selection
```

**Example:**
```bash
./scripts/gh-pattern-search.sh \
  --pattern "async def" \
  --language python \
  --fzf
```

## Cursor IDE Integration

### Slash Commands

Cursor slash commands are available in `.cursor/commands/`:

- `/gh-trending-ai` - Find trending AI/LLM repositories
- `/gh-find-tool` - Search for specific tools or libraries
- `/gh-lib-updates` - Check for updates in tracked libraries
- `/gh-code-pattern` - Search for code patterns
- `/gh-find-snippet` - Find code snippets
- `/gh-grep-repos` - Grep across repositories
- `/gh-pr-review` - Review PRs with AI assistance
- `/gh-issue-sync` - Sync and manage issues
- `/gh-notify` - View GitHub notifications

### Agent Hooks

Hooks in `.cursor/hooks/` for automation:

#### Library Update Check

Automatically checks for library updates when opening projects:

```bash
.cursor/hooks/lib-update-check.sh [project-dir]
```

#### Trending Suggestions

Suggests relevant trending repositories based on project context:

```bash
.cursor/hooks/trending-suggest.sh [project-dir]
```

#### PR Summary Generator

Generates PR summaries using gh extensions:

```bash
.cursor/hooks/pr-summary.sh [pr-number]
```

#### Code Pattern Suggestions

Suggests code patterns based on current file:

```bash
.cursor/hooks/code-pattern-suggest.sh <file-path>
```

### Using Hooks in Cursor

You can configure Cursor to run these hooks automatically:

1. **On Project Open**: Run `lib-update-check.sh` to check for updates
2. **On File Open**: Run `code-pattern-suggest.sh` to suggest patterns
3. **On PR View**: Run `pr-summary.sh` to generate summaries
4. **Agent Tasks**: Use hooks in agent prompts for automated workflows

## Configuration

### Tracked Libraries

Edit `config/tracked-libraries.json` to add libraries you want to track:

```json
{
  "libraries": [
    {
      "name": "library-name",
      "owner": "owner-name",
      "type": "repo",
      "description": "Description",
      "category": "ai-ml"
    }
  ]
}
```

### Environment Variables

- `GH_CLI_CONFIG_DIR` - Custom config directory (default: `~/.config/gh-cli`)
- `GH_PAGER` - Pager for gh output
- `GH_FORCE_TTY` - Force TTY mode

### fzf Configuration

fzf preview windows are configured in `gh-config.zsh`. Customize the `FZF_DEFAULT_OPTS` variable to change appearance.

## Installed Extensions

### AI/LLM & Model Management
- `github/gh-models` - GitHub Models service CLI
- `github/gh-copilot` - Terminal-based GitHub Copilot
- `githubnext/gh-aw` - GitHub Agentic Workflows

### Code Search & Pattern Discovery
- `k1LoW/gh-grep` - Search code patterns
- `LangLangBart/gh-find-code` - Code searching with fzf
- `gennaro-tedesco/gh-s` - Interactive repository search
- `gennaro-tedesco/gh-f` - Ultimate compact fzf extension

### Repository Management & Discovery
- `dlvhdr/gh-dash` - Rich terminal UI
- `2KAbhishek/gh-repo-man` - Interactive repo browsing
- `samcoe/gh-repo-explore` - Explore repos without cloning
- `jrnxf/gh-eco` - Explore the GitHub ecosystem

### Productivity & Workflow
- `mislav/gh-branch` - Fuzzy branch finding
- `meiji163/gh-notify` - GitHub notifications TUI
- `gennaro-tedesco/gh-i` - Interactive issue search
- `agynio/gh-pr-review` - Full PR review support
- `sgoedecke/gh-standup` - AI-assisted standup reports

### Additional Extensions
- `kawarimidoll/gh-q` - Clone repos with fzf and ghq
- `kavinvalli/gh-repo-fzf` - Fuzzy search repositories
- `benelan/gh-fzf` - fzf wrapper
- `kyhyco/gh-fh` - Fuzzyhub workflow

## Troubleshooting

### Extensions Not Installing

```bash
# Check gh authentication
gh auth status

# Try installing manually
gh ext install <owner/repo>

# Check extension compatibility
gh ext list
```

### Functions Not Found

```bash
# Reload configuration
source ~/.zshrc

# Or manually reload
gh-reload

# Check if functions are sourced
type gh-trend-ai
```

### fzf Not Working

```bash
# Check fzf installation
which fzf
fzf --version

# Install fzf if needed
brew install fzf  # macOS
# or
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### jq Not Found

```bash
# Install jq
brew install jq  # macOS
# or
sudo apt-get install jq  # Linux
```

## Examples

### Daily Workflow

```bash
# Morning: Check for updates
gh-lib-updates

# Find trending AI tools
gh-find-ai-tools 7

# Search for code patterns
gh-code-pattern "error handling" python

# Review PRs
gh-pr-fzf open
```

### Finding Examples

```bash
# Find React hook examples
gh-snippet-search "useEffect" typescript

# Find async/await patterns
gh-code-pattern "async.*await" javascript

# Search in specific organization
gh-grep-fzf "testing pattern" facebook "" typescript
```

### Repository Discovery

```bash
# Find trending repos
gh-trend-ai 30

# Search for specific tools
gh-repo-fzf "typescript framework"

# Browse your stars
gh-star-fzf
```

## Contributing

To add new functions or extensions:

1. Add functions to `gh-functions.zsh`
2. Add aliases to `gh-config.zsh`
3. Update this README
4. Test thoroughly

## License

This configuration is provided as-is for personal use. Individual extensions have their own licenses.

## Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub CLI Extensions](https://github.com/topics/gh-extension)
- [fzf Documentation](https://github.com/junegunn/fzf)
- [Cursor IDE Documentation](https://docs.cursor.com/)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review extension documentation
3. Check GitHub CLI issues

---

**Happy coding! 🚀**

# Find Trending AI/LLM Repositories

Search for trending AI and LLM repositories on GitHub, filtered by recent updates and popularity.

## Usage

This command will search GitHub for trending repositories related to AI, LLM, machine learning, and related topics.

## Implementation

Run the following command to search for trending AI repositories:

```bash
gh-trend-ai [limit] [query]
```

Or use the script directly (saves to workspace `trending/` directory):

```bash
./scripts/gh-trending-discovery.sh --topics "ai,llm,machine-learning" --min-stars 100 --days 30
```

**Note:** Results are automatically saved to `trending/` directory in your workspace root (relative to where the command is run).

## Examples

- Find top 50 trending AI repos: `gh-trend-ai 50`
- Search for specific AI tools: `gh-trend-ai 30 "langchain OR transformers"`
- Get JSON output: `./scripts/gh-trending-discovery.sh --format json --topics ai,llm`

## Output

The command will display:
- Repository name and owner
- Star count
- Last update date
- Description
- Topics
- Language

Results are displayed in an interactive fzf interface for easy browsing and selection.

## Function Details

The `gh-trend-ai` function is defined in `gh-functions.zsh` and uses:
- GitHub CLI (`gh`) to search repositories
- `jq` for JSON parsing
- `fzf` for interactive selection
- Default query: "ai OR llm OR machine-learning OR deep-learning"
- Default limit: 50 repositories

## Script Options

The underlying script `scripts/gh-trending-discovery.sh` supports:

- `--topics TOPICS` - Comma-separated topics (default: ai,llm,machine-learning)
- `--min-stars STARS` - Minimum star count (default: 100)
- `--days DAYS` - Days since last update (default: 30)
- `--limit LIMIT` - Maximum results (default: 50)
- `--format FORMAT` - Output format: table, json, markdown (default: table)

## Integration

This command integrates with:
- Zsh functions in `gh-functions.zsh`
- Key binding: `Ctrl-G + T` (if configured)
- Alias: `ghta` (short for `gh-trend-ai`)

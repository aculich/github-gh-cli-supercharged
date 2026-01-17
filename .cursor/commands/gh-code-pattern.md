# Search for Code Patterns

Search for specific code patterns across GitHub repositories.

## Usage

This command searches GitHub's codebase for specific patterns, useful for finding examples, implementations, or learning how others solve problems.

## Implementation

Use the pattern search script:

```bash
./scripts/gh-pattern-search.sh --pattern "<pattern>" [options]
```

Or use the function:

```bash
gh-code-pattern "<pattern>" [language] [owner]
```

## Options

- `-p, --pattern PATTERN` - Code pattern to search for (required)
- `-l, --language LANG` - Filter by programming language
- `-o, --owner OWNER` - Filter by repository owner/organization
- `--limit LIMIT` - Maximum results (default: 50)
- `--format FORMAT` - Output format: table, json, markdown
- `--fzf` - Use fzf for interactive selection

## Examples

- Search for async functions in Python: `gh-code-pattern "async def" python`
- Find React useState usage: `gh-code-pattern "useState" typescript`
- Search in specific org: `gh-code-pattern "error handling" python facebook`
- Interactive search: `./scripts/gh-pattern-search.sh --pattern "class.*extends" --language javascript --fzf`
- Get JSON output: `./scripts/gh-pattern-search.sh -p "try.*catch" --format json`

## Pattern Examples

- `"async def"` - Python async functions
- `"useState"` - React useState hook
- `"error handling"` - Error handling patterns
- `"class.*extends"` - Class inheritance (regex)
- `"try.*catch"` - Try-catch blocks
- `"def.*test"` - Test functions

## Output

Results include:
- Repository and file path
- Code snippet preview
- Direct link to the code
- Option to open in browser (with --fzf)

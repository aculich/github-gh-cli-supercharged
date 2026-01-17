# Grep Across Repositories

Search for text patterns across multiple repositories using GitHub's code search.

## Usage

This command allows you to search for patterns across repositories, similar to grep but across GitHub's entire codebase.

## Implementation

Use the grep function:

```bash
gh-grep-fzf "<pattern>" [repo] [language]
```

Or use the pattern search script:

```bash
./scripts/gh-pattern-search.sh --pattern "<pattern>" [options]
```

## Examples

- Search across all repos: `gh-grep-fzf "error handling"`
- Search in specific repo: `gh-grep-fzf "useState" facebook/react`
- Search by language: `gh-grep-fzf "async def" "" python`
- Interactive search: `gh-grep-fzf "class.*extends" "" javascript`

## Options

- Pattern (required) - The text or regex pattern to search for
- Repository (optional) - Limit search to specific repo (format: owner/repo)
- Language (optional) - Filter by programming language

## Output

Results show:
- Repository name
- File path where match was found
- Code snippet with the match highlighted
- Direct link to the code
- Option to open in browser

The fzf interface provides:
- Preview of matched code
- Easy navigation
- Quick access to view full file

# Search for Specific Tools or Libraries

Search GitHub for specific tools, libraries, or projects by name or keywords.

## Usage

This command helps you find tools and libraries on GitHub that match your search criteria.

## Implementation

Use GitHub CLI search:

```bash
gh search repos <query> --sort stars --order desc --limit 50
```

Or use the interactive function:

```bash
gh-repo-fzf "<query>"
```

## Examples

- Find a specific library: `gh search repos "react-query" --limit 20`
- Search by topic: `gh search repos topic:typescript topic:framework --limit 30`
- Interactive search: `gh-repo-fzf "next.js"`
- Find tools updated recently: `gh search repos "cli tool" --updated ">=2025-01-01" --sort updated`

## Advanced Search

You can combine multiple qualifiers:
- `language:python stars:>1000` - Python repos with 1000+ stars
- `topic:ai topic:llm pushed:>2025-01-01` - AI/LLM repos updated this year
- `user:facebook language:typescript` - TypeScript repos by Facebook

## Output

Results include:
- Repository name
- Star count
- Description
- Last update date
- Option to clone or view in browser

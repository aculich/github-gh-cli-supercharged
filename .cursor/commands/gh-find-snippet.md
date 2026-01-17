# Find Code Snippets

Search for code snippets by pattern and language across GitHub.

## Usage

Quickly find code snippets that match a specific pattern, useful for learning, reference, or finding implementation examples.

## Implementation

Use the snippet search function:

```bash
gh-snippet-search "<pattern>" [language]
```

Or use the pattern search script with fzf:

```bash
./scripts/gh-pattern-search.sh --pattern "<pattern>" --language <lang> --fzf
```

## Examples

- Find useState examples: `gh-snippet-search "useState" typescript`
- Search Python decorators: `gh-snippet-search "@decorator" python`
- Find error handling: `gh-snippet-search "try except" python`
- Interactive search: `gh-snippet-search "async await" javascript`

## Output

Results are displayed with:
- Repository name
- File path
- Code snippet preview
- Direct link to the code on GitHub
- Option to open in browser

The interactive mode (fzf) allows you to:
- Preview code snippets
- Navigate through results
- Open selected snippets in browser

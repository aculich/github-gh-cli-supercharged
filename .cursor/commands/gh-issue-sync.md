# Sync and Manage Issues

View, search, and manage GitHub issues interactively.

## Usage

This command provides an interactive interface for managing GitHub issues.

## Implementation

Use the issue search function:

```bash
gh-issue-fzf [state] [repo]
```

Or use the gh-i extension:

```bash
gh-i
```

## Examples

- List open issues: `gh-issue-fzf open`
- Search issues in repo: `gh-issue-fzf open owner/repo`
- Create new issue: `gh issue create --title "Title" --body "Description"`
- View specific issue: `gh issue view <number> --web`
- Interactive search: `gh-i`

## Features

- Interactive issue selection with fzf
- Filter by state (open, closed, all)
- View issue details, comments, and labels
- Create new issues
- Update existing issues
- Link issues to PRs

## Output

The interface displays:
- Issue number and title
- Author and last update time
- Labels and status
- Description preview
- Option to open full issue in browser

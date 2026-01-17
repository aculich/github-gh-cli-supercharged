# Review Pull Requests with AI Assistance

Review and manage pull requests with enhanced capabilities, including AI-assisted review.

## Usage

This command helps you review pull requests with additional context and AI assistance.

## Implementation

Use the PR review function:

```bash
gh-pr-fzf [state] [repo]
```

Or use the gh-pr-review extension if installed:

```bash
gh pr-review [pr-number]
```

## Examples

- List and review open PRs: `gh-pr-fzf open`
- Review PRs in specific repo: `gh-pr-fzf open owner/repo`
- View specific PR: `gh pr view <number> --web`
- Review with AI extension: `gh pr-review <number>`

## Features

- Interactive PR selection with fzf
- View PR details, comments, and reviews
- Navigate review threads
- Reply to review comments
- Resolve review threads
- LLM-ready for automated PR review agents

## Output

The interactive interface shows:
- PR number and title
- Author and last update time
- Status and labels
- Option to view full PR in browser
- Review comments and threads (with extension)

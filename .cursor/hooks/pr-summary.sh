#!/bin/bash

# Cursor Agent Hook: PR Summary Generator
# Generates PR summaries using gh extensions and AI assistance
# This hook can be used by Cursor agents to create PR summaries

set -euo pipefail

# Get PR number (from argument or git context)
PR_NUMBER="${1:-}"

# If no PR number provided, try to detect from git context
if [ -z "$PR_NUMBER" ]; then
    if git rev-parse --git-dir &> /dev/null; then
        # Try to get PR number from current branch
        BRANCH_NAME=$(git branch --show-current 2>/dev/null || echo "")
        if [ -n "$BRANCH_NAME" ]; then
            # Try to extract PR number from branch name or remote
            PR_NUMBER=$(gh pr list --head "$BRANCH_NAME" --json number --jq '.[0].number' 2>/dev/null || echo "")
        fi
    fi
fi

if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 [PR_NUMBER]"
    echo "Or run from a git repository with an associated PR"
    exit 1
fi

# Get repository info
REPO=$(gh pr view "$PR_NUMBER" --json repository --jq '.repository.nameWithOwner' 2>/dev/null || echo "")

if [ -z "$REPO" ]; then
    echo "Error: Could not find PR #$PR_NUMBER"
    exit 1
fi

echo "Generating summary for PR #$PR_NUMBER in $REPO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get PR details
PR_TITLE=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json title --jq '.title')
PR_AUTHOR=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json author --jq '.author.login')
PR_STATE=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json state --jq '.state')
PR_CREATED=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json createdAt --jq '.createdAt')
PR_UPDATED=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json updatedAt --jq '.updatedAt')

echo "Title: $PR_TITLE"
echo "Author: $PR_AUTHOR"
echo "State: $PR_STATE"
echo "Created: $PR_CREATED"
echo "Updated: $PR_UPDATED"
echo ""

# Get changed files
echo "Changed Files:"
gh pr view "$PR_NUMBER" --repo "$REPO" --json files --jq '.files[] | "  - \(.path) (\(.additions) additions, \(.deletions) deletions)"'
echo ""

# Get commits
echo "Commits:"
gh pr view "$PR_NUMBER" --repo "$REPO" --json commits --jq '.commits[] | "  - \(.messageHeadline) (\(.authors[0].name))"'
echo ""

# Try to use gh-standup extension if available for AI summary
if command -v gh-standup &> /dev/null; then
    echo "AI-Generated Summary:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    gh-standup --pr "$PR_NUMBER" 2>/dev/null || echo "  (AI summary not available)"
else
    echo "💡 Install 'gh-standup' extension for AI-assisted summaries:"
    echo "   gh ext install sgoedecke/gh-standup"
fi

echo ""
echo "View PR: https://github.com/$REPO/pull/$PR_NUMBER"

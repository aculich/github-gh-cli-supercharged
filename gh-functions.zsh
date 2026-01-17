#!/usr/bin/env zsh
# GitHub CLI Functions with fzf Integration
# Source this file in your .zshrc or gh-config.zsh

# Check dependencies (silently)
if ! command -v gh &> /dev/null; then
    # Silently note - functions will check at runtime
    :
fi

if ! command -v fzf &> /dev/null; then
    # Silently note - functions will check at runtime
    :
fi

# ============================================================================
# Trending & Discovery Functions
# ============================================================================

# Search trending AI/LLM repos with fzf preview
gh-trend-ai() {
    local limit=${1:-50}
    local query="${2:-ai OR llm OR machine-learning OR deep-learning}"
    
    echo "Searching for trending AI/LLM repositories..."
    gh search repos "$query" \
        --sort stars \
        --order desc \
        --limit "$limit" \
        --json fullName,description,stargazersCount,updatedAt,url \
        | jq -r '.[] | "\(.fullName)|\(.stargazersCount)|\(.updatedAt)|\(.description // "No description")"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2,3 \
            --preview='echo "Repository: {1}\nStars: {2}\nUpdated: {3}\n\nDescription:\n{4}"' \
            --preview-window=right:60% \
            --header="Select a repository (Enter to open, Ctrl-C to cancel)" \
        | cut -d'|' -f1 \
        | xargs -I {} gh repo view {} --web
}

# Track updates for specific libraries
gh-trend-libs() {
    local libs=("${@}")
    if [ ${#libs[@]} -eq 0 ]; then
        echo "Usage: gh-trend-libs <library1> <library2> ..."
        echo "Example: gh-trend-libs react vue angular"
        return 1
    fi
    
    for lib in "${libs[@]}"; do
        echo "Searching for trending repos related to: $lib"
        gh search repos "$lib" \
            --sort updated \
            --order desc \
            --limit 10 \
            --json fullName,description,stargazersCount,updatedAt \
            | jq -r '.[] | "\(.fullName) ⭐ \(.stargazersCount) | Updated: \(.updatedAt)"'
        echo ""
    done
}

# Discover emerging AI tools with recent updates
gh-find-ai-tools() {
    local days=${1:-30}
    local date_filter=$(date -v-${days}d +%Y-%m-%d 2>/dev/null || date -d "${days} days ago" +%Y-%m-%d)
    
    echo "Finding AI tools updated in the last $days days..."
    gh search repos \
        --topic ai,llm,artificial-intelligence,machine-learning \
        --updated ">=$date_filter" \
        --sort updated \
        --order desc \
        --limit 100 \
        --json fullName,description,stargazersCount,updatedAt,url,topics \
        | jq -r '.[] | "\(.fullName)|\(.stargazersCount)|\(.updatedAt)|\(.description // "No description")|\(.topics | join(", "))"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2,3,5 \
            --preview='echo "Repository: {1}\nStars: {2}\nUpdated: {3}\nTopics: {5}\n\nDescription:\n{4}"' \
            --preview-window=right:60% \
            --header="AI Tools (Enter to open, Ctrl-C to cancel)" \
        | cut -d'|' -f1 \
        | xargs -I {} gh repo view {} --web
}

# Check for updates in major libraries you track
gh-lib-updates() {
    local config_file="${GH_CLI_CONFIG_DIR:-$HOME/.config/gh-cli}/tracked-libraries.json"
    
    if [ ! -f "$config_file" ]; then
        echo "No tracked libraries config found at: $config_file"
        echo "Create it or set GH_CLI_CONFIG_DIR to point to your config directory"
        return 1
    fi
    
    echo "Checking for updates in tracked libraries..."
    jq -r '.libraries[] | "\(.name)|\(.owner // "github")|\(.type // "repo")"' "$config_file" \
        | while IFS='|' read -r name owner type; do
            if [ "$type" = "repo" ]; then
                local repo="$owner/$name"
                echo "Checking $repo..."
                gh api "repos/$repo/releases" --jq '.[0] | "\(.name) - \(.published_at)"' 2>/dev/null || echo "  No releases found"
            fi
        done
}

# ============================================================================
# Code Search Functions
# ============================================================================

# Search for code patterns across repos with fzf
gh-code-pattern() {
    if [ $# -eq 0 ]; then
        echo "Usage: gh-code-pattern <pattern> [language] [owner]"
        echo "Example: gh-code-pattern 'async def' python"
        return 1
    fi
    
    local pattern="$1"
    local language="${2:-}"
    local owner="${3:-}"
    local query="$pattern"
    
    if [ -n "$language" ]; then
        query="$query language:$language"
    fi
    
    if [ -n "$owner" ]; then
        query="$query user:$owner"
    fi
    
    echo "Searching for code pattern: $pattern"
    gh search code "$query" \
        --limit 50 \
        --json repository,name,path,textMatches \
        | jq -r '.[] | "\(.repository.fullName)|\(.path)|\(.textMatches[0].fragment // "No preview")"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2 \
            --preview='echo "Repository: {1}\nFile: {2}\n\nCode Preview:\n{3}"' \
            --preview-window=right:70% \
            --header="Select a match (Enter to view file, Ctrl-C to cancel)" \
        | cut -d'|' -f1,2 \
        | while IFS='|' read -r repo path; do
            gh repo view "$repo" --web
            echo "File: $path"
        done
}

# Find code snippets by pattern/language
gh-snippet-search() {
    if [ $# -lt 1 ]; then
        echo "Usage: gh-snippet-search <pattern> [language]"
        echo "Example: gh-snippet-search 'useState' typescript"
        return 1
    fi
    
    local pattern="$1"
    local language="${2:-}"
    local query="$pattern"
    
    if [ -n "$language" ]; then
        query="$query language:$language"
    fi
    
    echo "Searching for snippets: $pattern"
    gh search code "$query" \
        --limit 30 \
        --json repository,name,path,textMatches,htmlUrl \
        | jq -r '.[] | "\(.repository.fullName)|\(.path)|\(.htmlUrl)|\(.textMatches[0].fragment // "No preview")"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2 \
            --preview='echo "Repository: {1}\nFile: {2}\nURL: {3}\n\nCode:\n{4}"' \
            --preview-window=right:70% \
            --header="Select a snippet (Enter to open, Ctrl-C to cancel)" \
        | cut -d'|' -f3 \
        | xargs open
}

# Enhanced grep with fzf preview
gh-grep-fzf() {
    if [ $# -lt 1 ]; then
        echo "Usage: gh-grep-fzf <pattern> [repo] [language]"
        echo "Example: gh-grep-fzf 'error handling' myorg/myrepo python"
        return 1
    fi
    
    local pattern="$1"
    local repo="${2:-}"
    local language="${3:-}"
    local query="$pattern"
    
    if [ -n "$repo" ]; then
        query="$query repo:$repo"
    fi
    
    if [ -n "$language" ]; then
        query="$query language:$language"
    fi
    
    echo "Searching: $pattern"
    gh search code "$query" \
        --limit 50 \
        --json repository,name,path,textMatches \
        | jq -r '.[] | "\(.repository.fullName)|\(.path)|\(.textMatches[0].fragment // "No preview")"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2 \
            --preview='echo "Repo: {1}\nFile: {2}\n\nMatch:\n{3}"' \
            --preview-window=right:70% \
        | cut -d'|' -f1,2 \
        | while IFS='|' read -r repo_path file_path; do
            echo "Repository: $repo_path"
            echo "File: $file_path"
            gh repo view "$repo_path" --web
        done
}

# ============================================================================
# Repository Management Functions
# ============================================================================

# Fuzzy search and clone repos
gh-repo-fzf() {
    local query="${1:-}"
    
    if [ -z "$query" ]; then
        # Search your own repos
        echo "Searching your repositories..."
        gh repo list --limit 100 --json fullName,description,updatedAt \
            | jq -r '.[] | "\(.fullName)|\(.updatedAt)|\(.description // "No description")"' \
            | fzf \
                --delimiter='|' \
                --with-nth=1,2 \
                --preview='echo "Repository: {1}\nUpdated: {2}\n\nDescription:\n{3}"' \
                --preview-window=right:60% \
                --header="Select a repo (Enter to clone, Ctrl-C to cancel)" \
            | cut -d'|' -f1 \
            | xargs -I {} gh repo clone {}
    else
        # Search GitHub
        echo "Searching GitHub for: $query"
        gh search repos "$query" \
            --limit 50 \
            --json fullName,description,stargazersCount,updatedAt \
            | jq -r '.[] | "\(.fullName)|\(.stargazersCount)|\(.updatedAt)|\(.description // "No description")"' \
            | fzf \
                --delimiter='|' \
                --with-nth=1,2,3 \
                --preview='echo "Repository: {1}\nStars: {2}\nUpdated: {3}\n\nDescription:\n{4}"' \
                --preview-window=right:60% \
                --header="Select a repo (Enter to clone, Ctrl-C to cancel)" \
            | cut -d'|' -f1 \
            | xargs -I {} gh repo clone {}
    fi
}

# Enhanced branch switching
gh-branch-fzf() {
    if ! git rev-parse --git-dir &> /dev/null; then
        echo "Error: Not in a git repository"
        return 1
    fi
    
    # Use gh-branch extension if available, otherwise fallback
    if command -v gh-branch &> /dev/null; then
        gh-branch
    else
        git branch -a \
            | sed 's/^..//' \
            | sed 's/^remotes\/[^/]*\///' \
            | sort -u \
            | fzf \
                --preview='git log --oneline --graph --decorate {1} -10' \
                --preview-window=right:50% \
                --header="Select a branch (Enter to checkout, Ctrl-C to cancel)" \
            | xargs git checkout
    fi
}

# Interactive PR management
gh-pr-fzf() {
    local state="${1:-open}"
    local repo="${2:-}"
    
    if [ -z "$repo" ]; then
        if git rev-parse --git-dir &> /dev/null; then
            repo=$(git remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/\.git$//')
        fi
    fi
    
    if [ -z "$repo" ]; then
        echo "Usage: gh-pr-fzf [state] [repo]"
        echo "Example: gh-pr-fzf open owner/repo"
        return 1
    fi
    
    echo "Fetching $state pull requests for $repo..."
    gh pr list --repo "$repo" --state "$state" --limit 100 \
        --json number,title,author,updatedAt,url \
        | jq -r '.[] | "\(.number)|\(.title)|\(.author.login)|\(.updatedAt)|\(.url)"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2,3,4 \
            --preview='echo "PR #{}: {2}\nAuthor: {3}\nUpdated: {4}\nURL: {5}"' \
            --preview-window=right:60% \
            --header="Select a PR (Enter to open, Ctrl-C to cancel)" \
        | cut -d'|' -f5 \
        | xargs open
}

# ============================================================================
# Quick Access Functions
# ============================================================================

# View notifications with fzf
gh-notify-fzf() {
    # Use gh-notify extension if available
    if command -v gh-notify &> /dev/null; then
        gh-notify
    else
        echo "Fetching notifications..."
        gh api notifications --jq '.[] | "\(.id)|\(.subject.title)|\(.repository.full_name)|\(.updated_at)"' \
            | fzf \
                --delimiter='|' \
                --with-nth=2,3,4 \
                --preview='echo "Title: {2}\nRepository: {3}\nUpdated: {4}"' \
                --preview-window=right:60% \
                --header="Select a notification (Enter to view, Ctrl-C to cancel)" \
            | cut -d'|' -f1 \
            | xargs -I {} gh api "notifications/threads/{}" --method PATCH -f read=true
    fi
}

# Search issues interactively
gh-issue-fzf() {
    local state="${1:-open}"
    local repo="${2:-}"
    
    if [ -z "$repo" ]; then
        if git rev-parse --git-dir &> /dev/null; then
            repo=$(git remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/\.git$//')
        fi
    fi
    
    if [ -z "$repo" ]; then
        # Use gh-i extension if available
        if command -v gh-i &> /dev/null; then
            gh-i
            return
        fi
        echo "Usage: gh-issue-fzf [state] [repo]"
        echo "Example: gh-issue-fzf open owner/repo"
        return 1
    fi
    
    echo "Fetching $state issues for $repo..."
    gh issue list --repo "$repo" --state "$state" --limit 100 \
        --json number,title,author,updatedAt,url,labels \
        | jq -r '.[] | "\(.number)|\(.title)|\(.author.login)|\(.updatedAt)|\(.labels[].name // "none" | join(", "))|\(.url)"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2,3,5 \
            --preview='echo "Issue #{}: {2}\nAuthor: {3}\nUpdated: {4}\nLabels: {5}\nURL: {6}"' \
            --preview-window=right:60% \
            --header="Select an issue (Enter to open, Ctrl-C to cancel)" \
        | cut -d'|' -f6 \
        | xargs open
}

# Browse starred repos
gh-star-fzf() {
    local user="${1:-}"
    
    if [ -z "$user" ]; then
        user=$(gh api user --jq '.login')
    fi
    
    echo "Fetching starred repositories for $user..."
    gh api "users/$user/starred" --paginate \
        --jq '.[] | "\(.full_name)|\(.stargazers_count)|\(.updated_at)|\(.description // "No description")"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2,3 \
            --preview='echo "Repository: {1}\nStars: {2}\nUpdated: {3}\n\nDescription:\n{4}"' \
            --preview-window=right:60% \
            --header="Select a starred repo (Enter to view, Ctrl-C to cancel)" \
        | cut -d'|' -f1 \
        | xargs -I {} gh repo view {} --web
}

# ============================================================================
# Utility Functions
# ============================================================================

# Quick alias to open GitHub repo in browser
gh-open() {
    local repo="${1:-}"
    
    if [ -z "$repo" ]; then
        if git rev-parse --git-dir &> /dev/null; then
            repo=$(git remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/\.git$//')
        fi
    fi
    
    if [ -z "$repo" ]; then
        echo "Usage: gh-open [repo]"
        echo "Example: gh-open owner/repo"
        return 1
    fi
    
    gh repo view "$repo" --web
}

# Quick search across all your repos
gh-search-my-repos() {
    local query="${1:-}"
    
    if [ -z "$query" ]; then
        echo "Usage: gh-search-my-repos <query>"
        return 1
    fi
    
    local user=$(gh api user --jq '.login')
    echo "Searching your repositories for: $query"
    
    gh search repos "$query" user:"$user" \
        --limit 50 \
        --json fullName,description,updatedAt \
        | jq -r '.[] | "\(.fullName)|\(.updatedAt)|\(.description // "No description")"' \
        | fzf \
            --delimiter='|' \
            --with-nth=1,2 \
            --preview='echo "Repository: {1}\nUpdated: {2}\n\nDescription:\n{3}"' \
            --preview-window=right:60% \
        | cut -d'|' -f1 \
        | xargs -I {} gh repo view {} --web
}

# Export functions for use in other scripts
export -f gh-trend-ai gh-trend-libs gh-find-ai-tools gh-lib-updates
export -f gh-code-pattern gh-snippet-search gh-grep-fzf
export -f gh-repo-fzf gh-branch-fzf gh-pr-fzf
export -f gh-notify-fzf gh-issue-fzf gh-star-fzf
export -f gh-open gh-search-my-repos

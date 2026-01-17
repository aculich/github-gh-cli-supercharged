#!/bin/bash

# Clone Trending Repositories Script
# Clones repositories from trending JSON files and generates manifests

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TRENDING_DIR="$PROJECT_ROOT/trending"
UPSTREAM_DIR="$PROJECT_ROOT/upstream"

# Create directories if they don't exist
mkdir -p "$TRENDING_DIR"
mkdir -p "$UPSTREAM_DIR"

# Check dependencies
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: gh CLI is not installed${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed${NC}"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

# Parse arguments
MODE="${1:-latest}"
PATTERN="${1:-}"

# Find trending JSON files
JSON_FILES=()
if [ "$MODE" = "all" ]; then
    # Get all JSONL files sorted by modification time (newest first)
    while IFS= read -r file; do
        [ -n "$file" ] && JSON_FILES+=("$file")
    done < <(find "$TRENDING_DIR" -name "trending-*.jsonl" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | cut -d' ' -f2- || find "$TRENDING_DIR" -name "trending-*.jsonl" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | cut -d' ' -f2- || ls -t "$TRENDING_DIR"/trending-*.jsonl 2>/dev/null)
elif [ "$MODE" = "latest" ] || [ -z "$1" ]; then
    # Get the latest JSONL file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        LATEST=$(find "$TRENDING_DIR" -name "trending-*.jsonl" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    else
        LATEST=$(find "$TRENDING_DIR" -name "trending-*.jsonl" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || ls -t "$TRENDING_DIR"/trending-*.jsonl 2>/dev/null | head -1)
    fi
    if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
        JSON_FILES=("$LATEST")
    fi
else
    # Pattern matching - use latest file but filter by pattern
    if [[ "$OSTYPE" == "darwin"* ]]; then
        LATEST=$(find "$TRENDING_DIR" -name "trending-*.jsonl" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    else
        LATEST=$(find "$TRENDING_DIR" -name "trending-*.jsonl" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || ls -t "$TRENDING_DIR"/trending-*.jsonl 2>/dev/null | head -1)
    fi
    if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
        JSON_FILES=("$LATEST")
        PATTERN="$1"
    fi
fi

if [ ${#JSON_FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}No trending JSON files found in: $TRENDING_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Clone Trending Repositories${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Mode:${NC} $MODE"
if [ -n "$PATTERN" ] && [ "$PATTERN" != "latest" ] && [ "$PATTERN" != "all" ]; then
    echo -e "${GREEN}Pattern:${NC} $PATTERN"
fi
echo -e "${GREEN}Files to process:${NC} ${#JSON_FILES[@]}"
echo -e "${GREEN}Upstream directory:${NC} $UPSTREAM_DIR"
echo ""

# Collect all repositories to clone
REPOS_TO_CLONE=()

for JSON_FILE in "${JSON_FILES[@]}"; do
    echo -e "${BLUE}Processing:${NC} $(basename "$JSON_FILE")"
    
    if [ -n "$PATTERN" ] && [ "$PATTERN" != "latest" ] && [ "$PATTERN" != "all" ]; then
        # Filter by pattern
        MATCHING=$(jq -r --arg pattern "$PATTERN" 'select(.fullName | ascii_downcase | contains($pattern | ascii_downcase)) | .fullName' "$JSON_FILE")
        while IFS= read -r repo; do
            if [ -n "$repo" ]; then
                REPOS_TO_CLONE+=("$repo")
            fi
        done <<< "$MATCHING"
    else
        # Get all repos from file
        while IFS= read -r repo; do
            if [ -n "$repo" ]; then
                REPOS_TO_CLONE+=("$repo")
            fi
        done < <(jq -r '.fullName' "$JSON_FILE")
    fi
done

# Remove duplicates
UNIQUE_REPOS=($(printf '%s\n' "${REPOS_TO_CLONE[@]}" | sort -u))

if [ ${#UNIQUE_REPOS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No repositories found matching criteria.${NC}"
    exit 0
fi

echo -e "${GREEN}Repositories to clone:${NC} ${#UNIQUE_REPOS[@]}"
echo ""

# Function to generate manifest
generate_manifest() {
    local repo_full_name="$1"
    local repo_dir="$2"
    local json_data="$3"
    
    local manifest_file="$repo_dir/MANIFEST.md"
    
    {
        echo "# Repository Manifest: $repo_full_name"
        echo ""
        echo "Generated: $(date)"
        echo ""
        echo "## GitHub Metadata"
        echo ""
        echo "$json_data" | jq -r '
            "- **Full Name**: \(.fullName)
- **Description**: \(.description // "No description")
- **Stars**: \(.stargazersCount)
- **Forks**: \(.forksCount)
- **Watchers**: \(.watchersCount)
- **Open Issues**: \(.openIssuesCount)
- **Language**: \(.language // "N/A")
- **Created**: \(.createdAt)
- **Updated**: \(.updatedAt)
- **Last Pushed**: \(.pushedAt)
- **Size**: \(.size) KB
- **Default Branch**: \(.defaultBranch)
- **Visibility**: \(.visibility)
- **Archived**: \(.isArchived)
- **Private**: \(.isPrivate)
- **URL**: \(.url)
- **Homepage**: \(.homepage // "N/A")
- **License**: \(.license.name // "N/A")"
        '
        echo ""
        echo "## README"
        echo ""
        if [ -f "$repo_dir/README.md" ]; then
            echo "\`\`\`markdown"
            cat "$repo_dir/README.md"
            echo "\`\`\`"
        else
            echo "*No README.md found*"
        fi
        echo ""
    } > "$manifest_file"
    
    # Add repomix analysis if available
    echo "## Codebase Analysis" >> "$manifest_file"
    echo "" >> "$manifest_file"
    
    cd "$repo_dir"
    
    # Extract languages from GitHub metadata or detect from files
    {
        echo "### Programming Languages"
        echo ""
        if [ -n "$(echo "$json_data" | jq -r '.language // empty')" ]; then
            echo "- Primary: $(echo "$json_data" | jq -r '.language // "N/A"')"
        fi
        # Detect additional languages from files
        if command -v cloc &> /dev/null; then
            cloc --json . 2>/dev/null | jq -r '.SUM.languages // {} | to_entries[] | "- \(.key): \(.value.code) lines"' 2>/dev/null | head -10
        else
            # Simple detection from file extensions
            echo "*Install cloc for detailed language analysis*"
        fi
        echo ""
    } >> "$manifest_file"
    
    # Extract dependencies from package files
    {
        echo "### Dependencies"
        echo ""
        
        # Node.js/npm
        if [ -f "package.json" ]; then
            echo "#### npm/Node.js Dependencies:"
            echo ""
            echo "**Production:**"
            jq -r '.dependencies // {} | to_entries[] | "- \(.key): \(.value)"' package.json 2>/dev/null | head -30
            echo ""
            echo "**Development:**"
            jq -r '.devDependencies // {} | to_entries[] | "- \(.key): \(.value)"' package.json 2>/dev/null | head -20
            echo ""
        fi
        
        # Python
        if [ -f "requirements.txt" ]; then
            echo "#### Python Dependencies (requirements.txt):"
            head -50 requirements.txt | sed 's/^/- /'
            echo ""
        fi
        if [ -f "pyproject.toml" ]; then
            echo "#### Python Dependencies (pyproject.toml):"
            if command -v tomlq &> /dev/null; then
                tomlq -r '.project.dependencies[]?' pyproject.toml 2>/dev/null | head -30 | sed 's/^/- /'
            else
                grep -E "^\[project\]|^dependencies" pyproject.toml | head -20
            fi
            echo ""
        fi
        
        # Go
        if [ -f "go.mod" ]; then
            echo "#### Go Dependencies:"
            grep -E "^require" go.mod | head -30 | sed 's/^require //; s/^/- /'
            echo ""
        fi
        
        # Rust
        if [ -f "Cargo.toml" ]; then
            echo "#### Rust Dependencies:"
            grep -E "^\[dependencies\]|^[a-zA-Z]" Cargo.toml | head -30 | sed 's/^/- /'
            echo ""
        fi
    } >> "$manifest_file"
    
    # AI/LLM specific analysis
    {
        echo "### AI/LLM Libraries and Models"
        echo ""
        
        AI_LIBS_FOUND=false
        
        # Check package.json
        if [ -f "package.json" ]; then
            AI_DEPS=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | to_entries[] | select(.key | test("(openai|anthropic|langchain|transformers|torch|tensorflow|llama|gpt|claude|gemini|ai|ml|model|ollama|cohere|huggingface|pytorch|keras|jax)"; "i")) | "\(.key): \(.value)"' package.json 2>/dev/null)
            if [ -n "$AI_DEPS" ]; then
                echo "$AI_DEPS" | sed 's/^/- /'
                AI_LIBS_FOUND=true
            fi
        fi
        
        # Check requirements.txt
        if [ -f "requirements.txt" ]; then
            AI_REQS=$(grep -iE "(openai|anthropic|langchain|transformers|torch|tensorflow|llama|gpt|claude|gemini|ollama|cohere|huggingface|pytorch|keras|jax|sentencepiece|tokenizers)" requirements.txt 2>/dev/null)
            if [ -n "$AI_REQS" ]; then
                echo "$AI_REQS" | sed 's/^/- /'
                AI_LIBS_FOUND=true
            fi
        fi
        
        # Search for model references in code
        echo ""
        echo "#### Model References in Code:"
        MODEL_REFS=$(grep -riE "(model.*version|model.*name|gpt-[0-9]|claude-[0-9]|gemini-[0-9]|llama-[0-9]|text-davinci|gpt-4|gpt-3)" --include="*.py" --include="*.js" --include="*.ts" --include="*.json" . 2>/dev/null | head -20 | sed 's/^/- /' || true)
        if [ -n "$MODEL_REFS" ]; then
            echo "$MODEL_REFS"
            AI_LIBS_FOUND=true
        fi
        
        if [ "$AI_LIBS_FOUND" = false ]; then
            echo "*No AI/LLM libraries or model references detected*"
        fi
        echo ""
    } >> "$manifest_file"
    
    # Architecture and structure
    {
        echo "### Project Structure"
        echo ""
        echo "**Key Files:**"
        find . -maxdepth 2 -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) ! -path "*/node_modules/*" ! -path "*/.git/*" | head -20 | sed 's|^\./||; s|^|- |'
        echo ""
    } >> "$manifest_file"
    
    cd "$PROJECT_ROOT"
    
    echo "✅ Manifest generated: $manifest_file"
}

# Clone repositories
CLONED=0
SKIPPED=0
FAILED=0

for repo in "${UNIQUE_REPOS[@]}"; do
    owner=$(echo "$repo" | cut -d'/' -f1)
    repo_name=$(echo "$repo" | cut -d'/' -f2)
    target_dir="$UPSTREAM_DIR/$owner/$repo_name"
    
    echo -e "${BLUE}Processing:${NC} $repo"
    
    # Check if already cloned
    if [ -d "$target_dir/.git" ]; then
        echo -e "${YELLOW}  Already exists, skipping clone...${NC}"
        SKIPPED=$((SKIPPED + 1))
    else
        # Clone repository
        echo -e "${GREEN}  Cloning...${NC}"
        if git clone "https://github.com/$repo.git" "$target_dir" 2>/dev/null; then
            echo -e "${GREEN}  ✅ Cloned successfully${NC}"
            CLONED=$((CLONED + 1))
        else
            echo -e "${RED}  ❌ Clone failed${NC}"
            FAILED=$((FAILED + 1))
            continue
        fi
    fi
    
    # Get repository metadata from the JSON file
    REPO_DATA=""
    for JSON_FILE in "${JSON_FILES[@]}"; do
        REPO_DATA=$(jq -r --arg repo "$repo" 'select(.fullName == $repo)' "$JSON_FILE" | head -1)
        if [ -n "$REPO_DATA" ] && [ "$REPO_DATA" != "null" ]; then
            break
        fi
    done
    
    # Generate manifest
    if [ -n "$REPO_DATA" ] && [ "$REPO_DATA" != "null" ]; then
        generate_manifest "$repo" "$target_dir" "$REPO_DATA"
    else
        echo -e "${YELLOW}  ⚠️  No metadata found, creating basic manifest${NC}"
        {
            echo "# Repository Manifest: $repo"
            echo ""
            echo "Generated: $(date)"
            echo ""
            echo "## GitHub Metadata"
            echo ""
            echo "*Metadata not available in trending file*"
            echo ""
            echo "## README"
            echo ""
            if [ -f "$target_dir/README.md" ]; then
                echo "\`\`\`markdown"
                cat "$target_dir/README.md"
                echo "\`\`\`"
            else
                echo "*No README.md found*"
            fi
        } > "$target_dir/MANIFEST.md"
    fi
    
    echo ""
done

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Cloned:${NC} $CLONED"
echo -e "${YELLOW}Skipped (already exists):${NC} $SKIPPED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""
echo -e "${GREEN}Repositories are in:${NC} $UPSTREAM_DIR"
echo -e "${GREEN}Manifests generated in each repository directory${NC}"

# Clone Trending Repositories

Clone trending repositories from the latest trending search results into the `upstream/` directory and generate a comprehensive manifest.

## Usage

```bash
/gh-clone-trending [substring-pattern]
```

## Options

- **No argument**: Clone all repositories from the most recent trending JSON file
- **substring-pattern**: Clone repositories matching the specified substring (case-insensitive, searches in latest file)

## Examples

- Clone all repos from latest trending: `/gh-clone-trending`
- Clone repos matching "langchain": `/gh-clone-trending langchain`
- Clone repos matching "banana": `/gh-clone-trending banana`
- Clone repos matching "openai": `/gh-clone-trending openai`

## What It Does

1. **Finds Latest Trending File**: Automatically locates the most recent JSON file in the workspace `trending/` directory (workspace-relative)
2. **Filters Repositories**: If a substring is provided, filters repositories by matching the substring in the repository name (case-insensitive). Otherwise, clones all repositories from the latest file.
3. **Clones Repositories**: Clones matching repos into workspace `upstream/` directory (workspace-relative)
4. **Generates Manifest**: Creates a comprehensive markdown manifest for each cloned repo including:
   - GitHub metadata (stars, forks, dates, language, etc.)
   - README.md content
   - Repomix analysis (tech stack, architecture, AI/LLM libraries, model versions, etc.)

## Manifest Contents

Each manifest includes:
- **GitHub Metadata**: Stars, forks, watchers, dates, language, license, etc.
- **README.md**: Full content from the repository
- **Programming Languages**: Detected languages and line counts
- **Dependencies**: 
  - npm/Node.js (package.json)
  - Python (requirements.txt, pyproject.toml)
  - Go (go.mod)
  - Rust (Cargo.toml)
- **AI/LLM Libraries**: 
  - AI/ML libraries detected in dependencies
  - Model version references found in code
  - Framework versions (PyTorch, TensorFlow, etc.)
- **Project Structure**: Key files and directory layout

## Output

- Cloned repositories: `upstream/{owner}/{repo-name}/`
- Manifest files: `upstream/{owner}/{repo-name}/MANIFEST.md`

# Clone Trending Repositories

Clone trending repositories from the latest trending search results into the `upstream/` directory and generate a comprehensive manifest.

## Usage

```bash
/gh-clone-trending [latest|all|repo-name-pattern]
```

## Options

- **latest** (default): Clone all repositories from the most recent trending JSON file
- **all**: Clone repositories from all trending JSON files
- **repo-name-pattern**: Clone repositories matching the specified pattern (searches in latest file)

## Examples

- Clone all repos from latest trending: `/gh-clone-trending` or `/gh-clone-trending latest`
- Clone all repos from all trending files: `/gh-clone-trending all`
- Clone repos matching "banana": `/gh-clone-trending banana`
- Clone repos matching "langchain": `/gh-clone-trending langchain`

## What It Does

1. **Finds Trending Files**: Locates JSON files in the `trending/` directory
2. **Filters Repositories**: Based on your selection (latest/all/pattern)
3. **Clones Repositories**: Clones matching repos into `upstream/` directory
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

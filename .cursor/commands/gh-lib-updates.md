# Check for Updates in Tracked Libraries

Check for recent releases and updates in libraries you're tracking.

## Usage

This command checks the tracked libraries configuration and reports any recent updates.

## Implementation

Run the library tracker script:

```bash
./scripts/gh-lib-tracker.sh [options]
```

Or use the function:

```bash
gh-lib-updates
```

## Options

- `--category CATEGORY` - Filter by category (e.g., ai-ml, frontend)
- `--all` - Show all libraries, even without recent updates
- `--days DAYS` - Days threshold for "recent" updates (default: 30)
- `--config FILE` - Path to custom config file

## Examples

- Check all tracked libraries: `./scripts/gh-lib-tracker.sh`
- Check only AI/ML libraries: `./scripts/gh-lib-tracker.sh --category ai-ml`
- Show updates from last 7 days: `./scripts/gh-lib-tracker.sh --days 7`
- Show all libraries: `./scripts/gh-lib-tracker.sh --all`

## Configuration

Libraries are tracked in `config/tracked-libraries.json`. Add libraries to track:

```json
{
  "libraries": [
    {
      "name": "library-name",
      "owner": "owner-name",
      "type": "repo",
      "description": "Description",
      "category": "category-name"
    }
  ]
}
```

## Output

For each library, the command shows:
- Latest release information (if available)
- Release date and version
- Release notes preview
- Link to release page
- Summary of updated vs. non-updated libraries

# View GitHub Notifications

View and manage GitHub notifications in an interactive interface.

## Usage

This command displays your GitHub notifications with filtering and interaction capabilities.

## Implementation

Use the notification function:

```bash
gh-notify-fzf
```

Or use the gh-notify extension:

```bash
gh notify
```

## Examples

- View all notifications: `gh-notify-fzf`
- List notifications: `gh api notifications`
- Mark as read: `gh api notifications/threads/<id> --method PATCH -f read=true`
- View unread count: `gh api notifications --jq 'length'`

## Features

- Interactive notification browser
- Filter by type (issue, PR, discussion, etc.)
- Mark as read/unread
- Navigate to related items
- Preview notification content

## Output

The interface shows:
- Notification title
- Repository name
- Type and reason
- Last update time
- Option to view or mark as read

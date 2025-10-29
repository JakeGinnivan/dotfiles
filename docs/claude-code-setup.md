# Claude Code Configuration

This directory contains Claude Code configuration managed by chezmoi.

## Conversation Archive Hook

The `PreCompact` hook automatically archives conversation transcripts before they are compacted (either manually via `/compact` or automatically when context is full).

### What it does

- **Archives conversations** before compaction to preserve context
- **Organizes by project and date** for easy browsing
- **Extracts metadata** (session ID, message count, size, timestamps)
- **Creates summaries** with first/last messages for quick review
- **Maintains an index** of all archives per project

### Files

- `~/.claude/settings.json` - Claude Code settings including hook configuration
- `~/.local/bin/archive-claude-conversation.sh` - Archive script
- `~/.claude/conversation-archive/` - Archive storage location

### Archive Structure

```
~/.claude/conversation-archive/
└── {project-name}/
    ├── index.jsonl                          # Project archive index
    └── {date}/
        ├── {timestamp}_{trigger}_{session}.jsonl      # Full transcript
        ├── {timestamp}_{trigger}_{session}.meta.json  # Metadata
        └── {timestamp}_{trigger}_{session}.summary.txt # Human-readable summary
```

### Testing

Before applying changes, test the hook:

```bash
cd ~/.local/share/chezmoi
./test-archive-hook.sh
```

This will:

1. Find an existing transcript from this project
2. Run the archive script with mock input
3. Show you where the archive was created

### Applying Changes

After reviewing the changes in the chezmoi source:

```bash
# Preview what will change
chezmoi diff

# Apply to your home directory
chezmoi apply

# Or apply specific files
chezmoi apply ~/.claude/settings.json
chezmoi apply ~/.local/bin/archive-claude-conversation.sh
```

### Settings Configuration

The hook is configured in `~/.claude/settings.json`:

```json
{
    "hooks": {
        "PreCompact": [
            {
                "matcher": "*",
                "hooks": [
                    {
                        "type": "command",
                        "command": "$HOME/.local/bin/archive-claude-conversation.sh",
                        "timeout": 30
                    }
                ]
            }
        ]
    }
}
```

Additional settings include:

- **Sandbox**: Enabled with auto-allow for better workflow
- **Permissions**: Allow common commands (git, brew, chezmoi) while denying destructive operations
- **Deny patterns**: Protect .env files and secrets directories

### Usage

The hook runs automatically:

- **Manual trigger**: When you run `/compact` command
- **Auto trigger**: When context window fills up

You'll see output like:

```
✅ Conversation archived: 2025-10-22/20251022-153045_manual_abc123.jsonl
📊 Messages: 156 | Size: 245K
```

### Reviewing Archives

Each archive includes three files:

1. **`.jsonl`** - Full conversation transcript (same format as Claude's internal storage)
2. **`.meta.json`** - Structured metadata for programmatic access
3. **`.summary.txt`** - Human-readable summary with first/last messages

Browse archives:

```bash
# List all archives for current project
ls -lh ~/.claude/conversation-archive/chezmoi/

# View a summary
cat ~/.claude/conversation-archive/chezmoi/2025-10-22/*.summary.txt

# Extract specific data with jq
jq '.snapshot.messages[] | select(.role == "user") | .content' archive.jsonl
```

### Future Enhancements

Potential additions:

- **AI review pipeline** - Automated analysis of failed/unclear interactions
- **Documentation improvement** - Extract common issues to improve project docs
- **Search functionality** - Find specific conversations by topic/date
- **Git integration** - Commit archives to a separate repo for versioning

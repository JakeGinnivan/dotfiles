#!/bin/bash
#
# Claude Code PreCompact Hook - Archive Conversation Transcripts
#
# This script archives conversation transcripts before they are compacted,
# preserving context for documentation improvement and analysis.
#

set -euo pipefail

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Parse JSON input
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')
TRIGGER=$(echo "$HOOK_INPUT" | jq -r '.trigger')
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-unknown}"

# Expand tilde in transcript path
TRANSCRIPT_PATH="${TRANSCRIPT_PATH/#\~/$HOME}"

# Create archive directory structure
ARCHIVE_BASE="$HOME/.claude/conversation-archive"
PROJECT_NAME=$(basename "$PROJECT_DIR")
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Organize by project and date
ARCHIVE_DIR="$ARCHIVE_BASE/$PROJECT_NAME/$DATE"
mkdir -p "$ARCHIVE_DIR"

# Check if transcript exists
if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
    echo "⚠️  Transcript file not found: $TRANSCRIPT_PATH" >&2
    exit 0  # Don't block compaction
fi

# Archive filename with timestamp and trigger type
ARCHIVE_FILE="$ARCHIVE_DIR/${TIMESTAMP}_${TRIGGER}_${SESSION_ID}.jsonl"

# Copy transcript to archive
cp "$TRANSCRIPT_PATH" "$ARCHIVE_FILE"

# Extract metadata for easy browsing
METADATA_FILE="${ARCHIVE_FILE%.jsonl}.meta.json"
cat > "$METADATA_FILE" <<EOF
{
  "session_id": "$SESSION_ID",
  "project": "$PROJECT_NAME",
  "project_dir": "$PROJECT_DIR",
  "timestamp": "$TIMESTAMP",
  "date": "$DATE",
  "trigger": "$TRIGGER",
  "original_path": "$TRANSCRIPT_PATH",
  "archive_path": "$ARCHIVE_FILE",
  "message_count": $(wc -l < "$TRANSCRIPT_PATH" | xargs),
  "size_bytes": $(stat -f%z "$TRANSCRIPT_PATH")
}
EOF

# Create a human-readable summary
SUMMARY_FILE="${ARCHIVE_FILE%.jsonl}.summary.txt"
{
    echo "=== Claude Code Conversation Archive ==="
    echo "Project: $PROJECT_NAME"
    echo "Date: $DATE $TIMESTAMP"
    echo "Session: $SESSION_ID"
    echo "Trigger: $TRIGGER"
    echo "Messages: $(wc -l < "$TRANSCRIPT_PATH" | xargs)"
    echo ""
    echo "Archive location: $ARCHIVE_FILE"
    echo ""
    echo "--- First message ---"
    head -1 "$TRANSCRIPT_PATH" | jq -r 'if .type == "message" then (.content // .text // "N/A") else "N/A" end' 2>/dev/null || echo "Unable to extract"
    echo ""
    echo "--- Last message ---"
    tail -1 "$TRANSCRIPT_PATH" | jq -r 'if .type == "message" then (.content // .text // "N/A") else "N/A" end' 2>/dev/null || echo "Unable to extract"
} > "$SUMMARY_FILE"

# Output success message (shown to user)
echo "✅ Conversation archived: $ARCHIVE_DIR/$(basename "$ARCHIVE_FILE")"
echo "📊 Messages: $(wc -l < "$TRANSCRIPT_PATH" | xargs) | Size: $(du -h "$TRANSCRIPT_PATH" | cut -f1)"

# Maintain an index of all archives for the project
INDEX_FILE="$ARCHIVE_BASE/$PROJECT_NAME/index.jsonl"
echo "$HOOK_INPUT" | jq --arg archive "$ARCHIVE_FILE" '. + {archive_path: $archive, archived_at: now | todateiso8601}' >> "$INDEX_FILE"

# Success - allow compaction to proceed
exit 0

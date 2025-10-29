#!/bin/bash
#
# Test script for Claude Code PreCompact hook
#
# Usage: ./test-archive-hook.sh
#

set -euo pipefail

echo "🧪 Testing Claude Code archive hook..."
echo ""

# Determine the project directory (allows callers to override)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/.local/share/chezmoi}"
PROJECT_SLUG="-"$(echo "$PROJECT_DIR" | sed 's#^/##; s#/#-#g; s#\.#-#g')
PROJECT_ARCHIVE_DIR="$HOME/.claude/projects/$PROJECT_SLUG"

# Ensure the project archive directory exists
if [[ ! -d "$PROJECT_ARCHIVE_DIR" ]]; then
    echo "❌ Project archive directory not found: $PROJECT_ARCHIVE_DIR"
    exit 1
fi

# Find an actual transcript file to test with
TRANSCRIPT=$(find "$PROJECT_ARCHIVE_DIR" -name "*.jsonl" -type f | head -1)

if [[ -z "$TRANSCRIPT" ]]; then
    echo "❌ No transcript files found in project"
    exit 1
fi

echo "📄 Using transcript: $TRANSCRIPT"
echo ""

# Create mock hook input
MOCK_INPUT=$(cat <<EOF
{
  "session_id": "test-$(date +%s)",
  "transcript_path": "$TRANSCRIPT",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": ""
}
EOF
)

# Set required environment variable
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run the hook script
echo "🔧 Running hook script..."
echo ""

echo "$MOCK_INPUT" | bash home/dot_local/bin/executable_archive-claude-conversation.sh

echo ""
echo "✅ Hook test completed!"
echo ""
echo "📁 Check archives in: ~/.claude/conversation-archive/chezmoi/"

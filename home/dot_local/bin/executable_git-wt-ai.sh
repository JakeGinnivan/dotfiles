#!/usr/bin/env bash
# Create a new AI worktree as a sibling directory with incremented number suffix

set -euo pipefail

# Get current directory name
current_dir=$(basename "$PWD")
parent_dir=$(dirname "$PWD")

# Strip numeric suffix if present (e.g., myrepo-1 -> myrepo)
base_name=$(echo "$current_dir" | sed -E 's/-[0-9]+$//')

# Find the next available number
next_num=1
while [[ -d "$parent_dir/$base_name-$next_num" ]]; do
    ((next_num++))
done

new_dir="$parent_dir/$base_name-$next_num"
branch_name="${1:-ai-$(date +%Y%m%d-%H%M%S)}"

# Determine the main branch (try origin/main, fall back to origin/master, then main)
if git rev-parse --verify origin/main >/dev/null 2>&1; then
    base_branch="origin/main"
elif git rev-parse --verify origin/master >/dev/null 2>&1; then
    base_branch="origin/master"
else
    base_branch="main"
fi

echo "Fetching latest changes from origin..."
git fetch origin

echo ""
echo "Creating AI worktree:"
echo "  Directory: $new_dir"
echo "  Branch: $branch_name"
echo "  Base: $base_branch"
echo ""

# Create the worktree based on the main branch
git worktree add "$new_dir" -b "$branch_name" "$base_branch"

echo ""
echo "✓ Worktree created successfully!"
echo ""
echo "To switch to it:"
echo "  cd $new_dir"

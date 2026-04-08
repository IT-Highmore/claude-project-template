#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: bash example/init-unix.sh <frontend-path> <backend-path> [global-path]" >&2
  exit 1
fi

frontend_path="$(cd "$1" && pwd)"
backend_path="$(cd "$2" && pwd)"
global_path="${3:-$HOME/.claude-global}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template_root="$script_dir"

require_directory() {
  local target_path="$1"
  if [[ ! -d "$target_path" ]]; then
    echo "Directory not found: $target_path" >&2
    exit 1
  fi
}

ensure_line() {
  local line_value="$1"
  local file_path="$2"
  touch "$file_path"
  if ! grep -Fxq "$line_value" "$file_path"; then
    printf '%s\n' "$line_value" >> "$file_path"
  fi
}

replace_with_symlink() {
  local target_path="$1"
  local link_path="$2"

  if [[ -L "$link_path" || -f "$link_path" ]]; then
    rm -f "$link_path"
  elif [[ -d "$link_path" ]]; then
    if [[ -n "$(ls -A "$link_path")" ]]; then
      echo "Path exists and is not empty: $link_path" >&2
      exit 1
    fi
    rmdir "$link_path"
  fi

  ln -s "$target_path" "$link_path"
}

copy_project_claude() {
  local source_dir="$1"
  local destination_dir="$2"

  mkdir -p "$destination_dir/.claude/docs" "$destination_dir/.claude/rules" "$destination_dir/.claude/skills"
  cp -R "$source_dir/.claude/docs/." "$destination_dir/.claude/docs/"
  cp -R "$source_dir/.claude/skills/." "$destination_dir/.claude/skills/"
  cp "$source_dir/.claude/LINKS.md" "$destination_dir/.claude/LINKS.md"
}

require_directory "$frontend_path"
require_directory "$backend_path"
require_directory "$template_root/.claude-global"
require_directory "$template_root/frontend/.claude"
require_directory "$template_root/backend/.claude"

mkdir -p "$global_path"
cp -R "$template_root/.claude-global/." "$global_path/"

copy_project_claude "$template_root/frontend" "$frontend_path"
copy_project_claude "$template_root/backend" "$backend_path"

cp "$template_root/frontend/.claude/rules/frontend.md" "$frontend_path/.claude/rules/frontend.md"
cp "$template_root/backend/.claude/rules/backend.md" "$backend_path/.claude/rules/backend.md"

replace_with_symlink "$global_path/CLAUDE.md" "$frontend_path/.claude/CLAUDE.md"
replace_with_symlink "$global_path/CLAUDE.md" "$backend_path/.claude/CLAUDE.md"
replace_with_symlink "$global_path/rules" "$frontend_path/.claude/rules/global"
replace_with_symlink "$global_path/rules" "$backend_path/.claude/rules/global"
replace_with_symlink "$backend_path" "$frontend_path/backend"
replace_with_symlink "$frontend_path" "$backend_path/frontend"

ensure_line ".claude/CLAUDE.md" "$frontend_path/.gitignore"
ensure_line ".claude/rules/global/" "$frontend_path/.gitignore"
ensure_line "backend/" "$frontend_path/.gitignore"
ensure_line ".claude/CLAUDE.md" "$backend_path/.gitignore"
ensure_line ".claude/rules/global/" "$backend_path/.gitignore"
ensure_line "frontend/" "$backend_path/.gitignore"

printf 'Initialized Claude template.\n'
printf 'Frontend: %s\n' "$frontend_path"
printf 'Backend:  %s\n' "$backend_path"
printf 'Global:   %s\n' "$global_path"

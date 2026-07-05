#!/usr/bin/env bash
# Run `cargo fmt` when a Rust source or Cargo file is edited.
set -u

if ! command -v jq >/dev/null 2>&1; then
  echo '{"systemMessage": "cargo-fmt hook skipped: jq not found"}'
  exit 0
fi

file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0

case "$file" in
  *.rs | */Cargo.toml | Cargo.toml | */Cargo.lock | Cargo.lock) ;;
  *) exit 0 ;;
esac

if ! command -v cargo >/dev/null 2>&1; then
  echo '{"systemMessage": "cargo-fmt hook skipped: cargo not found"}'
  exit 0
fi

# Locate the enclosing package manifest from the edited file's directory.
manifest=$(cd "$(dirname "$file")" 2>/dev/null &&
  cargo locate-project --message-format plain 2>/dev/null) || exit 0
[ -z "$manifest" ] && exit 0

# Ignore failures: code may be mid-refactor and not parse yet.
cargo fmt --manifest-path "$manifest" 2>/dev/null || true

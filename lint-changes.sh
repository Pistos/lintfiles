#!/usr/bin/env zsh
#
# lint-changes — Lint changed files, report only new issues.
#
# Compares linter output on current file versions against a base git ref,
# and reports only issues that are new (not present in the base version).
#
# Usage: lint-changes [options] [BASE_REF]
#
# Options:
#   -a, --all     Show all issues in changed files, not just new ones
#   -h, --help    Show this help message
#
# BASE_REF defaults to HEAD (compare working tree against last commit).
# Can be any git ref: branch name, commit hash, HEAD~3, etc.
#
# Supported linters (all applicable linters run, auto-detected from CWD):
#   rubocop   — detected via .rubocop.yml
#   eslint    — detected via .eslintrc.* or eslint.config.*
#   stylelint — detected via .stylelintrc* or stylelint.config.*
#
# If no eslint config is found in the project, falls back to eslint.config.js
# from the script's own directory.
#
# Works from any subdirectory (scopes to that subtree), and can live
# anywhere on PATH (e.g. ~/bin) — always operates on CWD.
#

set -euo pipefail

script_dir="${0:A:h}"
eslint_extra_args=()
show_all=false
base_ref="HEAD"

# ── Parse arguments ───────────────────────────────────────────────

for arg in "$@"; do
  case "$arg" in
    -a|--all)
      show_all=true
      ;;
    -h|--help)
      cat <<'HELP'
Usage: lint-changes [options] [BASE_REF]

Lint changed files, reporting only new issues.

Options:
  -a, --all   Show all issues in changed files, not just new ones
  -h, --help  Show this help message

BASE_REF defaults to HEAD. Can be any git ref (branch, tag, SHA, HEAD~3).
HELP
      exit 0
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
    *)
      base_ref="$arg"
      ;;
  esac
done

# ── Linter detection ─────────────────────────────────────────────

# Search CWD and ancestor directories (up to the repo root) for linter configs.
# Populates the `detected_linters` array with all linters found.
detect_linters() {
  local repo_root dir
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  dir=$(pwd)

  local found_eslint=false
  local found_rubocop=false
  local found_stylelint=false

  while true; do
    if ! $found_eslint; then
      if [[ -f "$dir/.eslintrc.js" ]] || [[ -f "$dir/.eslintrc.json" ]] || \
         [[ -f "$dir/.eslintrc.yml" ]] || [[ -f "$dir/.eslintrc.yaml" ]] || \
         [[ -f "$dir/.eslintrc.cjs" ]] || \
         [[ -f "$dir/eslint.config.js" ]] || [[ -f "$dir/eslint.config.mjs" ]] || \
         [[ -f "$dir/eslint.config.ts" ]] || [[ -f "$dir/eslint.config.cjs" ]]; then
        found_eslint=true
      fi
    fi
    if ! $found_rubocop && [[ -f "$dir/.rubocop.yml" ]]; then
      found_rubocop=true
    fi
    if ! $found_stylelint; then
      if [[ -f "$dir/.stylelintrc" ]] || [[ -f "$dir/.stylelintrc.js" ]] || \
         [[ -f "$dir/.stylelintrc.cjs" ]] || [[ -f "$dir/.stylelintrc.mjs" ]] || \
         [[ -f "$dir/.stylelintrc.json" ]] || [[ -f "$dir/.stylelintrc.yml" ]] || \
         [[ -f "$dir/.stylelintrc.yaml" ]] || [[ -f "$dir/.stylelintrc.ts" ]] || \
         [[ -f "$dir/stylelint.config.js" ]] || [[ -f "$dir/stylelint.config.cjs" ]] || \
         [[ -f "$dir/stylelint.config.mjs" ]] || [[ -f "$dir/stylelint.config.ts" ]]; then
        found_stylelint=true
      fi
    fi

    # Stop at the repo root (or filesystem root if not in a repo).
    if [[ "$dir" == "$repo_root" ]] || [[ "$dir" == "/" ]]; then
      break
    fi

    dir=$(dirname "$dir")
  done

  # Fallback: use eslint config from the script's own directory.
  if ! $found_eslint && [[ -f "$script_dir/eslint.config.js" ]]; then
    eslint_extra_args=(--config "$script_dir/eslint.config.js")
    found_eslint=true
  fi

  detected_linters=()
  if $found_eslint; then detected_linters+=(eslint); fi
  if $found_rubocop; then detected_linters+=(rubocop); fi
  if $found_stylelint; then detected_linters+=(stylelint); fi
}

# ── Linter operations ────────────────────────────────────────────

# Run linter on a file in the working tree.
lint_file() {
  local file="$1"
  case "$linter" in
    rubocop)
      rubocop --format emacs --force-exclusion "$file" 2>/dev/null || true
      ;;
    eslint)
      npx eslint "${eslint_extra_args[@]}" --format compact "$file" 2>/dev/null || true
      ;;
    stylelint)
      npx stylelint --formatter compact "$file" 2>/dev/null || true
      ;;
  esac
}

# Run linter on stdin, using the given filename for config resolution.
lint_stdin() {
  local file="$1"
  case "$linter" in
    rubocop)
      rubocop --format emacs --force-exclusion --stdin "$file" 2>/dev/null || true
      ;;
    eslint)
      npx eslint "${eslint_extra_args[@]}" --format compact --stdin --stdin-filename "$file" 2>/dev/null || true
      ;;
    stylelint)
      npx stylelint --formatter compact --stdin-filename "$file" 2>/dev/null || true
      ;;
  esac
}

# Strip file path and line/column numbers from linter output,
# leaving only the issue description for comparison.
normalize() {
  case "$linter" in
    rubocop)
      # Input:  /path/file.rb:10:5: C: Cop/Name: message
      # Output: C: Cop/Name: message
      grep -E '^.+:[0-9]+:[0-9]+: ' | sed -E 's/^[^:]+:[0-9]+:[0-9]+: //' || true
      ;;
    eslint)
      # Input:  /path/file.js: line 10, col 5, Error - message (rule)
      # Output: Error - message (rule)
      grep -E '^.+: line [0-9]+, col [0-9]+, ' | sed -E 's/^.+: line [0-9]+, col [0-9]+, //' || true
      ;;
    stylelint)
      # Input:  /path/file.css: line 10, col 5, error - message (rule)
      # Output: error - message (rule)
      grep -E '^.+: line [0-9]+, col [0-9]+, ' | sed -E 's/^.+: line [0-9]+, col [0-9]+, //' || true
      ;;
  esac
}

# Check if a file's extension is relevant for the detected linter.
is_relevant_file() {
  local file="$1"
  case "$linter" in
    rubocop)
      [[ "$file" =~ \.(rb|rake|gemspec)$ ]] || \
        [[ "$(basename "$file")" =~ ^(Gemfile|Rakefile)$ ]]
      ;;
    eslint)
      [[ "$file" =~ \.(js|jsx|ts|tsx|mjs|cjs|vue)$ ]]
      ;;
    stylelint)
      [[ "$file" =~ \.(css|scss|sass|less|sss)$ ]]
      ;;
  esac
}

# ── Main ──────────────────────────────────────────────────────────

detect_linters
if [[ ${#detected_linters[@]} -eq 0 ]]; then
  echo "No supported linter configuration found." >&2
  exit 1
fi

# The git prefix is the CWD's path relative to the repo root (e.g. "lib/").
# git show/cat-file need repo-root-relative paths, while the linter and file
# list use CWD-relative paths, so this bridges the two.
git_prefix=$(git rev-parse --show-prefix 2>/dev/null)

# Gather all changed files once; each linter filters for its relevant extensions.
all_changed_files=()
while IFS= read -r file; do
  if [[ -n "$file" ]]; then
    all_changed_files+=("$file")
  fi
done < <(
  {
    git diff --name-only --relative --diff-filter=d "$base_ref" -- . 2>/dev/null
    git ls-files --others --exclude-standard -- . 2>/dev/null
  } | sort -u
)

echo "Linters: ${detected_linters[*]}"
echo "Base: $base_ref"
echo ""

total_new=0
files_with_issues=0

for linter in "${detected_linters[@]}"; do
  changed_files=()
  for file in "${all_changed_files[@]}"; do
    if is_relevant_file "$file"; then
      changed_files+=("$file")
    fi
  done

  if [[ ${#changed_files[@]} -eq 0 ]]; then
    continue
  fi

  echo "── $linter (${#changed_files[@]} file(s)) ──"
  if [[ "$linter" == "eslint" ]] && [[ ${#eslint_extra_args[@]} -gt 0 ]]; then
    echo "Config: ${eslint_extra_args[-1]} (fallback)"
  fi
  echo ""

  for file in "${changed_files[@]}"; do
    new_raw=$(lint_file "$file")

    # No issues in the current version — nothing to report.
    if [[ -z "$new_raw" ]]; then
      continue
    fi

    # In --all mode, show every issue without diffing.
    if $show_all; then
      echo "=== $file ==="
      echo "$new_raw"
      echo ""
      count=$(echo "$new_raw" | wc -l)
      total_new=$((total_new + count))
      files_with_issues=$((files_with_issues + 1))
      continue
    fi

    # Lint the old version for comparison.
    # git show needs repo-root-relative paths; the linter gets CWD-relative paths.
    if git cat-file -e "${base_ref}:${git_prefix}${file}" 2>/dev/null; then
      old_raw=$(git show "${base_ref}:${git_prefix}${file}" | lint_stdin "$file")
    else
      # File is new — all issues are new.
      old_raw=""
    fi

    # If no old issues exist, everything current is new.
    if [[ -z "$old_raw" ]]; then
      echo "=== $file ==="
      echo "$new_raw"
      echo ""
      count=$(echo "$new_raw" | wc -l)
      total_new=$((total_new + count))
      files_with_issues=$((files_with_issues + 1))
      continue
    fi

    # Normalize both outputs and find issues only in the new version.
    # LC_ALL=C ensures consistent sort/comm behavior across locales.
    new_norm=$(echo "$new_raw" | normalize | LC_ALL=C sort)
    old_norm=$(echo "$old_raw" | normalize | LC_ALL=C sort)
    new_only=$(LC_ALL=C comm -13 <(echo "$old_norm") <(echo "$new_norm") | grep -v '^$' || true)

    if [[ -n "$new_only" ]]; then
      echo "=== $file ==="
      while IFS= read -r norm_line; do
        [[ -z "$norm_line" ]] && continue
        matched=$(grep -F -- "$norm_line" <<< "$new_raw" | head -1)
        if [[ -n "$matched" ]]; then
          echo "$matched"
          total_new=$((total_new + 1))
        fi
      done <<< "$new_only"
      echo ""
      files_with_issues=$((files_with_issues + 1))
    fi
  done
done

echo "---"
if [[ $total_new -eq 0 ]]; then
  echo "No new issues found."
else
  echo "New issues: $total_new (in $files_with_issues file(s))"
  exit 1
fi

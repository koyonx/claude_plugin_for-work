#!/usr/bin/env bash
# develop / main の HEAD が現在のブランチにマージされているか判定する。
# 使い方:
#   check-merge-status.sh           ローカル refs のみを確認
#   check-merge-status.sh --fetch   先に `git fetch` してから remote-tracking refs も確認
#   check-merge-status.sh --quiet   全ブランチがマージ済みなら何も出力しない（hook 用）

set -u

mode_fetch=0
mode_quiet=0
for arg in "$@"; do
  case "$arg" in
    --fetch) mode_fetch=1 ;;
    --quiet) mode_quiet=1 ;;
    *) ;;
  esac
done

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

current=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -z "$current" ] || [ "$current" = "HEAD" ]; then
  exit 0
fi

if [ "$mode_fetch" -eq 1 ]; then
  git fetch --quiet --no-tags origin develop main 2>/dev/null || true
fi

# 判定対象の候補。ローカル ref を優先し、無ければ remote-tracking ref にフォールバック。
targets=()
for name in develop main; do
  if [ "$current" = "$name" ]; then
    continue
  fi
  if git rev-parse --verify --quiet "refs/heads/${name}" >/dev/null 2>&1; then
    targets+=("${name}|refs/heads/${name}")
  elif git rev-parse --verify --quiet "refs/remotes/origin/${name}" >/dev/null 2>&1; then
    targets+=("${name}|refs/remotes/origin/${name}")
  fi
done

if [ ${#targets[@]} -eq 0 ]; then
  exit 0
fi

lines=()
all_merged=1
for entry in "${targets[@]}"; do
  label="${entry%%|*}"
  ref="${entry##*|}"
  short_ref="${ref#refs/heads/}"
  short_ref="${short_ref#refs/remotes/}"

  if git merge-base --is-ancestor "$ref" HEAD 2>/dev/null; then
    lines+=("  [MERGED]     ${label} (${short_ref}) は ${current} にマージ済み")
  else
    all_merged=0
    behind=$(git rev-list --count "HEAD..${ref}" 2>/dev/null || echo "?")
    lines+=("  [NOT MERGED] ${label} (${short_ref}) は ${current} に未マージ — ${current} は ${behind} コミット遅れ")
  fi
done

if [ "$mode_quiet" -eq 1 ] && [ "$all_merged" -eq 1 ]; then
  exit 0
fi

echo "=== branch merge status (current: ${current}) ==="
for line in "${lines[@]}"; do
  echo "$line"
done

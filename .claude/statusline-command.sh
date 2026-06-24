#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
five_hr_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ── Helpers ────────────────────────────────────────────────────────────────

make_bar() {
  local pct="$1" width="$2"
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar="" bar_color=""
  if [ "$pct" -ge 80 ]; then bar_color="\033[31m"
  elif [ "$pct" -ge 50 ]; then bar_color="\033[33m"
  else bar_color="\033[32m"
  fi
  [ "$filled" -gt 0 ] && printf -v f "%${filled}s" && bar="${f// /▓}"
  [ "$empty"  -gt 0 ] && printf -v e "%${empty}s"  && bar="${bar}${e// /░}"
  printf "%b" "${bar_color}${bar}\033[0m"
}

# ── Path ───────────────────────────────────────────────────────────────────
short_cwd="${cwd/#$HOME/\~}"
if [ "${#short_cwd}" -gt 22 ]; then
  short_cwd="…${short_cwd: -21}"
fi
parts="\033[34m${short_cwd}\033[0m"

# ── Git branch ─────────────────────────────────────────────────────────────
branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  if [ "${#branch}" -gt 18 ]; then branch="…${branch: -17}"; fi
  parts="$parts \033[33m(${branch})\033[0m"
fi

# ── Model ──────────────────────────────────────────────────────────────────
if [ -n "$model" ]; then
  parts="$parts  \033[36m$model\033[0m"
fi

# ── Session context bar (tokens only, no out/cache) ────────────────────────
if [ -n "$used_pct" ]; then
  printf_pct=$(printf "%.0f" "$used_pct")

  token_str=""
  if [ -n "$total_input" ] && [ -n "$ctx_size" ] && \
     [ "$total_input" != "null" ] && [ "$ctx_size" != "null" ]; then
    used_k=$(awk "BEGIN {printf \"%.1f\", $total_input/1000}")
    size_k=$(awk "BEGIN {printf \"%.0f\", $ctx_size/1000}")
    token_str=" ${used_k}k/${size_k}k"
  fi

  ctx_bar=$(make_bar "$printf_pct" 8)
  parts="$parts  ctx:${ctx_bar} ${printf_pct}%${token_str}"
fi

# ── 5-hour rate limit bar + countdown ─────────────────────────────────────
STAMP_FILE="${XDG_RUNTIME_DIR:-$HOME/.cache}/claude_5h_start"

if [ -n "$five_hr_pct" ] && [ "$five_hr_pct" != "null" ]; then
  pct5=$(printf "%.0f" "$five_hr_pct")

  # Stamp management: create on first use, reset when pct drops back near 0
  if [ -f "$STAMP_FILE" ]; then
    # If usage dropped to ≤2 % the window likely reset — refresh the stamp
    if [ "$pct5" -le 2 ]; then
      date +%s > "$STAMP_FILE"
    fi
  else
    date +%s > "$STAMP_FILE"
  fi

  start_ts=$(cat "$STAMP_FILE")
  now_ts=$(date +%s)
  elapsed=$(( now_ts - start_ts ))
  window=18000   # 5 hours in seconds
  remaining=$(( window - elapsed ))
  if [ "$remaining" -lt 0 ]; then remaining=0; fi

  rem_h=$(( remaining / 3600 ))
  rem_m=$(( (remaining % 3600) / 60 ))
  countdown=$(printf "%dh%02dm" "$rem_h" "$rem_m")

  bar5=$(make_bar "$pct5" 6)
  parts="$parts  5h:${bar5} ${pct5}% (${countdown})"
fi

# ── 7-day rate limit bar ───────────────────────────────────────────────────
if [ -n "$seven_day_pct" ] && [ "$seven_day_pct" != "null" ]; then
  pct7=$(printf "%.0f" "$seven_day_pct")
  bar7=$(make_bar "$pct7" 6)
  parts="$parts  7d:${bar7} ${pct7}%"
fi

printf "%b" "$parts"

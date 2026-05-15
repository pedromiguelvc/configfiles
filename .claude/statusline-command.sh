#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
five_hr_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ── Helpers ────────────────────────────────────────────────────────────────

# Build a color-coded progress bar: make_bar <pct_int> <width>
make_bar() {
  local pct="$1" width="$2"
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  if [ "$pct" -ge 80 ]; then bar_color="\033[31m"
  elif [ "$pct" -ge 50 ]; then bar_color="\033[33m"
  else bar_color="\033[32m"
  fi
  [ "$filled" -gt 0 ] && printf -v f "%${filled}s" && bar="${f// /▓}"
  [ "$empty"  -gt 0 ] && printf -v e "%${empty}s"  && bar="${bar}${e// /░}"
  printf "%b" "${bar_color}${bar}\033[0m"
}

# ── Path: replace HOME, keep last 2 segments, truncate to 22 chars ─────────
short_cwd="${cwd/#$HOME/\~}"
# Keep only the last 2 path components (e.g. ~/projects/myrepo)
if [ "${#short_cwd}" -gt 22 ]; then
  short_cwd="…${short_cwd: -21}"
fi

parts="\033[34m${short_cwd}\033[0m"

# ── Git branch: truncate to 18 chars ───────────────────────────────────────
branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  if [ "${#branch}" -gt 18 ]; then
    branch="…${branch: -17}"
  fi
  parts="$parts \033[33m(${branch})\033[0m"
fi

# ── Model ──────────────────────────────────────────────────────────────────
if [ -n "$model" ]; then
  parts="$parts  \033[36m$model\033[0m"
fi

# ── Session context bar ────────────────────────────────────────────────────
if [ -n "$used_pct" ]; then
  printf_pct=$(printf "%.0f" "$used_pct")

  token_str=""
  if [ -n "$total_input" ] && [ -n "$ctx_size" ] && \
     [ "$total_input" != "null" ] && [ "$ctx_size" != "null" ]; then
    used_k=$(awk "BEGIN {printf \"%.1f\", $total_input/1000}")
    size_k=$(awk "BEGIN {printf \"%.0f\", $ctx_size/1000}")
    token_str=" ${used_k}k/${size_k}k"
  fi

  out_str=""
  if [ -n "$total_output" ] && [ "$total_output" != "null" ] && \
     [ "$total_output" != "0" ]; then
    out_k=$(awk "BEGIN {printf \"%.1f\", $total_output/1000}")
    out_str=" out:${out_k}k"
  fi

  cache_str=""
  if [ -n "$cache_read" ] && [ "$cache_read" != "null" ] && \
     [ "$cache_read" != "0" ]; then
    cr_k=$(awk "BEGIN {printf \"%.1f\", $cache_read/1000}")
    cache_str=" cr:${cr_k}k"
  fi
  if [ -n "$cache_write" ] && [ "$cache_write" != "null" ] && \
     [ "$cache_write" != "0" ]; then
    cw_k=$(awk "BEGIN {printf \"%.1f\", $cache_write/1000}")
    cache_str="${cache_str} cw:${cw_k}k"
  fi

  ctx_bar=$(make_bar "$printf_pct" 8)
  parts="$parts  ctx:${ctx_bar} ${printf_pct}%${token_str}${out_str}${cache_str}"
fi

# ── Rate limit bars ────────────────────────────────────────────────────────
if [ -n "$five_hr_pct" ] && [ "$five_hr_pct" != "null" ]; then
  pct5=$(printf "%.0f" "$five_hr_pct")
  bar5=$(make_bar "$pct5" 6)
  parts="$parts  5h:${bar5} ${pct5}%"
fi

if [ -n "$seven_day_pct" ] && [ "$seven_day_pct" != "null" ]; then
  pct7=$(printf "%.0f" "$seven_day_pct")
  bar7=$(make_bar "$pct7" 6)
  parts="$parts  7d:${bar7} ${pct7}%"
fi

printf "%b" "$parts"

#!/usr/bin/env bash
# Claude Code status line: model, effort level, context usage, and rate limits.
# Receives the session JSON on stdin (same payload as hooks).
#
# Percentages are colored by how much of the budget is used:
#   used < 60%       -> green
#   60% <= used < 80% -> yellow
#   used >= 80%      -> red
# Rate limit windows also show their reset time in JST.

input=$(cat)

# Pull the raw values as tab-separated fields (empty string when absent).
IFS=$'\t' read -r model effort used limit ctx_pct \
  five_pct five_reset seven_pct seven_reset <<EOF
$(printf '%s' "$input" | jq -r '
  def num(f): (f) | if . == null then "" else (.|floor|tostring) end;
  [ (.model.display_name // "?"),
    (.effort.level // "default"),
    ((.context_window.total_input_tokens // 0) | floor | tostring),
    ((.context_window.context_window_size // 200000) | floor | tostring),
    num(.context_window.used_percentage),
    num(.rate_limits.five_hour.used_percentage),
    ((.rate_limits.five_hour.resets_at) // "" | tostring),
    num(.rate_limits.seven_day.used_percentage),
    ((.rate_limits.seven_day.resets_at) // "" | tostring)
  ] | @tsv')
EOF

green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[31m'
reset=$'\033[0m'

# Color code for a used-percentage: green < 60 <= yellow < 80 <= red.
color_for() {
  local used=${1:-0}
  if [ "$used" -lt 60 ]; then
    printf '%s' "$green"
  elif [ "$used" -lt 80 ]; then
    printf '%s' "$yellow"
  else
    printf '%s' "$red"
  fi
}

# Human-readable token count (e.g. 82000 -> 82k).
kfmt() {
  local n=${1:-0}
  if [ "$n" -ge 1000 ]; then printf '%dk' "$((n / 1000))"; else printf '%d' "$n"; fi
}

# Unix epoch -> JST clock time. BSD date (macOS) uses -r for epoch input.
jst() { TZ='Asia/Tokyo' date -r "$1" "$2" 2>/dev/null; }

sep=" │ "

# The payload does not flag the 1M context variant in the model name, so
# derive it from the context window size.
[ "${limit:-0}" -ge 1000000 ] && model="$model[1m]"

out="🤖 $model"
out+="${sep}⚡ $effort"
out+="${sep}🧠 $(kfmt "$used")/$(kfmt "$limit") $(color_for "$ctx_pct")${ctx_pct}%${reset}"

if [ -n "$five_pct" ]; then
  seg="⏱ 5h $(color_for "$five_pct")${five_pct}%${reset}"
  [ -n "$five_reset" ] && seg+=" ↻$(jst "$five_reset" '+%H:%M')"
  out+="${sep}${seg}"
fi

if [ -n "$seven_pct" ]; then
  seg="📅 7d $(color_for "$seven_pct")${seven_pct}%${reset}"
  [ -n "$seven_reset" ] && seg+=" ↻$(jst "$seven_reset" '+%m/%d %H:%M')"
  out+="${sep}${seg}"
fi

printf '%s' "$out"

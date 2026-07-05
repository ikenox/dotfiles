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

# Pull the raw values, separated by a non-whitespace control char (US, 0x1f).
# A whitespace separator (like tab) would let `read` collapse empty fields and
# shift every following value left when an optional field is absent.
IFS=$'\x1f' read -r model effort used limit ctx_pct \
  five_pct five_reset seven_pct seven_reset <<EOF
$(printf '%s' "$input" | jq -r '
  def num(f): (f) | if . == null then "" else (.|floor|tostring) end;
  [ (.model.display_name // "?"),
    (.effort.level // "default"),
    ((.context_window.total_input_tokens // 0) | floor | tostring),
    ((.context_window.context_window_size // 200000) | floor | tostring),
    ((.context_window.used_percentage // 0) | floor | tostring),
    num(.rate_limits.five_hour.used_percentage),
    ((.rate_limits.five_hour.resets_at) // "" | tostring),
    num(.rate_limits.seven_day.used_percentage),
    ((.rate_limits.seven_day.resets_at) // "" | tostring)
  ] | join("")')
EOF

green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[31m'
cyan=$'\033[36m'
magenta=$'\033[35m'
bold_magenta=$'\033[1;35m'
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

# Color code for the effort level, by intensity.
effort_color() {
  case "$1" in
    low) printf '%s' "$cyan" ;;
    medium) printf '%s' "$green" ;;
    high) printf '%s' "$yellow" ;;
    xhigh) printf '%s' "$red" ;;
    max) printf '%s' "$magenta" ;;
    ultracode) printf '%s' "$bold_magenta" ;;
    *) printf '%s' "$reset" ;;
  esac
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
out+="${sep}⚡ $(effort_color "$effort")${effort}${reset}"
out+="${sep}🧠 $(kfmt "$used")/$(kfmt "$limit") $(color_for "$ctx_pct")${ctx_pct}%${reset}"

if [ -n "$five_pct" ]; then
  seg="⏱ 5h $(color_for "$five_pct")${five_pct}%${reset}"
  [ -n "$five_reset" ] && seg+=" →$(jst "$five_reset" '+%H:%M')"
  out+="${sep}${seg}"
fi

if [ -n "$seven_pct" ]; then
  seg="📅 7d $(color_for "$seven_pct")${seven_pct}%${reset}"
  [ -n "$seven_reset" ] && seg+=" →$(jst "$seven_reset" '+%m/%d(%H:%M)')"
  out+="${sep}${seg}"
fi

# Second line: worktree, branch, and diff stats vs HEAD (git info is not in
# the payload, so query git in the session's working directory).
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
line2=""
if [ -n "$dir" ] && git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  worktree=$(basename "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)")
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ "$branch" = "HEAD" ] && branch="detached@$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"

  line2="${cyan}${worktree}${reset} ⎇ ${cyan}${branch}${reset}"

  stat=$(git -C "$dir" diff --shortstat HEAD 2>/dev/null)
  files=0 ins=0 del=0
  [[ $stat =~ ([0-9]+)\ file ]] && files=${BASH_REMATCH[1]}
  [[ $stat =~ ([0-9]+)\ insertion ]] && ins=${BASH_REMATCH[1]}
  [[ $stat =~ ([0-9]+)\ deletion ]] && del=${BASH_REMATCH[1]}
  if [ "$files" -gt 0 ]; then
    line2+="${sep}📝 ${files}f ${green}+${ins}${reset} ${red}-${del}${reset}"
  else
    line2+="${sep}${green}✓ clean${reset}"
  fi
fi

if [ -n "$line2" ]; then
  printf '%s\n%s' "$line2" "$out"
else
  printf '%s' "$out"
fi

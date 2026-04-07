#!/bin/bash
cat > /dev/null

NOTIFICATION_TYPE="${1:-general}"

case "$NOTIFICATION_TYPE" in
    "stop")
        SOUND_MAC="/System/Library/Sounds/Glass.aiff"
        MESSAGE="タスク完了"
        ;;
    "permission")
        SOUND_MAC="/System/Library/Sounds/Purr.aiff"
        MESSAGE="許可待ち"
        ;;
    *)
        SOUND_MAC="/System/Library/Sounds/Blow.aiff"
        MESSAGE="入力待ち"
        ;;
esac

afplay "$SOUND_MAC" 2>/dev/null &

if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier \
        -title "Claude Code" \
        -message "$MESSAGE" \
        -activate "com.mitchellh.ghostty" \
        >/dev/null 2>&1 &
else
    osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\"" 2>/dev/null &
fi

exit 0

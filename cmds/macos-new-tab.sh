#!/usr/bin/env bash

###
# Opens a new terminal in macos to run a command using applescript
###

DIR_NAME="$1"
COMMAND="$2"

osascript << EOF
tell application "Terminal"
    activate
end tell
tell application "System Events"
    keystroke "t" using command down
    set textToType to "cd ${DIR_NAME} && ${COMMAND}\n"
    keystroke textToType
end tell
EOF
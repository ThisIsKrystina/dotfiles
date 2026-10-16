#!/bin/bash

# Toggle time announcement on computer. Turn off during non-work hours. Hook into launchd, automator, shortcuts, etc. 

announce_time() {
local mode=${1:-"on"}
# Read the flags
while [[ $# -gt 0 ]]; do
case "$1" in 
--on) mode="on" ;;
--off) mode="off" ;;
*)
echo "Unknown option: $1" >&2
exit 1
;;
esac
shift
done

# Check and run command

if [[ ${mode} == "on" ]]; then
local STATE="YES"
else 
local STATE="NO"
fi
MSG="Time check is ${mode}!"


plutil -replace TimeAnnouncementPrefs.TimeAnnouncementsEnabled -bool "${STATE}" ~/Library/Preferences/com.apple.speech.synthesis.general.prefs.plist

echo "${MSG}"

}



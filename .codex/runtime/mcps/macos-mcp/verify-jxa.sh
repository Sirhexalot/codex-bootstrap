#!/usr/bin/env bash
set -euo pipefail

commands=(
  '/usr/bin/osascript -l JavaScript -e '\''Application("Contacts").people().length'\'''
  '/usr/bin/osascript -l JavaScript -e '\''Application("Calendar").calendars().length'\'''
  '/usr/bin/osascript -l JavaScript -e '\''Application("Reminders").defaultList().name()'\'''
  '/usr/bin/osascript -l JavaScript -e '\''Application("Mail").inbox().messages().length'\'''
  '/usr/bin/osascript -l JavaScript -e '\''Application("Notes").notes().length'\'''
)

for cmd in "${commands[@]}"; do
  echo
  echo "\$ $cmd"
  eval "$cmd"
done

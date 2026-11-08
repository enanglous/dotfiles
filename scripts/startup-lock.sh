#!/bin/bash

FLAG_FILE="/tmp/.hyprland_boot_locked"

# Check if the flag file already exists
if [ -f "$FLAG_FILE" ]; then
  # If it exists, we have already locked the screen this boot cycle.
  # Exit silently without locking.
  exit 0
fi

# If the file doesn't exist, this is the first boot.
# Create the flag file so this block doesn't run again until the next reboot.
touch "$FLAG_FILE"

# Wait for the qs daemon to actually bind to the session
while ! pgrep -x qs >/dev/null; do
  sleep 0.5
done

# Give it 1 extra second to load the lock listener
sleep 2

# Lock the specific session
caelestia shell lock lock

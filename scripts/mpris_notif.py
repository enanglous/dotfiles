#!/usr/bin/env python3

import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib
from subprocess import Popen
import os

player = Playerctl.Player()

def on_track_change(player, e):
    # Get metadata
    metadata = player.props.metadata
    
    # Extract track info
    artist = player.get_artist() or 'Unknown Artist'
    title = player.get_title() or 'Unknown Title'
    album = metadata['xesam:album'] if metadata else 'Unknown Album'
    
    # Extract album art URL if available
    album_art_url = None
    if metadata['mpris:artUrl']:
        album_art_url = metadata['mpris:artUrl']
        # Remove 'file://' prefix if present
        if album_art_url.startswith('file://'):
            album_art_url = album_art_url[7:]
    
    # Build dunstify command with proper formatting
    cmd = [
        'dunstify',
        '-a', 'Music Player',           # Application name
        '-t', '5000',                   # Timeout in ms (5 seconds)
        '-u', 'low',                    # Urgency level (low, normal, critical)
        '-r', '991049',                 # Replace ID (to avoid multiple notifications)
        f'{artist} - {title}',          # Title/Summary
        f'Album: {album}'               # Body/Message
    ]
    
    # Add album art if available and file exists
    if album_art_url and os.path.exists(album_art_url):
        cmd.extend(['-I', album_art_url])
    
    # Add progress bar if duration is available (optional)
    if metadata['mpris:length']:
        length_ns = metadata['mpris:length']
        # Convert nanoseconds to seconds
        length_seconds = length_ns / 1e9
        # Get current position if available
        try:
            position = player.get_position()
            if position and length_seconds > 0:
                progress = (position / length_seconds) * 100
                cmd.extend(['-h', f'int:value:{progress:.0f}'])
        except:
            pass  # Skip progress bar if position not available
    
    # Send notification
    Popen(cmd)

player.connect('metadata', on_track_change)
GLib.MainLoop().run()

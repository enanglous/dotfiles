#!/bin/bash

# Check if song ID is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <song-id>"
    exit 1
fi

SONG_ID="$1"
API_URL="https://wolf.qqdl.site/track/?id=${SONG_ID}&quality=LOSSLESS"
TEMP_JSON="temp_metadata.json"
ALBUM_ART_FILE="temp_album_art.jpg"

# Function to cleanup temporary files
cleanup() {
    rm -f "$TEMP_JSON" "temp_music.flac" "$ALBUM_ART_FILE" "temp_vars.txt"
}

# Set trap to cleanup on exit
trap cleanup EXIT

echo "Fetching metadata for song ID: $SONG_ID"

# Get the JSON response
curl -s -o "$TEMP_JSON" "$API_URL"

# Check if curl was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch metadata from API"
    exit 1
fi

# Check if the response is an array or object
JSON_TYPE=$(jq -r 'type' "$TEMP_JSON")

if [ "$JSON_TYPE" = "array" ]; then
    echo "JSON is an array"
    # Extract from array structure
    DOWNLOAD_URL=$(jq -r '.[2].OriginalTrackUrl' "$TEMP_JSON")
    TITLE=$(jq -r '.[0].title' "$TEMP_JSON")
    ARTIST=$(jq -r '.[0].artist.name' "$TEMP_JSON")
    ALBUM=$(jq -r '.[0].album.title' "$TEMP_JSON")
    TRACK_NUMBER=$(jq -r '.[0].trackNumber' "$TEMP_JSON")
    YEAR=$(jq -r '.[0].streamStartDate' "$TEMP_JSON" | cut -d'-' -f1)
    GENRE=$(jq -r '.[0].copyright' "$TEMP_JSON")
    BPM=$(jq -r '.[0].bpm' "$TEMP_JSON")
    ISRC=$(jq -r '.[0].isrc' "$TEMP_JSON")
    ALBUM_ART_ID=$(jq -r '.[0].album.cover' "$TEMP_JSON")
elif [ "$JSON_TYPE" = "object" ]; then
    echo "JSON is an object"
    # Try to extract from object structure
    DOWNLOAD_URL=$(jq -r '.OriginalTrackUrl' "$TEMP_JSON")
    TITLE=$(jq -r '.title' "$TEMP_JSON")
    ARTIST=$(jq -r '.artist.name' "$TEMP_JSON")
    ALBUM=$(jq -r '.album.title' "$TEMP_JSON")
    TRACK_NUMBER=$(jq -r '.trackNumber' "$TEMP_JSON")
    YEAR=$(jq -r '.streamStartDate' "$TEMP_JSON" | cut -d'-' -f1)
    GENRE=$(jq -r '.copyright' "$TEMP_JSON")
    BPM=$(jq -r '.bpm' "$TEMP_JSON")
    ISRC=$(jq -r '.isrc' "$TEMP_JSON")
    ALBUM_ART_ID=$(jq -r '.album.cover' "$TEMP_JSON")
else
    echo "Error: Unknown JSON type: $JSON_TYPE"
    exit 1
fi

# If download URL is still not found, try alternative locations
if [ "$DOWNLOAD_URL" = "null" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo "Trying alternative URL extraction methods..."
    DOWNLOAD_URL=$(jq -r '.. | objects | .OriginalTrackUrl? // empty' "$TEMP_JSON")
fi

if [ "$DOWNLOAD_URL" = "null" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not extract download URL from JSON response"
    exit 1
fi

echo "Download URL found: $DOWNLOAD_URL"

# Download album art if available
if [ "$ALBUM_ART_ID" != "null" ] && [ -n "$ALBUM_ART_ID" ]; then
    echo "Downloading album art..."
    
    # Convert the album art ID by replacing hyphens with slashes
    FORMATTED_ART_ID=$(echo "$ALBUM_ART_ID" | sed 's/-/\//g')
    echo "Original ID: $ALBUM_ART_ID"
    echo "Formatted ID: $FORMATTED_ART_ID"
    
    # Try different album art URL patterns with the formatted ID
    ALBUM_ART_URLS=(
        "https://resources.tidal.com/images/${FORMATTED_ART_ID}/1280x1280.jpg"
        "https://wolf.qqdl.site/cover/${ALBUM_ART_ID}/1280x1280.jpg"
        "https://wolf.qqdl.site/cover/${ALBUM_ART_ID}/640x640.jpg"
        "https://wolf.qqdl.site/cover/${ALBUM_ART_ID}/320x320.jpg"
    )
    
    for ART_URL in "${ALBUM_ART_URLS[@]}"; do
        echo "Trying: $ART_URL"
        if curl -s -L -o "$ALBUM_ART_FILE" "$ART_URL" && [ -s "$ALBUM_ART_FILE" ]; then
            echo "Album art downloaded successfully"
            ALBUM_ART_DOWNLOADED=true
            break
        fi
    done
    
    if [ ! "$ALBUM_ART_DOWNLOADED" = true ]; then
        echo "Warning: Could not download album art"
        rm -f "$ALBUM_ART_FILE"
    fi
else
    echo "No album art ID found in metadata"
fi

# Sanitize filename (remove special characters)
SAFE_FILENAME=$(echo "${ARTIST:-Unknown} - ${TITLE:-Unknown}" | tr -d '/<>:"\\|?*')
OUTPUT_FILE="${SAFE_FILENAME}.flac"

echo "Downloading music file..."
curl -L -o "temp_music.flac" "$DOWNLOAD_URL"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download music file"
    exit 1
fi

echo "Adding metadata to the music file..."

# Use metaflac to add metadata (recommended for FLAC files)
if command -v metaflac >/dev/null 2>&1; then
    echo "Using metaflac for metadata..."
    metaflac --remove-all "temp_music.flac"
    
    [ "$TITLE" != "null" ] && [ -n "$TITLE" ] && metaflac --set-tag="TITLE=$TITLE" "temp_music.flac"
    [ "$ARTIST" != "null" ] && [ -n "$ARTIST" ] && metaflac --set-tag="ARTIST=$ARTIST" "temp_music.flac"
    [ "$ALBUM" != "null" ] && [ -n "$ALBUM" ] && metaflac --set-tag="ALBUM=$ALBUM" "temp_music.flac"
    [ "$TRACK_NUMBER" != "null" ] && [ -n "$TRACK_NUMBER" ] && metaflac --set-tag="TRACKNUMBER=$TRACK_NUMBER" "temp_music.flac"
    [ "$YEAR" != "null" ] && [ -n "$YEAR" ] && metaflac --set-tag="DATE=$YEAR" "temp_music.flac"
    [ "$GENRE" != "null" ] && [ -n "$GENRE" ] && metaflac --set-tag="GENRE=$GENRE" "temp_music.flac"
    [ "$BPM" != "null" ] && [ -n "$BPM" ] && metaflac --set-tag="BPM=$BPM" "temp_music.flac"
    [ "$ISRC" != "null" ] && [ -n "$ISRC" ] && metaflac --set-tag="ISRC=$ISRC" "temp_music.flac"
    
    # Add album art if downloaded
    if [ -f "$ALBUM_ART_FILE" ] && [ -s "$ALBUM_ART_FILE" ]; then
        echo "Adding album art to music file..."
        
        # Get image dimensions using identify (from ImageMagick) or file command
        if command -v identify >/dev/null 2>&1; then
            # Use ImageMagick's identify to get dimensions
            DIMENSIONS=$(identify -format "%wx%h" "$ALBUM_ART_FILE" 2>/dev/null)
        else
            # Fallback to using file command and extracting dimensions
            DIMENSIONS=$(file "$ALBUM_ART_FILE" | grep -o '[0-9]* x [0-9]*' | head -1 | tr ' ' 'x' 2>/dev/null)
        fi
        
        # If we couldn't get dimensions, use a default
        if [ -z "$DIMENSIONS" ]; then
            DIMENSIONS="1000x1000"
            echo "Using default dimensions for album art: $DIMENSIONS"
        else
            echo "Detected album art dimensions: $DIMENSIONS"
        fi
        
        # Add color depth (24 for JPEG)
        DIMENSIONS="${DIMENSIONS}x24"
        
        # Use the complete picture specification
        metaflac --import-picture-from="3|image/jpeg||${DIMENSIONS}|$(realpath "$ALBUM_ART_FILE")" "temp_music.flac"
        
        if [ $? -eq 0 ]; then
            echo "Album art added successfully"
        else
            echo "Warning: Failed to add album art with metaflac, trying simple method..."
            # Fallback to simple method
            metaflac --import-picture-from="$ALBUM_ART_FILE" "temp_music.flac" && echo "Album art added with simple method" || echo "Failed to add album art completely"
        fi
    fi
    
    # Rename the file to final name
    mv "temp_music.flac" "$OUTPUT_FILE"
    
# Fallback to ffmpeg if metaflac is not available
elif command -v ffmpeg >/dev/null 2>&1; then
    echo "Using ffmpeg for metadata..."
    
    # Build metadata string
    METADATA_ARGS=()
    [ "$TITLE" != "null" ] && [ -n "$TITLE" ] && METADATA_ARGS+=(-metadata "title=$TITLE")
    [ "$ARTIST" != "null" ] && [ -n "$ARTIST" ] && METADATA_ARGS+=(-metadata "artist=$ARTIST")
    [ "$ALBUM" != "null" ] && [ -n "$ALBUM" ] && METADATA_ARGS+=(-metadata "album=$ALBUM")
    [ "$TRACK_NUMBER" != "null" ] && [ -n "$TRACK_NUMBER" ] && METADATA_ARGS+=(-metadata "track=$TRACK_NUMBER")
    [ "$YEAR" != "null" ] && [ -n "$YEAR" ] && METADATA_ARGS+=(-metadata "date=$YEAR")
    [ "$GENRE" != "null" ] && [ -n "$GENRE" ] && METADATA_ARGS+=(-metadata "genre=$GENRE")
    [ "$BPM" != "null" ] && [ -n "$BPM" ] && METADATA_ARGS+=(-metadata "TBPM=$BPM")
    [ "$ISRC" != "null" ] && [ -n "$ISRC" ] && METADATA_ARGS+=(-metadata "ISRC=$ISRC")
    
    # Construct ffmpeg command based on whether we have album art
    if [ -f "$ALBUM_ART_FILE" ] && [ -s "$ALBUM_ART_FILE" ]; then
        echo "Adding metadata and album art with ffmpeg..."
        ffmpeg -i "temp_music.flac" -i "$ALBUM_ART_FILE" \
            -map 0 -map 1 \
            -c copy \
            -disposition:v attached_pic \
            "${METADATA_ARGS[@]}" \
            "$OUTPUT_FILE" -y
    else
        echo "Adding metadata with ffmpeg (no album art)..."
        ffmpeg -i "temp_music.flac" \
            -c copy \
            "${METADATA_ARGS[@]}" \
            "$OUTPUT_FILE" -y
    fi
    
    if [ $? -eq 0 ]; then
        rm -f "temp_music.flac"
        echo "Metadata added successfully with ffmpeg"
    else
        echo "Error: ffmpeg failed to add metadata"
        mv "temp_music.flac" "$OUTPUT_FILE"
    fi
else
    echo "Warning: Neither metaflac nor ffmpeg found. File downloaded without metadata as: $OUTPUT_FILE"
    mv "temp_music.flac" "$OUTPUT_FILE"
fi

mv "$OUTPUT_FILE" ~/Music/downloads/"$OUTPUT_FILE"

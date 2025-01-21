#!/bin/sh

# Define input and output files
REPO_FILE="/etc/apk/repositories"
TEMP_DIR="/tmp/repositories_data"

# Create a temporary directory to store downloaded content
mkdir -p "$TEMP_DIR"

# Read the repository file
while read -r line; do
    # Ignore empty lines or comments
    if echo "$line" | grep -qE '^\s*#'; then
        continue
    fi

    # Extract tag (if present) and repository URL
    TAG=$(echo "$line" | grep -oE '^@[a-zA-Z0-9_-]+' || echo "")
    URL=$(echo "$line" | sed -E 's/^@[a-zA-Z0-9_-]+\s*//' | xargs)

    # Skip invalid entries
    if [ -z "$URL" ]; then
        continue
    fi

    # Handle local directories
    if echo "$URL" | grep -qE '^/'; then
        cp -r "$URL" "$TEMP_DIR/"
        echo "Copied local repository: $URL"
    else
        # Handle remote URLs
        REPO_NAME=$(basename "$URL" | sed 's/[\/:.]/_/g') # Sanitize the name for storage
        DOWNLOAD_DIR="$TEMP_DIR/$REPO_NAME"
        mkdir -p "$DOWNLOAD_DIR"

        # Download and extract the APKINDEX.tar.gz
        wget -q -P "$DOWNLOAD_DIR" "$URL"/APKINDEX.tar.gz
        if [ -f "$DOWNLOAD_DIR/APKINDEX.tar.gz" ]; then
            tar -xzf "$DOWNLOAD_DIR/APKINDEX.tar.gz" -C "$DOWNLOAD_DIR"
            rm "$DOWNLOAD_DIR/APKINDEX.tar.gz"  # Remove the tar.gz to keep only the uncompressed file
            echo "Uncompressed APKINDEX for repository: $URL"
        else
            echo "Failed to download APKINDEX.tar.gz from: $URL"
        fi
    fi

done < "$REPO_FILE"

ls -lah $TEMP_DIR $TEMP_DIR/*

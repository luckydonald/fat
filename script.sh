#!/bin/sh

# Define input and output files
REPO_FILE="/etc/apk/repositories"
TEMP_DIR="/tmp/repositories_data"
ARCHIVE_NAME="repositories.tar.gz"

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
        REPO_NAME=$(basename "$URL")
        DOWNLOAD_DIR="$TEMP_DIR/$REPO_NAME"
        mkdir -p "$DOWNLOAD_DIR"

        # Use wget to download the repository index
        wget -q --mirror --no-parent --directory-prefix="$DOWNLOAD_DIR" "$URL"
        echo "Downloaded remote repository: $URL"
    fi
done < "$REPO_FILE"

ls -lah $TEMP_DIR



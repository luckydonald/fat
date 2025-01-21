#!/bin/sh

# Define input and output files
REPO_FILE="/etc/apk/repositories"
TEMP_DIR="/tmp/repositories_data"

# Create a temporary directory to store downloaded content
mkdir -p "$TEMP_DIR"

# Detect the system's architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="x86_64" ;;
    x86) ARCH="x86" ;;
    aarch64) ARCH="aarch64" ;;
    armv7l|armv7) ARCH="armv7" ;;
    armhf) ARCH="armhf" ;;
    loongarch64) ARCH="loongarch64" ;;
    ppc64le) ARCH="ppc64le" ;;
    riscv64) ARCH="riscv64" ;;
    s390x) ARCH="s390x" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

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

        # Build the full URL with architecture
        FULL_URL="$URL/$ARCH/APKINDEX.tar.gz"

        # Download and extract the APKINDEX.tar.gz
        wget -q -P "$DOWNLOAD_DIR" "$FULL_URL"
        if [ -f "$DOWNLOAD_DIR/APKINDEX.tar.gz" ]; then
            tar -xzf "$DOWNLOAD_DIR/APKINDEX.tar.gz" -C "$DOWNLOAD_DIR"
            rm "$DOWNLOAD_DIR/APKINDEX.tar.gz"  # Remove the tar.gz to keep only the uncompressed file
            echo "Downloaded and uncompressed APKINDEX for repository: $FULL_URL"
        else
            echo "Failed to download APKINDEX.tar.gz from: $FULL_URL"
        fi
    fi

done < "$REPO_FILE"

echo "Repositories have been processed and stored in $TEMP_DIR"
ls -lah $TEMP_DIR $TEMP_DIR/*

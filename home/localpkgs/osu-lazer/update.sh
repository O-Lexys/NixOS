#!/usr/bin/env bash
# Script to update osu-lazer-bin to the latest version
# Usage: ./update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"

echo "🎮 osu!lazer updater"
echo "===================="

echo "Fetching latest release..."

# Get latest release tag via redirect (doesn't require jq)
LATEST_TAG=$(curl -sI "https://github.com/ppy/osu/releases/latest" | grep -i "^location:" | sed 's/.*tag\///' | tr -d '\r\n')

if [[ -z "$LATEST_TAG" ]]; then
    echo "❌ Failed to fetch latest release"
    exit 1
fi

# Extract version (remove -lazer or -tachyon suffix)
VERSION=$(echo "$LATEST_TAG" | sed 's/-lazer$//' | sed 's/-tachyon$//')

echo "📦 Latest: $VERSION (tag: $LATEST_TAG)"

# Get current version from default.nix
CURRENT_VERSION=$(grep 'version = "' "$DEFAULT_NIX" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')
echo "📦 Current: $CURRENT_VERSION"

if [[ "$VERSION" == "$CURRENT_VERSION" ]]; then
    echo "✅ Already up to date!"
    exit 0
fi

# Construct download URL
APPIMAGE_URL="https://github.com/ppy/osu/releases/download/${LATEST_TAG}/osu.AppImage"

echo "🔗 URL: $APPIMAGE_URL"

# Verify URL exists
if ! curl --output /dev/null --silent --head --fail "$APPIMAGE_URL"; then
    echo "❌ AppImage not found at URL"
    exit 1
fi

echo "⏳ Fetching hash (this may take a while)..."

# Get hash using nix-prefetch-url
HASH=$(nix-prefetch-url "$APPIMAGE_URL" 2>/dev/null)
SRI_HASH=$(nix hash to-sri --type sha256 "$HASH")

echo "🔑 Hash: $SRI_HASH"

# Get the tag suffix (-lazer or -tachyon)
TAG_SUFFIX="${LATEST_TAG##*-}"

# Update default.nix
echo "📝 Updating $DEFAULT_NIX..."

sed -i "s/version = \"[^\"]*\"/version = \"$VERSION\"/" "$DEFAULT_NIX"
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$SRI_HASH\"|" "$DEFAULT_NIX"
sed -i "s|tag = \"\${version}-[^\"]*\"|tag = \"\${version}-${TAG_SUFFIX}\"|" "$DEFAULT_NIX"

echo ""
echo "✅ Updated to version $VERSION"
echo ""
echo "Run 'nh home switch' or 'home-manager switch' to apply."

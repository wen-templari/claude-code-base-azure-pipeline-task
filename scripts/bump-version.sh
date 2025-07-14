#!/bin/bash

# Version bump script for Claude Code Base Action
# Usage: ./scripts/bump-version.sh [patch|minor|major] [azure_version]

set -e

VERSION_TYPE=${1:-patch}
AZURE_VERSION=${2:-}

# Validate version type
if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo "Error: Invalid version type. Use 'patch', 'minor', or 'major'"
    exit 1
fi

echo "🚀 Bumping version..."

# Get current version
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Current GitHub Action version: $CURRENT_VERSION"

# Bump GitHub Action version
case "$VERSION_TYPE" in
    "major")
        NEW_VERSION=$(npm version major --no-git-tag-version)
        ;;
    "minor")
        NEW_VERSION=$(npm version minor --no-git-tag-version)
        ;;
    "patch")
        NEW_VERSION=$(npm version patch --no-git-tag-version)
        ;;
esac

# Remove 'v' prefix from npm version output
NEW_VERSION=${NEW_VERSION#v}
echo "New GitHub Action version: $NEW_VERSION"

# Update Azure extension version if provided
if [[ -n "$AZURE_VERSION" ]]; then
    echo "Updating Azure extension to version: $AZURE_VERSION"
    
    # Validate Azure version format (x.y.z)
    if [[ ! "$AZURE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid Azure version format. Use x.y.z format"
        exit 1
    fi
    
    # Update vss-extension.json
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$AZURE_VERSION\"/" vss-extension.json
    
    # Update task.json - extract major, minor, patch from version
    IFS='.' read -r MAJOR MINOR PATCH <<< "$AZURE_VERSION"
    sed -i.bak "s/\"Major\": [0-9]*/\"Major\": $MAJOR/" task.json
    sed -i.bak "s/\"Minor\": [0-9]*/\"Minor\": $MINOR/" task.json
    sed -i.bak "s/\"Patch\": [0-9]*/\"Patch\": $PATCH/" task.json
    
    # Clean up backup files
    rm -f vss-extension.json.bak task.json.bak
    
    echo "✅ Azure extension version updated to $AZURE_VERSION"
fi

echo "✅ Version bump completed!"
echo ""
echo "📋 Summary:"
echo "  - GitHub Action: $NEW_VERSION ($VERSION_TYPE bump)"
[[ -n "$AZURE_VERSION" ]] && echo "  - Azure DevOps Extension: $AZURE_VERSION"
echo ""
echo "🔄 Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Test the changes"
echo "  3. Commit the changes: git add . && git commit -m 'chore: bump version to $NEW_VERSION'"
[[ -n "$AZURE_VERSION" ]] && echo "  4. Build and test Azure extension: npm run package:azure"
echo "  5. Create a pull request or push to main"
#!/bin/bash

# Azure DevOps Extension publishing script
# Usage: ./scripts/publish-azure-extension.sh [--dry-run] [--version VERSION]

set -e

DRY_RUN=false
VERSION=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--version VERSION]"
            echo ""
            echo "Options:"
            echo "  --dry-run       Build but do not publish"
            echo "  --version VER   Use specific version (default: current version)"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Publishing Azure DevOps Extension..."
echo "Dry run: $DRY_RUN"

# Get version info
if [ -n "$VERSION" ]; then
    echo "Using manual version: $VERSION"
else
    VERSION=$(node -p "require('./vss-extension.json').version")
    echo "Using current version: $VERSION"
fi

# Check version consistency
echo "🔍 Checking version consistency..."
PACKAGE_VERSION=$(node -p "require('./package.json').version")
VSS_VERSION=$(node -p "require('./vss-extension.json').version")
TASK_VERSION=$(node -p "const task = require('./task.json'); \`\${task.version.Major}.\${task.version.Minor}.\${task.version.Patch}\`")

echo "Package.json: $PACKAGE_VERSION"
echo "vss-extension.json: $VSS_VERSION"
echo "task.json: $TASK_VERSION"

if [ "$VSS_VERSION" != "$TASK_VERSION" ]; then
    echo "❌ Version mismatch between vss-extension.json and task.json"
    exit 1
fi

echo "✅ Version consistency check passed"

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Check if tfx-cli is installed
if ! command -v tfx &> /dev/null; then
    echo "📦 Installing tfx-cli..."
    pnpm install -g tfx-cli
fi

# Build extension
echo "🔨 Building Azure extension..."
pnpm run build

echo "📦 Built files:"
ls -la dist/

# Validate build using our comprehensive validator
echo "🔍 Validating build..."
pnpm run validate:build

# Create VSIX package
echo "📦 Creating VSIX package..."
pnpm run create:vsix

VSIX_FILE="claswen.claude-code-base-task-$VSS_VERSION.vsix"

if [ ! -f "$VSIX_FILE" ]; then
    echo "❌ VSIX file not created: $VSIX_FILE"
    exit 1
fi

echo "✅ VSIX package created: $VSIX_FILE"

# Show file info
echo "📋 Package details:"
ls -lh "$VSIX_FILE"

if [ "$DRY_RUN" = true ]; then
    echo "🔍 Dry run completed - extension built but not published"
    echo "To publish manually, run:"
    echo "  tfx extension publish --vsix $VSIX_FILE --token <YOUR_PAT>"
    exit 0
fi

# Check for PAT token
if [ -z "$AZURE_DEVOPS_EXT_PAT" ]; then
    echo "❌ AZURE_DEVOPS_EXT_PAT environment variable not set"
    echo ""
    echo "Please set your Azure DevOps Personal Access Token:"
    echo "  export AZURE_DEVOPS_EXT_PAT=your_pat_token_here"
    echo ""
    echo "Or run with --dry-run to build without publishing"
    exit 1
fi

# Publish to marketplace
echo "🚀 Publishing to Azure DevOps Marketplace..."
echo "$AZURE_DEVOPS_EXT_PAT" | tfx extension publish --vsix "$VSIX_FILE" --token stdin

echo "✅ Extension published successfully!"
echo ""
echo "🌐 View at: https://marketplace.visualstudio.com/items?itemName=claswen.claude-code-base-task"
echo ""
echo "📋 Summary:"
echo "  - Version: $VSS_VERSION"
echo "  - VSIX File: $VSIX_FILE"
echo "  - Status: Published"
echo ""
echo "🔄 Next steps:"
echo "  1. Test the extension in Azure DevOps"
echo "  2. Update documentation if needed"
echo "  3. Announce the release"
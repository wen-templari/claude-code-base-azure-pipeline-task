#!/bin/bash

# Version bump script for Claude Code Base Azure Task
# Usage: ./scripts/bump-version.sh [patch|minor|major] [--auto-azure] [--dry-run]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VERSION_TYPE=${1:-patch}
AUTO_AZURE=false
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        patch|minor|major)
            VERSION_TYPE=$1
            shift
            ;;
        --auto-azure)
            AUTO_AZURE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [patch|minor|major] [--auto-azure] [--dry-run]"
            echo ""
            echo "Version types:"
            echo "  patch   Bump patch version (x.y.Z)"
            echo "  minor   Bump minor version (x.Y.z)"
            echo "  major   Bump major version (X.y.z)"
            echo ""
            echo "Options:"
            echo "  --auto-azure  Also update Azure extension to same version"
            echo "  --dry-run     Show what would be changed without making changes"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate version type
if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo -e "${RED}❌ Error: Invalid version type. Use 'patch', 'minor', or 'major'${NC}"
    exit 1
fi

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${BLUE}🔨 $1${NC}"
}

# Get project root directory
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$PROJECT_ROOT"

log_info "Bumping version ($VERSION_TYPE)..."
if [ "$DRY_RUN" = true ]; then
    log_warning "DRY RUN - No changes will be made"
fi

# Get current version
CURRENT_VERSION=$(node -p "require('./package.json').version")
log_info "Current version: $CURRENT_VERSION"

# Calculate new version without actually changing package.json yet
case "$VERSION_TYPE" in
    "major")
        IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
        NEW_VERSION="$((MAJOR + 1)).0.0"
        ;;
    "minor")
        IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
        NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
        ;;
    "patch")
        IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
        NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
        ;;
esac

log_info "New version will be: $NEW_VERSION"

# Check if working directory is clean
if [ "$DRY_RUN" = false ]; then
    if ! git diff --quiet; then
        log_error "Working directory is not clean. Please commit or stash changes first."
        exit 1
    fi
fi

# Backup files if not dry run
if [ "$DRY_RUN" = false ]; then
    log_step "Creating backups..."
    cp package.json package.json.bak
    cp vss-extension.json vss-extension.json.bak
    cp task.json task.json.bak
fi

# Update package.json
log_step "Updating package.json..."
if [ "$DRY_RUN" = false ]; then
    npm version $VERSION_TYPE --no-git-tag-version > /dev/null
    ACTUAL_NEW_VERSION=$(node -p "require('./package.json').version")
    log_success "Updated package.json to $ACTUAL_NEW_VERSION"
else
    log_info "Would update package.json to $NEW_VERSION"
    ACTUAL_NEW_VERSION=$NEW_VERSION
fi

# Update Azure extension files if requested
if [ "$AUTO_AZURE" = true ]; then
    log_step "Updating Azure extension files..."
    
    # Extract major, minor, patch from version
    IFS='.' read -r MAJOR MINOR PATCH <<< "$ACTUAL_NEW_VERSION"
    
    if [ "$DRY_RUN" = false ]; then
        # Update vss-extension.json
        sed -i.tmp "s/\"version\": \"[^\"]*\"/\"version\": \"$ACTUAL_NEW_VERSION\"/" vss-extension.json
        
        # Update task.json
        sed -i.tmp "s/\"Major\": [0-9]*/\"Major\": $MAJOR/" task.json
        sed -i.tmp "s/\"Minor\": [0-9]*/\"Minor\": $MINOR/" task.json
        sed -i.tmp "s/\"Patch\": [0-9]*/\"Patch\": $PATCH/" task.json
        
        # Clean up temporary files
        rm -f vss-extension.json.tmp task.json.tmp
        
        log_success "Updated Azure extension to $ACTUAL_NEW_VERSION"
    else
        log_info "Would update vss-extension.json to $ACTUAL_NEW_VERSION"
        log_info "Would update task.json to Major: $MAJOR, Minor: $MINOR, Patch: $PATCH"
    fi
fi

# Validate version consistency
if [ "$DRY_RUN" = false ]; then
    log_step "Validating version consistency..."
    
    PACKAGE_VERSION=$(node -p "require('./package.json').version")
    VSS_VERSION=$(node -p "require('./vss-extension.json').version")
    TASK_VERSION=$(node -p "const task = require('./task.json'); \`\${task.version.Major}.\${task.version.Minor}.\${task.version.Patch}\`")
    
    log_info "Package version: $PACKAGE_VERSION"
    log_info "VSS extension version: $VSS_VERSION"
    log_info "Task version: $TASK_VERSION"
    
    if [ "$AUTO_AZURE" = true ]; then
        if [ "$VSS_VERSION" != "$TASK_VERSION" ]; then
            log_error "Version mismatch between vss-extension.json and task.json"
            
            # Restore from backups
            mv package.json.bak package.json
            mv vss-extension.json.bak vss-extension.json
            mv task.json.bak task.json
            
            exit 1
        fi
    fi
    
    # Clean up backup files
    rm -f package.json.bak vss-extension.json.bak task.json.bak
    
    log_success "Version consistency validated"
fi

# Show summary
log_success "Version bump completed!"
echo ""
log_info "📋 Summary:"
echo "  - Package: $CURRENT_VERSION → $ACTUAL_NEW_VERSION ($VERSION_TYPE bump)"
if [ "$AUTO_AZURE" = true ]; then
    echo "  - Azure DevOps Extension: $ACTUAL_NEW_VERSION"
fi
echo ""

if [ "$DRY_RUN" = false ]; then
    log_info "🔄 Next steps:"
    echo "  1. Review the changes: git diff"
    echo "  2. Test the changes: npm run build"
    echo "  3. Commit the changes: git add . && git commit -m 'chore: bump version to $ACTUAL_NEW_VERSION'"
    echo "  4. Create a pull request or push to main"
    echo "  5. Build and test extension: npm run create:vsix"
    echo "  6. Publish if everything looks good: npm run publish:extension"
    
    # Check if there are any uncommitted changes
    if git diff --quiet; then
        log_warning "No changes detected. This might indicate a problem."
    else
        log_info "Changes detected. Ready to commit."
    fi
else
    log_info "This was a dry run. No actual changes were made."
    log_info "Run without --dry-run to apply changes."
fi
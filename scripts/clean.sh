#!/bin/bash

# Clean build artifacts and temporary files
# Usage: ./scripts/clean.sh [--all] [--verbose]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
CLEAN_ALL=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            CLEAN_ALL=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--all] [--verbose]"
            echo ""
            echo "Options:"
            echo "  --all       Clean everything including node_modules"
            echo "  --verbose   Show detailed output"
            echo "  -h, --help  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

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

# Get project root directory
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$PROJECT_ROOT"

log_info "Cleaning build artifacts..."
log_info "Project root: $PROJECT_ROOT"

# Define what to clean
BUILD_ARTIFACTS=(
    "dist"
    "*.vsix"
    "output.txt"
    "build-report.json"
    "*.tgz"
    ".tscache"
    "*.log"
)

TEMP_FILES=(
    "*.tmp"
    "*.temp"
    ".DS_Store"
    "Thumbs.db"
    "*.swp"
    "*.swo"
    "*~"
)

NODE_ARTIFACTS=(
    "node_modules"
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    ".npm"
    ".yarn"
)

# Function to safely remove files/directories
safe_remove() {
    local item="$1"
    local description="$2"
    
    if [ -e "$item" ] || [ -L "$item" ]; then
        if [ "$VERBOSE" = true ]; then
            log_info "Removing $description: $item"
        fi
        rm -rf "$item"
        if [ "$VERBOSE" = true ]; then
            log_success "Removed $description"
        fi
    else
        if [ "$VERBOSE" = true ]; then
            log_info "Not found: $item"
        fi
    fi
}

# Clean build artifacts
log_info "Cleaning build artifacts..."
for artifact in "${BUILD_ARTIFACTS[@]}"; do
    for file in $artifact; do
        if [ -e "$file" ]; then
            safe_remove "$file" "build artifact"
        fi
    done
done

# Clean temporary files
if [ "$VERBOSE" = true ]; then
    log_info "Cleaning temporary files..."
fi
for temp in "${TEMP_FILES[@]}"; do
    for file in $temp; do
        if [ -e "$file" ]; then
            safe_remove "$file" "temporary file"
        fi
    done
done

# Clean node artifacts if --all is specified
if [ "$CLEAN_ALL" = true ]; then
    log_info "Cleaning Node.js artifacts..."
    for node_artifact in "${NODE_ARTIFACTS[@]}"; do
        safe_remove "$node_artifact" "Node.js artifact"
    done
    log_warning "Node.js dependencies cleaned. Run 'npm install' to restore."
fi

# Clean specific directories that might contain build artifacts
CLEAN_DIRS=(
    "test/coverage"
    "test/tmp"
    "tmp"
    ".temp"
    ".cache"
)

for dir in "${CLEAN_DIRS[@]}"; do
    safe_remove "$dir" "temporary directory"
done

# Clean any leftover TypeScript build info
safe_remove "tsconfig.tsbuildinfo" "TypeScript build info"

# Clean Jest cache if it exists
safe_remove ".jest" "Jest cache"

# Clean any OS-specific cache directories
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific
    find . -name ".DS_Store" -type f -delete 2>/dev/null || true
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows specific
    find . -name "Thumbs.db" -type f -delete 2>/dev/null || true
fi

# Show what remains
if [ "$VERBOSE" = true ]; then
    log_info "Remaining files in project root:"
    ls -la
fi

# Check if anything important is missing
if [ "$CLEAN_ALL" = true ]; then
    if [ ! -f "package.json" ]; then
        log_error "package.json is missing! This might indicate a problem."
        exit 1
    fi
fi

log_success "Cleaning completed successfully!"

# Show cleanup summary
echo ""
log_info "Cleanup Summary:"
echo "  ✅ Build artifacts cleaned"
echo "  ✅ Temporary files cleaned"
if [ "$CLEAN_ALL" = true ]; then
    echo "  ✅ Node.js dependencies cleaned"
    echo "  ⚠️  Remember to run 'npm install' to restore dependencies"
fi

echo ""
log_info "Next steps:"
echo "  1. Run 'npm install' to install dependencies"
echo "  2. Run 'npm run build' to rebuild the extension"
echo "  3. Run 'npm test' to verify everything works"
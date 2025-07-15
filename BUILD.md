# Build Guide

This document provides comprehensive instructions for building the Claude Code Base Azure DevOps Extension.

## Quick Start

```bash
# Install dependencies
npm install

# Build the extension
npm run build

# Create VSIX package
npm run create:vsix

# Publish to marketplace
npm run publish:extension
```

## Build Scripts

### Core Build Commands

| Command | Description |
|---------|-------------|
| `npm run build` | Full build with all checks |
| `npm run build:clean` | Clean build (removes dist first) |
| `npm run build:fast` | Fast build (skips tests and lint) |
| `npm run build:azure` | TypeScript compilation only |

### Development Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Fast build + validation |
| `npm run clean` | Clean all build artifacts |
| `npm test` | Run tests |
| `npm run typecheck` | TypeScript type checking |
| `npm run format` | Format code |
| `npm run format:check` | Check code formatting |

### Release Commands

| Command | Description |
|---------|-------------|
| `npm run version:bump` | Bump version |
| `npm run create:vsix` | Create VSIX package |
| `npm run publish:extension` | Publish to marketplace |
| `npm run publish:dry-run` | Test publishing without uploading |
| `npm run release` | Full release workflow |

## Build Process

### 1. Prerequisites

- Node.js 18.x or higher
- npm or compatible package manager
- Git (for version management)

### 2. Install Dependencies

```bash
npm install
```

### 3. Build the Extension

The build process includes:

1. **TypeScript Compilation**: Compiles TypeScript source to JavaScript
2. **Validation**: Validates the build output
3. **Dependency Installation**: Installs production dependencies in `dist/`
4. **File Copying**: Copies necessary files to `dist/`

```bash
npm run build
```

### 4. Create VSIX Package

```bash
npm run create:vsix
```

This creates a `.vsix` file that can be installed in Azure DevOps.

### 5. Publish to Marketplace

```bash
# Test the publishing process
npm run publish:dry-run

# Publish to marketplace
npm run publish:extension
```

## Build Configuration

### TypeScript Configuration

- **Development**: `tsconfig.json` - Used for development and type checking
- **Build**: `tsconfig.build.json` - Used for production builds

### Key Build Files

- `scripts/build-extension.sh` - Main build script
- `scripts/validate-build.js` - Build validation
- `scripts/clean.sh` - Clean build artifacts
- `scripts/bump-version.sh` - Version management
- `scripts/publish-azure-extension.sh` - Publishing script

## Environment Variables

### Required for Publishing

- `AZURE_DEVOPS_EXT_PAT` - Azure DevOps Personal Access Token

### Optional

- `NODE_VERSION` - Node.js version for builds (default: 18.x)

## Build Validation

The build process includes comprehensive validation:

1. **File Structure**: Ensures all required files exist
2. **JavaScript Syntax**: Validates generated JavaScript
3. **JSON Validation**: Validates `task.json` and other JSON files
4. **Version Consistency**: Ensures versions match across files
5. **Dependencies**: Validates required dependencies are present

## Troubleshooting

### Common Issues

1. **TypeScript Compilation Errors**
   ```bash
   npm run typecheck
   ```

2. **Missing Dependencies**
   ```bash
   npm install
   npm run build:clean
   ```

3. **Version Mismatches**
   ```bash
   npm run version:bump -- --auto-azure
   ```

4. **Build Validation Failures**
   ```bash
   npm run validate:build
   ```

### Build Artifacts

The build creates the following structure:

```
dist/
├── azure-pipeline.js          # Main entry point
├── azure-run-claude.js        # Claude execution logic
├── azure-setup.js            # Setup utilities
├── azure-validate-env.js     # Environment validation
├── prepare-prompt.js          # Prompt preparation
├── setup-claude-code-settings.js # Claude settings
├── validate-env.js           # Environment validation
├── task.json                 # Task definition
├── node_modules/             # Production dependencies
└── package.json             # Package metadata
```

### Clean Build

If you encounter issues, try a clean build:

```bash
npm run clean
npm install
npm run build
```

## Version Management

### Automatic Version Bumping

```bash
# Bump patch version (1.0.0 → 1.0.1)
npm run version:bump

# Bump minor version (1.0.0 → 1.1.0)
npm run version:bump minor

# Bump major version (1.0.0 → 2.0.0)
npm run version:bump major

# Update Azure extension too
npm run version:bump -- --auto-azure
```

### Manual Version Updates

Update versions in:
- `package.json`
- `vss-extension.json`
- `task.json`

## CI/CD Integration

### Azure DevOps Pipeline

```yaml
- script: npm ci
  displayName: 'Install dependencies'

- script: npm run build
  displayName: 'Build extension'

- script: npm run create:vsix
  displayName: 'Create VSIX package'

- script: npm run publish:extension
  displayName: 'Publish to marketplace'
  env:
    AZURE_DEVOPS_EXT_PAT: $(marketplace-pat)
```

### GitHub Actions

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v3
  with:
    node-version: '18'

- name: Install dependencies
  run: npm ci

- name: Build extension
  run: npm run build

- name: Create VSIX
  run: npm run create:vsix

- name: Publish extension
  run: npm run publish:extension
  env:
    AZURE_DEVOPS_EXT_PAT: ${{ secrets.AZURE_DEVOPS_EXT_PAT }}
```

## Performance Optimization

### Build Speed

- Use `npm run build:fast` for development
- Use `npm run dev` for rapid iteration
- Enable TypeScript incremental compilation

### Output Size

- Production dependencies are automatically optimized
- Unused code is excluded from the build
- Source maps are disabled for production builds

## Security Considerations

- Never commit API keys or tokens
- Use environment variables for sensitive data
- Validate all inputs in the build process
- Regularly update dependencies

## Support

For build issues:

1. Check the build logs for specific errors
2. Run `npm run validate:build` for detailed diagnostics
3. Review the [troubleshooting section](#troubleshooting)
4. Open an issue with build logs if problems persist
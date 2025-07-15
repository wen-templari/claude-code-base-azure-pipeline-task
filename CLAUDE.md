# CLAUDE.md

## Common Commands

### Development Commands

- Build/Type check: `pnpm run typecheck`
- Format code: `pnpm run format`
- Check formatting: `pnpm run format:check`
- Run tests: `pnpm test`
- Install dependencies: `pnpm install`

### Azure DevOps Task Testing

- Test Azure DevOps task locally: `node test-azure-task.js`
- Test specific file: `pnpm test test/prepare-prompt.test.ts`

## Architecture Overview

This is an Azure DevOps extension that allows running Claude Code within Azure DevOps pipelines. The extension consists of:

### Core Components

1. **Task Definition** (`task.json`): Defines inputs, outputs, and the Azure DevOps task configuration
2. **Azure Pipeline Entry** (`src/azure-pipeline.ts`): Main entry point for Azure DevOps task execution
3. **Prompt Preparation** (`src/prepare-prompt.ts`): Handles prompt input validation and preparation
4. **Claude Execution** (`src/azure-run-claude.ts`): Manages Claude Code execution with Azure DevOps integration

### Key Design Patterns

- Uses Bun runtime for development and execution
- Named pipes for IPC between prompt input and Claude process
- JSON streaming output format for execution logs
- Azure DevOps task pattern with proper input/output handling
- Provider-agnostic design supporting Anthropic API, AWS Bedrock, and Google Vertex AI

## Provider Authentication

1. **Anthropic API** (default): Requires API key via `anthropic_api_key` input
2. **AWS Bedrock**: Uses AWS credentials from Azure DevOps variables
3. **Google Vertex AI**: Uses GCP service account credentials from Azure DevOps variables

## Testing Strategy

### Local Testing

- Use `test-azure-task.js` script to test Azure DevOps task locally
- Requires `ANTHROPIC_API_KEY` environment variable
- Tests task input validation and Claude execution

### Test Structure

- Unit tests for configuration logic
- Integration tests for prompt preparation
- Azure DevOps pipeline tests in `azure-pipelines.yml`

## Important Technical Details

- Uses `mkfifo` to create named pipes for prompt input
- Outputs execution logs as JSON to `${Agent.TempDirectory}/claude-execution-output.json`
- Timeout enforcement via process management
- Strict TypeScript configuration with Bun-specific settings
- Azure DevOps task library integration for proper variable handling

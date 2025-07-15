# Claude Code Base Task for Azure DevOps

This Azure DevOps extension allows you to run [Claude Code](https://www.anthropic.com/claude-code) within your Azure DevOps pipelines for automated code analysis, issue triage, and development tasks.

## Features

- **Multi-Provider Support**: Works with Anthropic API, AWS Bedrock, and Google Vertex AI
- **Flexible Prompts**: Support for inline prompts or prompt files
- **Tool Configuration**: Configurable allowed/disallowed tools
- **MCP Integration**: Model Context Protocol support for external integrations
- **Comprehensive Logging**: JSON execution logs for analysis
- **Timeout Management**: Configurable execution timeouts
- **Azure DevOps Integration**: Native support for Azure DevOps variables and service connections

## Installation

### Option 1: From Azure DevOps Marketplace

Install the extension from the [Azure DevOps Marketplace](https://marketplace.visualstudio.com/items?itemName=claswen.claude-code-base-task).

### Option 2: From Source

1. Clone this repository
2. Install dependencies: `pnpm install`
3. Build the Azure DevOps task: `pnpm run build:azure`
4. Package the task: `pnpm run create:vsix`
5. Upload the task to your Azure DevOps organization

## Quick Start

### Basic Usage

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Analyze Code with Claude"
  inputs:
    prompt: "Please review this codebase and provide improvement suggestions."
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"
    timeout_minutes: "10"
```

### Using Prompt Files

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Security Review"
  inputs:
    prompt_file: "prompts/security-review.txt"
    allowed_tools: "Bash,Glob,Grep,Read,LS"
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"
```

### AWS Bedrock Integration

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Claude via Bedrock"
  inputs:
    prompt: "Analyze this codebase for potential improvements."
    use_bedrock: true
    aws_region: "us-east-1"
    model: "anthropic.claude-3-sonnet-20240229-v1:0"
```

### Google Vertex AI Integration

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Claude via Vertex AI"
  inputs:
    prompt: "Review this code for best practices."
    use_vertex: true
    gcp_project_id: "my-gcp-project"
    gcp_region: "us-central1"
    model: "claude-3-sonnet@20240229"
```

## Task Inputs

| Input                     | Type      | Required | Description                                                             |
| ------------------------- | --------- | -------- | ----------------------------------------------------------------------- |
| `prompt`                  | multiLine | No       | The prompt to send to Claude Code (mutually exclusive with prompt_file) |
| `prompt_file`             | filePath  | No       | Path to a file containing the prompt (mutually exclusive with prompt)   |
| `allowed_tools`           | string    | No       | Comma-separated list of allowed tools                                   |
| `disallowed_tools`        | string    | No       | Comma-separated list of disallowed tools                                |
| `max_turns`               | string    | No       | Maximum number of conversation turns                                    |
| `mcp_config`              | string    | No       | MCP configuration as JSON string or path to JSON file                   |
| `system_prompt`           | multiLine | No       | Override system prompt                                                  |
| `append_system_prompt`    | multiLine | No       | Append to system prompt                                                 |
| `model`                   | string    | No       | Model to use (provider-specific format)                                 |
| `fallback_model`          | string    | No       | Fallback model when default is unavailable                              |
| `claude_env`              | multiLine | No       | Custom environment variables (YAML format)                              |
| `timeout_minutes`         | string    | No       | Timeout in minutes (default: 10)                                        |
| `anthropic_api_key`       | string    | No       | Anthropic API key                                                       |
| `claude_code_oauth_token` | string    | No       | Claude Code OAuth token                                                 |
| `use_bedrock`             | boolean   | No       | Use AWS Bedrock                                                         |
| `use_vertex`              | boolean   | No       | Use Google Vertex AI                                                    |
| `aws_region`              | string    | No       | AWS region for Bedrock                                                  |
| `gcp_project_id`          | string    | No       | GCP project ID for Vertex AI                                            |
| `gcp_region`              | string    | No       | GCP region for Vertex AI                                                |

## Task Outputs

| Output           | Description                                |
| ---------------- | ------------------------------------------ |
| `conclusion`     | Execution status ('success' or 'failure')  |
| `execution_file` | Path to JSON file containing execution log |

## Authentication

### Anthropic API (Default)

Set the `anthropic_api_key` input or configure the `ANTHROPIC_API_KEY` pipeline variable:

```yaml
variables:
  ANTHROPIC_API_KEY: $(anthropic-api-key) # Configure as secret variable
```

### AWS Bedrock

Configure AWS credentials as pipeline variables:

```yaml
variables:
  AWS_ACCESS_KEY_ID: $(aws-access-key-id)
  AWS_SECRET_ACCESS_KEY: $(aws-secret-access-key)
  AWS_REGION: "us-east-1"
```

### Google Vertex AI

Configure GCP credentials as pipeline variables:

```yaml
variables:
  GOOGLE_APPLICATION_CREDENTIALS: $(google-application-credentials)
  ANTHROPIC_VERTEX_PROJECT_ID: "my-gcp-project"
  CLOUD_ML_REGION: "us-central1"
```

## Available Tools

Claude Code supports various tools for interacting with your codebase:

- `Bash` - Execute shell commands
- `Glob` - File pattern matching
- `Grep` - Search file contents
- `Read` - Read file contents
- `LS` - List directory contents
- `Edit` - Edit files
- `Write` - Write new files
- `MultiEdit` - Multiple file edits
- `WebFetch` - Fetch web content
- `WebSearch` - Search the web
- `Task` - Launch sub-agents

## Common Use Cases

### Code Review

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Automated Code Review"
  inputs:
    prompt: |
      Please review this codebase and provide feedback on:
      1. Code quality and best practices
      2. Security vulnerabilities
      3. Performance optimizations
      4. Documentation improvements
    allowed_tools: "Bash,Glob,Grep,Read,LS"
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"
```

### Security Analysis

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Security Scan"
  inputs:
    prompt: |
      Perform a security analysis focusing on:
      1. OWASP Top 10 vulnerabilities
      2. Secrets in code
      3. Input validation issues
      4. Authentication/authorization flaws
    disallowed_tools: "Edit,Write,MultiEdit"
    system_prompt: "You are a security expert focused on identifying vulnerabilities."
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"
```

### Issue Triage

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Issue Triage"
  inputs:
    prompt_file: "prompts/triage-prompt.txt"
    mcp_config: "$(Agent.TempDirectory)/mcp-config/mcp-servers.json"
    allowed_tools: "Bash,mcp__github__get_issue,mcp__github__update_issue"
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"
```

## Custom Environment Variables

You can pass custom environment variables to Claude Code execution using the `claude_env` input. This allows Claude to access environment-specific configuration during its execution.

The `claude_env` input accepts YAML multiline format with key-value pairs:

```yaml
- task: ClaudeCodeBaseTask@1
  displayName: "Deploy with custom environment"
  inputs:
    prompt: "Deploy the application to the staging environment"
    claude_env: |
      ENVIRONMENT: staging
      API_BASE_URL: https://api-staging.example.com
      DATABASE_URL: $(staging-db-url)
      DEBUG: true
      LOG_LEVEL: debug
    allowed_tools: "Bash,Glob,Grep,Read,LS"
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"
```

### Features:

- **YAML Format**: Use standard YAML key-value syntax (`KEY: value`)
- **Multiline Support**: Define multiple environment variables in a single input
- **Comments**: Lines starting with `#` are ignored
- **Azure DevOps Variables**: Can reference Azure DevOps variables using `$(variable-name)`
- **Runtime Access**: Environment variables are available to Claude during execution

## MCP (Model Context Protocol) Integration

Configure MCP servers for external integrations:

```yaml
- script: |
    mkdir -p $(Agent.TempDirectory)/mcp-config
    cat > $(Agent.TempDirectory)/mcp-config/mcp-servers.json << 'EOF'
    {
      "mcpServers": {
        "github": {
          "command": "docker",
          "args": [
            "run", "-i", "--rm",
            "-e", "GITHUB_TOKEN",
            "ghcr.io/github/github-mcp-server:latest"
          ],
          "env": {
            "GITHUB_TOKEN": "$(System.AccessToken)"
          }
        }
      }
    }
    EOF
  displayName: "Setup MCP Configuration"

- task: ClaudeCodeBaseTask@1
  displayName: "Run Claude with MCP"
  inputs:
    prompt: "Access the GitHub MCP server and analyze recent issues"
    mcp_config: "$(Agent.TempDirectory)/mcp-config/mcp-servers.json"
    allowed_tools: "Bash,mcp__github__get_issue,mcp__github__update_issue"
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"
```

## Using Cloud Providers

You can authenticate with Claude using any of these methods:

1. Direct Anthropic API (default) - requires API key or OAuth token
2. Amazon Bedrock - requires AWS credentials and automatically uses cross-region inference profiles
3. Google Vertex AI - requires GCP credentials

### Model Configuration

Use provider-specific model names based on your chosen provider:

```yaml
# For direct Anthropic API (default)
- task: ClaudeCodeBaseTask@1
  inputs:
    prompt: "Your prompt here"
    model: "claude-3-7-sonnet-20250219"
    anthropic_api_key: "$(ANTHROPIC_API_KEY)"

# For Amazon Bedrock
- task: ClaudeCodeBaseTask@1
  inputs:
    prompt: "Your prompt here"
    model: "anthropic.claude-3-7-sonnet-20250219-v1:0"
    use_bedrock: true
    aws_region: "us-west-2"

# For Google Vertex AI
- task: ClaudeCodeBaseTask@1
  inputs:
    prompt: "Your prompt here"
    model: "claude-3-7-sonnet@20250219"
    use_vertex: true
    gcp_project_id: "my-gcp-project"
    gcp_region: "us-central1"
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure API keys are configured as secret variables
   - Check that service connections are properly configured
   - Verify provider-specific credentials

2. **Timeout Issues**
   - Increase `timeout_minutes` for complex tasks
   - Use `max_turns` to limit conversation length
   - Consider breaking complex prompts into smaller tasks

3. **Tool Permissions**
   - Review `allowed_tools` and `disallowed_tools` settings
   - Ensure required tools are not inadvertently disabled
   - Check agent permissions for file operations

### Debugging

Enable verbose logging by adding:

```yaml
- task: ClaudeCodeBaseTask@1
  inputs:
    # ... other inputs
    claude_env: |
      DEBUG: 1
      VERBOSE: 1
```

## Security Best Practices

**⚠️ IMPORTANT: Never commit API keys directly to your repository! Always use Azure DevOps secret variables.**

To securely use your Anthropic API key:

1. Add your API key as a secret variable:
   - Go to your pipeline's "Variables" section
   - Click "New variable"
   - Name it `ANTHROPIC_API_KEY`
   - Paste your API key as the value
   - Check "Keep this value secret"

2. Reference the secret in your task:
   ```yaml
   anthropic_api_key: "$(ANTHROPIC_API_KEY)"
   ```

**Never do this:**
```yaml
# ❌ WRONG - Exposes your API key
anthropic_api_key: "sk-ant-..."
```

**Always do this:**
```yaml
# ✅ CORRECT - Uses Azure DevOps secret variables
anthropic_api_key: "$(ANTHROPIC_API_KEY)"
```

## Examples

See the `azure-pipelines.yml` file for complete pipeline examples including:

- Multi-stage pipelines
- Conditional execution
- Artifact publishing
- Different authentication methods
- MCP server configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License—see the LICENSE file for details.

## Building and Development

### Prerequisites

- Node.js 18.x or higher
- pnpm package manager
- Git (for version management)

### Development Commands

| Command | Description |
|---------|-------------|
| `pnpm install` | Install dependencies |
| `pnpm run typecheck` | TypeScript type checking |
| `pnpm run format` | Format code |
| `pnpm run format:check` | Check code formatting |
| `pnpm test` | Run tests |
| `pnpm run build` | Full build with all checks |
| `pnpm run build:clean` | Clean build (removes dist first) |
| `pnpm run build:fast` | Fast build (skips tests and lint) |
| `pnpm run build:azure` | TypeScript compilation only |
| `pnpm run dev` | Fast build + validation |
| `pnpm run clean` | Clean all build artifacts |

### Testing

- Test Azure DevOps task locally: `node test-azure-task.js`
- Test specific file: `pnpm test test/prepare-prompt.test.ts`
- Requires `ANTHROPIC_API_KEY` environment variable for local testing

### Release Commands

| Command | Description |
|---------|-------------|
| `pnpm run version:bump` | Bump version |
| `pnpm run create:vsix` | Create VSIX package |
| `pnpm run publish:extension` | Publish to marketplace |
| `pnpm run publish:dry-run` | Test publishing without uploading |
| `pnpm run release` | Full release workflow |

### Build Process

The build process includes:

1. **TypeScript Compilation**: Compiles TypeScript source to JavaScript
2. **Validation**: Validates the build output
3. **Dependency Installation**: Installs production dependencies in `dist/`
4. **File Copying**: Copies necessary files to `dist/`

```bash
pnpm install
pnpm run build
pnpm run create:vsix
```

### Build Configuration

- **Development**: `tsconfig.json` - Used for development and type checking
- **Build**: `tsconfig.build.json` - Used for production builds

### Environment Variables

#### Required for Publishing

- `AZURE_DEVOPS_EXT_PAT` - Azure DevOps Personal Access Token

#### Optional

- `NODE_VERSION` - Node.js version for builds (default: 18.x)

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

### Version Management

```bash
# Bump patch version (1.0.0 → 1.0.1)
pnpm run version:bump

# Bump minor version (1.0.0 → 1.1.0)
pnpm run version:bump minor

# Bump major version (1.0.0 → 2.0.0)
pnpm run version:bump major

# Update Azure extension too
pnpm run version:bump -- --auto-azure
```

### Clean Build

If you encounter issues, try a clean build:

```bash
pnpm run clean
pnpm install
pnpm run build
```

## Support

For issues and questions:

- Check the [troubleshooting section](#troubleshooting)
- Review the [Azure DevOps documentation](https://docs.microsoft.com/en-us/azure/devops/)
- Open an issue in this repository
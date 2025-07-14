# Claude Code Base Task for Azure DevOps

This repository contains the Azure DevOps adaptation of the Claude Code Base Action, allowing you to run Claude Code AI assistant within Azure DevOps pipelines for automated code analysis, issue triage, and development tasks.

## Features

- **Multi-Provider Support**: Works with Anthropic API, AWS Bedrock, and Google Vertex AI
- **Flexible Prompts**: Support for inline prompts or prompt files
- **Tool Configuration**: Configurable allowed/disallowed tools
- **MCP Integration**: Model Context Protocol support for external integrations
- **Comprehensive Logging**: JSON execution logs for analysis
- **Timeout Management**: Configurable execution timeouts
- **Azure DevOps Integration**: Native support for Azure DevOps variables and service connections

## Installation

### Option 1: From Source

1. Clone this repository
2. Install dependencies: `npm install`
3. Build the Azure DevOps task: `npm run build:azure`
4. Package the task: `npm run package:azure`
5. Upload the task to your Azure DevOps organization

### Option 2: Via Azure DevOps Marketplace

_(Coming soon - task will be published to Azure DevOps Marketplace)_

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

This project is licensed under the same terms as the original Claude Code Base Action.

## Support

For issues and questions:

- Check the [troubleshooting section](#troubleshooting)
- Review the [original GitHub Action documentation](https://github.com/anthropics/claude-code-base-action)
- Open an issue in this repository

# Claude Code Base Task for Azure DevOps

An Azure DevOps extension that enables you to run Claude Code within your Azure DevOps pipelines for automated code assistance, reviews, and development tasks.

## Overview

This extension integrates Anthropic's Claude Code directly into your Azure DevOps pipelines, allowing you to leverage Claude's capabilities for:

- **Automated Code Review**: Analyze pull requests and provide intelligent feedback
- **Code Generation**: Generate code based on prompts and requirements
- **Bug Detection**: Identify potential issues and suggest fixes
- **Documentation**: Create or update documentation automatically
- **Testing**: Generate and run tests
- **Refactoring**: Improve code quality and structure

## Key Features

- **Multi-Provider Support**: Works with Anthropic API, AWS Bedrock, and Google Vertex AI
- **Flexible Authentication**: Supports API keys, OAuth tokens, and cloud provider credentials
- **Customizable Tools**: Configure which tools Claude can use (Bash, file operations, etc.)
- **Environment Variables**: Pass custom configuration to Claude execution
- **Timeout Control**: Set execution time limits
- **Conversation Management**: Control the number of turns in the conversation
- **MCP Integration**: Support for Model Context Protocol servers
- **Fallback Models**: Automatic fallback when primary models are unavailable

## Use Cases

- **Pull Request Reviews**: Automatically review code changes for quality, bugs, and best practices
- **Code Generation**: Generate boilerplate code, API endpoints, or entire features
- **Testing**: Create unit tests, integration tests, and test data
- **Documentation**: Generate README files, API documentation, and code comments
- **Refactoring**: Modernize legacy code and improve architecture
- **Security Analysis**: Identify potential security vulnerabilities
- **Performance Optimization**: Suggest improvements for better performance

## Platform Support

- **Azure DevOps**: Native extension available on Azure DevOps Marketplace
- **Cross-Platform**: Works on Windows, Linux, and macOS build agents
- **Multi-Language**: Supports all programming languages and frameworks

## Getting Started

Simply add the task to your Azure DevOps pipeline with your desired prompt and configuration. The extension handles Claude Code installation and execution automatically.

## Security

- Secure credential handling through Azure DevOps secret variables
- Cloud provider authentication support for AWS Bedrock and Google Vertex AI
- Configurable tool restrictions for security
- No API keys stored in logs or outputs
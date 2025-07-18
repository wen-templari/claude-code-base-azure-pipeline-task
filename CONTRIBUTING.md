# Contributing to Claude Code Base Action

Thank you for your interest in contributing to Claude Code Base Action! This document provides guidelines and instructions for contributing to the project.

## Getting Started

### Prerequisites

- [Bun](https://bun.sh/) runtime
- [Docker](https://www.docker.com/) (for running GitHub Actions locally)
- [act](https://github.com/nektos/act) (installed automatically by our test script)
- An Anthropic API key (for testing)

### Setup

1. Fork the repository on GitHub and clone your fork:

   ```bash
   git clone https://github.com/your-username/claude-code-base-action.git
   cd claude-code-base-action
   ```

2. Install dependencies:

   ```bash
   pnpm install
   ```

3. Set up your Anthropic API key:
   ```bash
   export ANTHROPIC_API_KEY="your-api-key-here"
   ```

## Development

### Available Scripts

- `pnpm test` - Run all tests
- `pnpm run typecheck` - Type check the code
- `pnpm run format` - Format code with Prettier
- `pnpm run format:check` - Check code formatting

## Testing

### Running Tests Locally

1. **Unit Tests**:

   ```bash
   pnpm test
   ```

2. **Integration Tests** (using GitHub Actions locally):

   ```bash
   ./test-local.sh
   ```

   This script:

   - Installs `act` if not present (requires Homebrew on macOS)
   - Runs the GitHub Action workflow locally using Docker
   - Requires your `ANTHROPIC_API_KEY` to be set

   On Apple Silicon Macs, the script automatically adds the `--container-architecture linux/amd64` flag to avoid compatibility issues.

## Pull Request Process

1. Create a new branch from `main`:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them:

   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Run tests and formatting:

   ```bash
   pnpm test
   pnpm run typecheck
   pnpm run format:check
   ```

4. Push your branch and create a Pull Request:

   ```bash
   git push origin feature/your-feature-name
   ```

5. Ensure all CI checks pass

6. Request review from maintainers

## Action Development

### Testing Your Changes

When modifying the action:

1. Test locally with the test script:

   ```bash
   ./test-local.sh
   ```

2. Test in a real GitHub Actions workflow by:
   - Creating a test repository
   - Using your branch as the action source:
     ```yaml
     uses: your-username/claude-code-base-action@your-branch
     ```

### Debugging

- Use `console.log` for debugging in development
- Check GitHub Actions logs for runtime issues
- Use `act` with `-v` flag for verbose output:
  ```bash
  act push -v --secret ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
  ```

## Common Issues

### Docker Issues

Make sure Docker is running before using `act`. You can check with:

```bash
docker ps
```

#!/usr/bin/env node

import * as tl from "azure-pipelines-task-lib/task";
import { preparePrompt } from "./prepare-prompt";
import { runClaudeAzure } from "./azure-run-claude";
import { setupClaudeCodeSettingsAzure, setupAzureEnvironment } from "./azure-setup";
import { validateEnvironmentVariablesAzure } from "./azure-validate-env";

async function run() {
  try {
    // Setup Azure DevOps environment
    await setupAzureEnvironment();

    // Validate environment variables based on task inputs
    validateEnvironmentVariablesAzure();

    // Setup Claude Code settings
    await setupClaudeCodeSettingsAzure();

    // Prepare prompt from task inputs
    const promptConfig = await preparePrompt({
      prompt: tl.getInput("prompt", false) || "",
      promptFile: tl.getInput("prompt_file", false) || "",
    });

    // Run Claude with Azure DevOps specific configuration
    await runClaudeAzure(promptConfig.path, {
      allowedTools: tl.getInput("allowed_tools", false),
      disallowedTools: tl.getInput("disallowed_tools", false),
      maxTurns: tl.getInput("max_turns", false),
      mcpConfig: tl.getInput("mcp_config", false),
      systemPrompt: tl.getInput("system_prompt", false),
      appendSystemPrompt: tl.getInput("append_system_prompt", false),
      claudeEnv: tl.getInput("claude_env", false),
      fallbackModel: tl.getInput("fallback_model", false),
      timeoutMinutes: tl.getInput("timeout_minutes", false),
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    tl.setResult(tl.TaskResult.Failed, `Task failed with error: ${errorMessage}`);
    tl.setVariable("conclusion", "failure");
    process.exit(1);
  }
}

// Run the task
run();
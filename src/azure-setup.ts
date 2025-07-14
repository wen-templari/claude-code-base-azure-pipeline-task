import * as tl from "azure-pipelines-task-lib/task";
import { homedir } from "os";
import { exec } from "child_process";
import { promisify } from "util";
import { mkdir, writeFile, readFile } from "fs/promises";
import { existsSync } from "fs";

const execAsync = promisify(exec);

export async function setupClaudeCodeSettingsAzure() {
  const home = homedir();
  const settingsPath = `${home}/.claude/settings.json`;
  console.log(`Setting up Claude settings at: ${settingsPath}`);

  // Ensure .claude directory exists
  console.log(`Creating .claude directory...`);
  await mkdir(`${home}/.claude`, { recursive: true });

  let settings: Record<string, unknown> = {};
  try {
    if (existsSync(settingsPath)) {
      const existingSettings = await readFile(settingsPath, "utf-8");
      if (existingSettings.trim()) {
        settings = JSON.parse(existingSettings);
        console.log(
          `Found existing settings:`,
          JSON.stringify(settings, null, 2),
        );
      } else {
        console.log(`Settings file exists but is empty`);
      }
    } else {
      console.log(`No existing settings file found, creating new one`);
    }
  } catch (e) {
    console.log(`Error reading existing settings: ${e}`);
  }

  // Enable all project MCP servers
  settings.enableAllProjectMcpServers = true;
  console.log(`Updated settings with enableAllProjectMcpServers: true`);

  await writeFile(settingsPath, JSON.stringify(settings, null, 2));
  console.log(`Settings saved successfully`);
}

export async function setupAzureEnvironment() {
  // Setup Azure DevOps specific environment variables
  const agentTempDirectory = tl.getVariable("Agent.TempDirectory") || "/tmp";
  const agentBuildDirectory =
    tl.getVariable("Agent.BuildDirectory") || process.cwd();

  // Set environment variables that Claude Code expects
  process.env.RUNNER_TEMP = agentTempDirectory;
  process.env.CLAUDE_WORKING_DIR = agentBuildDirectory;

  console.log(`Azure Agent Temp Directory: ${agentTempDirectory}`);
  console.log(`Azure Agent Build Directory: ${agentBuildDirectory}`);

  // Install Claude Code if not already installed
  try {
    await execAsync("claude --version");
    console.log("Claude Code is already installed");
  } catch (e) {
    console.log("Installing Claude Code...");
    await execAsync("npm install -g @anthropic-ai/claude-code@1.0.51");
    console.log("Claude Code installed successfully");
  }
}

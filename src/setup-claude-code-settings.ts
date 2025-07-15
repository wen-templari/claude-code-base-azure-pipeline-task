import { homedir } from "os";
import { readFile, writeFile, mkdir } from "fs/promises";
import { existsSync } from "fs";

export async function setupClaudeCodeSettings() {
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
    console.log(`Error reading settings file, creating new one`);
  }

  settings.enableAllProjectMcpServers = true;
  console.log(`Updated settings with enableAllProjectMcpServers: true`);

  await writeFile(settingsPath, JSON.stringify(settings, null, 2));
  console.log(`Settings saved successfully`);
}

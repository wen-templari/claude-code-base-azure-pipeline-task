import * as tl from "azure-pipelines-task-lib/task";

/**
 * Validates the environment variables required for running Claude Code
 * based on the selected provider (Anthropic API, AWS Bedrock, or Google Vertex AI)
 * using Azure DevOps task inputs
 */
export function validateEnvironmentVariablesAzure() {
  const useBedrock = tl.getBoolInput("use_bedrock", false);
  const useVertex = tl.getBoolInput("use_vertex", false);
  const anthropicApiKey = tl.getInput("anthropic_api_key", false);
  const claudeCodeOAuthToken = tl.getInput("claude_code_oauth_token", false);

  const errors: string[] = [];

  if (useBedrock && useVertex) {
    errors.push(
      "Cannot use both Bedrock and Vertex AI simultaneously. Please set only one provider.",
    );
  }

  if (!useBedrock && !useVertex) {
    if (!anthropicApiKey && !claudeCodeOAuthToken) {
      errors.push(
        "Either 'anthropic_api_key' or 'claude_code_oauth_token' input is required when using direct Anthropic API.",
      );
    }
  } else if (useBedrock) {
    const awsRegion = tl.getInput("aws_region", false);
    if (!awsRegion) {
      errors.push("'aws_region' input is required when using AWS Bedrock.");
    }

    // Check for AWS credentials in Azure DevOps variables or service connections
    const awsAccessKeyId = tl.getVariable("AWS_ACCESS_KEY_ID");
    const awsSecretAccessKey = tl.getVariable("AWS_SECRET_ACCESS_KEY");

    if (!awsAccessKeyId || !awsSecretAccessKey) {
      errors.push(
        "AWS credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) must be configured as pipeline variables when using AWS Bedrock.",
      );
    }
  } else if (useVertex) {
    const gcpProjectId = tl.getInput("gcp_project_id", false);
    const gcpRegion = tl.getInput("gcp_region", false);

    if (!gcpProjectId) {
      errors.push(
        "'gcp_project_id' input is required when using Google Vertex AI.",
      );
    }
    if (!gcpRegion) {
      errors.push(
        "'gcp_region' input is required when using Google Vertex AI.",
      );
    }

    // Check for GCP credentials
    const googleApplicationCredentials = tl.getVariable(
      "GOOGLE_APPLICATION_CREDENTIALS",
    );
    if (!googleApplicationCredentials) {
      errors.push(
        "GOOGLE_APPLICATION_CREDENTIALS must be configured as a pipeline variable when using Google Vertex AI.",
      );
    }
  }

  // Validate prompt inputs
  const prompt = tl.getInput("prompt", false);
  const promptFile = tl.getInput("prompt_file", false);

  if (!prompt && !promptFile) {
    errors.push("Either 'prompt' or 'prompt_file' input is required.");
  }

  if (prompt && promptFile) {
    errors.push(
      "Both 'prompt' and 'prompt_file' inputs were provided. Please specify only one.",
    );
  }

  if (errors.length > 0) {
    const errorMessage = `Task input validation failed:\n${errors.map((e) => `  - ${e}`).join("\n")}`;
    throw new Error(errorMessage);
  }
}

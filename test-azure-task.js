#!/usr/bin/env node

/**
 * Test script to simulate Azure DevOps task execution locally
 * This helps validate the task without actually deploying to Azure DevOps
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Mock Azure DevOps environment variables
const mockAzureEnv = {
  // Azure DevOps agent variables
  'AGENT_TEMPDIRECTORY': '/tmp/azure-test',
  'AGENT_BUILDDIRECTORY': process.cwd(),
  'AGENT_WORKFOLDER': process.cwd(),
  'SYSTEM_DEFAULTWORKINGDIRECTORY': process.cwd(),
  'SYSTEM_ACCESSTOKEN': 'mock-token',
  
  // Task input variables (these would normally come from the pipeline YAML)
  'INPUT_PROMPT': 'Please analyze this codebase and provide a brief summary of its structure and purpose.',
  'INPUT_ANTHROPIC_API_KEY': process.env.ANTHROPIC_API_KEY || 'test-key',
  'INPUT_TIMEOUT_MINUTES': '2',
  'INPUT_ALLOWED_TOOLS': 'Bash,Glob,Grep,Read,LS',
  'INPUT_DISALLOWED_TOOLS': 'Edit,Write,MultiEdit',
  'INPUT_MAX_TURNS': '3',
  
  // Provider settings
  'INPUT_USE_BEDROCK': 'false',
  'INPUT_USE_VERTEX': 'false',
  
  // Azure DevOps task lib debug
  'TASK_DEBUG': 'true',
  'SYSTEM_DEBUG': 'true',
  
  // Inherit current environment
  ...process.env
};

function createTempDirectory() {
  const tempDir = mockAzureEnv.AGENT_TEMPDIRECTORY;
  if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir, { recursive: true });
    console.log(`Created temp directory: ${tempDir}`);
  }
}

function runTask(testName, customEnv = {}) {
  return new Promise((resolve, reject) => {
    console.log(`\n=== Running test: ${testName} ===`);
    
    const taskProcess = spawn('node', ['azure-pipeline.js'], {
      cwd: path.join(__dirname, 'dist'),
      env: { ...mockAzureEnv, ...customEnv },
      stdio: 'pipe'
    });

    let stdout = '';
    let stderr = '';

    taskProcess.stdout.on('data', (data) => {
      const output = data.toString();
      stdout += output;
      process.stdout.write(output);
    });

    taskProcess.stderr.on('data', (data) => {
      const output = data.toString();
      stderr += output;
      process.stderr.write(output);
    });

    taskProcess.on('close', (code) => {
      console.log(`\nTest "${testName}" completed with exit code: ${code}`);
      resolve({
        name: testName,
        exitCode: code,
        stdout,
        stderr,
        success: code === 0
      });
    });

    taskProcess.on('error', (error) => {
      console.error(`\nTest "${testName}" failed to start: ${error.message}`);
      reject(error);
    });

    // Set a timeout to prevent hanging
    setTimeout(() => {
      console.log(`\nTest "${testName}" timed out, killing process...`);
      taskProcess.kill('SIGTERM');
      setTimeout(() => {
        taskProcess.kill('SIGKILL');
      }, 5000);
    }, 30000); // 30 second timeout
  });
}

async function runTests() {
  createTempDirectory();
  
  const tests = [
    {
      name: 'Missing Authentication',
      env: {
        'INPUT_ANTHROPIC_API_KEY': '',
        'INPUT_CLAUDE_CODE_OAUTH_TOKEN': ''
      }
    },
    {
      name: 'Missing Prompt',
      env: {
        'INPUT_PROMPT': '',
        'INPUT_PROMPT_FILE': ''
      }
    },
    {
      name: 'Valid Input (Mock API Key)',
      env: {
        'INPUT_ANTHROPIC_API_KEY': 'test-api-key',
        'INPUT_PROMPT': 'Test prompt for validation'
      }
    },
    {
      name: 'Bedrock Configuration',
      env: {
        'INPUT_USE_BEDROCK': 'true',
        'INPUT_AWS_REGION': 'us-east-1',
        'INPUT_PROMPT': 'Test prompt for Bedrock',
        'AWS_ACCESS_KEY_ID': 'test-key',
        'AWS_SECRET_ACCESS_KEY': 'test-secret'
      }
    },
    {
      name: 'Vertex AI Configuration',
      env: {
        'INPUT_USE_VERTEX': 'true',
        'INPUT_GCP_PROJECT_ID': 'test-project',
        'INPUT_GCP_REGION': 'us-central1',
        'INPUT_PROMPT': 'Test prompt for Vertex AI',
        'GOOGLE_APPLICATION_CREDENTIALS': '/tmp/test-credentials.json'
      }
    }
  ];

  const results = [];
  
  for (const test of tests) {
    try {
      const result = await runTask(test.name, test.env);
      results.push(result);
    } catch (error) {
      results.push({
        name: test.name,
        exitCode: 1,
        error: error.message,
        success: false
      });
    }
  }
  
  // Summary
  console.log('\n' + '='.repeat(50));
  console.log('TEST SUMMARY');
  console.log('='.repeat(50));
  
  results.forEach(result => {
    const status = result.success ? '✅ PASS' : '❌ FAIL';
    const details = result.success ? '' : ` (Exit code: ${result.exitCode})`;
    console.log(`${status} ${result.name}${details}`);
  });
  
  const passed = results.filter(r => r.success).length;
  const total = results.length;
  
  console.log('\n' + '='.repeat(50));
  console.log(`Results: ${passed}/${total} tests passed`);
  
  if (passed === total) {
    console.log('🎉 All tests passed! Task is ready for deployment.');
  } else {
    console.log('⚠️  Some tests failed. Review the output above.');
  }
  
  return results;
}

// Instructions for actual deployment
function printDeploymentInstructions() {
  console.log('\n' + '='.repeat(50));
  console.log('DEPLOYMENT INSTRUCTIONS');
  console.log('='.repeat(50));
  
  console.log('\n1. Install Azure DevOps CLI extension (if not already installed):');
  console.log('   az extension add --name azure-devops');
  
  console.log('\n2. Login to Azure:');
  console.log('   az login');
  
  console.log('\n3. Configure Azure DevOps:');
  console.log('   az devops configure --defaults organization=https://dev.azure.com/your-org project=your-project');
  
  console.log('\n4. Install TFX CLI (for packaging):');
  console.log('   npm install -g tfx-cli');
  
  console.log('\n5. Update vss-extension.json with your publisher ID');
  
  console.log('\n6. Package the extension:');
  console.log('   tfx extension create --manifest-globs vss-extension.json');
  
  console.log('\n7. Upload to Azure DevOps Marketplace:');
  console.log('   tfx extension publish --manifest-globs vss-extension.json');
  
  console.log('\n8. Or install directly to your organization:');
  console.log('   az devops extension install --extension-id claude-code-base-task --publisher your-publisher-id');
  
  console.log('\n9. Use in your pipeline:');
  console.log('   - task: ClaudeCodeBaseTask@1');
  console.log('     inputs:');
  console.log('       prompt: "Your prompt here"');
  console.log('       anthropic_api_key: "$(ANTHROPIC_API_KEY)"');
}

if (require.main === module) {
  runTests()
    .then(() => {
      printDeploymentInstructions();
    })
    .catch(console.error);
}

module.exports = { runTask, runTests };
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // Environment settings
    environment: "node",

    // Test file patterns
    include: ["test/**/*.test.ts", "test/**/*.spec.ts"],
    exclude: ["node_modules", "dist", "test/mcp-test/**/*"],

    // Coverage configuration
    coverage: {
      enabled: true, // Enable coverage reporting
      provider: "v8",
      reporter: ["text", "json", "html"],
      reportsDirectory: "./coverage",
      exclude: [
        "node_modules",
        "dist",
        "test",
        "scripts",
        "*.config.ts",
        "*.config.js",
        "vss-extension.json",
        "task.json",
      ],
      // Disable thresholds for now - can be enabled later as more tests are added
      // thresholds: {
      //   lines: 70,
      //   functions: 70,
      //   branches: 70,
      //   statements: 70
      // }
    },

    // Test execution settings
    globals: false, // Use explicit imports from vitest
    testTimeout: 30000, // 30 seconds timeout for tests
    hookTimeout: 10000, // 10 seconds timeout for hooks

    // TypeScript configuration
    typecheck: {
      enabled: false, // TypeScript checking is handled separately
    },

    // Watch mode settings
    watch: false, // Default to not watching, can be overridden with --watch

    // Reporter configuration
    reporter: process.env.CI ? "basic" : "verbose",

    // Retry configuration
    retry: 0,

    // Parallel execution
    pool: "forks", // Use forks for better isolation
    poolOptions: {
      forks: {
        singleFork: false,
      },
    },

    // Setup files
    setupFiles: [],

    // Mock settings
    clearMocks: true,
    restoreMocks: true,

    // Global test configuration
    logHeapUsage: false,

    // File system permissions for Azure DevOps tasks
    isolate: true,

    // Snapshot settings
    snapshotFormat: {
      printBasicPrototype: false,
    },
  },

  // Vite configuration for test builds
  esbuild: {
    target: "node18", // Match the Node.js version requirement
  },

  // Resolve configuration
  resolve: {
    alias: {
      "@": "/src",
    },
  },
});

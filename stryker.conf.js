// @ts-check
/** @type {import('@stryker-mutator/api/core').PartialStrykerOptions} */
const config = {
  packageManager: "npm",
  reporters: ["html", "clear-text", "progress"],
  testRunner: "command",
  commandRunner: {
    command: "npm run test:ci"
  },
  coverageAnalysis: "perTest",
  mutate: [
    "src/**/*.ts",
    "!src/**/*.spec.ts",
    "!src/test.ts",
    "!src/**/*.server.ts",
    "!src/main.ts",
    "!src/main.server.ts",
    "!src/server.ts"
  ],
  htmlReporter: {
    fileName: "reports/mutation/mutation-report.html"
  },
  thresholds: {
    high: 80,
    low: 60,
    break: 50
  },
  timeoutMS: 300000,
  maxConcurrentTestRunners: 1
};

module.exports = config;

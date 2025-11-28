// @ts-check
/** @type {import('@stryker-mutator/api/core').PartialStrykerOptions} */
const config = {
  packageManager: "npm",
  reporters: ["html", "clear-text", "progress", "dashboard"],
  testRunner: "karma",
  karma: {
    configFile: "karma.conf.js",
    projectType: "angular-cli",
    config: {
      browsers: ["ChromeHeadless"]
    }
  },
  coverageAnalysis: "perTest",
  mutate: [
    "src/**/*.ts",
    "!src/**/*.spec.ts",
    "!src/test.ts",
    "!src/environments/**",
    "!src/main.ts",
    "!src/polyfills.ts"
  ],
  htmlReporter: {
    fileName: "reports/mutation/mutation-report.html"
  },
  thresholds: {
    high: 80,
    low: 60,
    break: 50
  },
  timeoutMS: 60000,
  maxConcurrentTestRunners: 2
};

module.exports = config;

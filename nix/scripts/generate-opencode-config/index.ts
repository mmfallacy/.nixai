import { generateOpencodeConfig } from "./lib/generator";

export { generateOpencodeConfig };

if (import.meta.main) {
  const [, , configPath, outputDirectory] = process.argv;
  if (!configPath || !outputDirectory) {
    throw new Error(
      "Usage: generate-opencode-config <agentforms/index.ts> <output-directory>",
    );
  }
  await generateOpencodeConfig(configPath, outputDirectory);
}

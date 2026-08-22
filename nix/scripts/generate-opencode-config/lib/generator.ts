import { mkdir, rename } from "node:fs/promises";
import { dirname } from "node:path";
import { pathToFileURL } from "node:url";
import { isRecord } from "./json";
import { resolveConfigPath, resolveOutputDirectory } from "./paths";
import { planFiles } from "./plan";

export async function generateOpencodeConfig(
  configPath: string,
  outputDirectory: string,
) {
  const resolvedConfigPath = resolveConfigPath(configPath);
  const resolvedOutputDirectory = resolveOutputDirectory(outputDirectory);
  const imported = await import(pathToFileURL(resolvedConfigPath).href);
  const generatedFiles: unknown = imported.default;

  if (!isRecord(generatedFiles)) {
    throw new Error(
      `Config module ${configPath} must export a default filename-to-object record`,
    );
  }

  // Planning validates every file before the first filesystem mutation.
  const files = await planFiles(generatedFiles, resolvedOutputDirectory);
  await mkdir(resolvedOutputDirectory, { recursive: true });

  for (const file of files) {
    if (file.needsBackup) {
      await rename(file.outputPath, file.backupPath);
      console.warn(
        `Moved manually modified ${file.outputPath} to ${file.backupPath}`,
      );
    }
    await mkdir(dirname(file.outputPath), { recursive: true });
    await Bun.write(file.outputPath, file.contents);
    console.log(`Generated ${file.outputPath} from ${configPath}`);
  }
}

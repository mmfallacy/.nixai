import type { JsonObject, PlannedFile } from "./types";
import { hashConfig, isRecord } from "./json";
import { outputPathFor } from "./paths";

async function readExisting(outputPath: string) {
  const output = Bun.file(outputPath);
  if (!(await output.exists())) return undefined;

  let existing: unknown;
  try {
    existing = await output.json();
  } catch {
    throw new Error(`${outputPath} must contain a JSON object`);
  }

  if (!isRecord(existing))
    throw new Error(`${outputPath} must contain a JSON object`);
  return existing;
}

async function planFile(
  filename: string,
  value: unknown,
  outputDirectory: string,
  outputPaths: Set<string>,
): Promise<PlannedFile> {
  if (!isRecord(value))
    throw new Error(`Generated value for ${filename} must be a JSON object`);

  const outputPath = outputPathFor(filename, outputDirectory);
  if (outputPaths.has(outputPath))
    throw new Error(`Duplicate output filename: ${filename}`);
  outputPaths.add(outputPath);

  const existing = await readExisting(outputPath);
  const generatedWithHash = { ...value, hash: hashConfig(value) };
  const needsBackup =
    existing !== undefined && hashConfig(existing) !== existing.hash;
  const backupPath = `${outputPath}.bak`;

  const backupFileAlreadyExists =
    needsBackup && (await Bun.file(backupPath).exists());
  if (backupFileAlreadyExists) {
    throw new Error(
      `${backupPath} already exists; remove it before running the generator again`,
    );
  }

  return {
    outputPath,
    backupPath,
    contents: `${JSON.stringify(generatedWithHash, null, 2)}\n`,
    needsBackup,
  };
}

export async function planFiles(
  generatedFiles: JsonObject,
  outputDirectory: string,
) {
  const files: PlannedFile[] = [];
  const outputPaths = new Set<string>();

  for (const [filename, value] of Object.entries(generatedFiles)) {
    files.push(await planFile(filename, value, outputDirectory, outputPaths));
  }

  for (const file of files) {
    const backupPathConflictsWithOutput = outputPaths.has(file.backupPath);
    if (backupPathConflictsWithOutput) {
      throw new Error(
        `Backup path conflicts with a generated output: ${file.backupPath}`,
      );
    }
  }

  return files;
}

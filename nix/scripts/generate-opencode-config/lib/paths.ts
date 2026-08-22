import { isAbsolute, relative, resolve, sep } from "node:path";

export function resolveConfigPath(configPath: string) {
  return isAbsolute(configPath)
    ? configPath
    : resolve(process.cwd(), configPath);
}

export function resolveOutputDirectory(outputDirectory: string) {
  return isAbsolute(outputDirectory)
    ? outputDirectory
    : resolve(process.cwd(), outputDirectory);
}

export function outputPathFor(filename: string, outputDirectory: string) {
  if (!filename || isAbsolute(filename)) {
    throw new Error(`Unsafe output filename: ${filename}`);
  }

  const outputRoot = resolve(outputDirectory);
  const outputPath = resolve(outputRoot, filename);
  const pathFromRoot = relative(outputRoot, outputPath);

  const isWithinOutputRoot =
    pathFromRoot === ".." ||
    pathFromRoot.startsWith(`..${sep}`) ||
    isAbsolute(pathFromRoot);
  if (isWithinOutputRoot) {
    throw new Error(`Unsafe output filename: ${filename}`);
  }
  return outputPath;
}

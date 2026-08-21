import canonicalize from "canonicalize"
import { isAbsolute, resolve } from "node:path"
import { pathToFileURL } from "node:url"

const [, , configPath, outputPath] = process.argv

if (!configPath || !outputPath) {
  throw new Error("Usage: generate-opencode-config <root.ts> <opencode.json>")
}

const backupPath = `${outputPath}.bak`
type JsonObject = Record<string, unknown>

function isRecord(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value)
}

function hashConfig(config: JsonObject) {
  const withoutHash = { ...config }
  delete withoutHash.hash
  const hasher = new Bun.CryptoHasher("sha256")
  const canonical = canonicalize(withoutHash)
  if (canonical === undefined) throw new Error("Unable to canonicalize config")
  hasher.update(canonical)
  return hasher.digest("hex")
}

const resolvedConfigPath = isAbsolute(configPath) ? configPath : resolve(process.cwd(), configPath)
const imported = await import(pathToFileURL(resolvedConfigPath).href)
const generated: unknown = imported.default

if (!isRecord(generated)) {
  throw new Error(`Config module ${configPath} must export a default object`)
}

if (await Bun.file(backupPath).exists()) {
  throw new Error(`${backupPath} already exists; remove it before running the generator again`)
}

const output = Bun.file(outputPath)
const outputExists = await output.exists()
const existing: unknown = outputExists ? await output.json() : {}
if (!isRecord(existing)) {
  throw new Error(`${outputPath} must contain a JSON object`)
}

generated.hash = hashConfig(generated)

if (outputExists && existing.hash !== hashConfig(existing)) {
  const backupProcess = Bun.spawn(["mv", outputPath, backupPath])
  if ((await backupProcess.exited) !== 0) throw new Error(`Unable to rename ${outputPath} to ${backupPath}`)
  console.warn(`Moved manually modified ${outputPath} to ${backupPath}`)
}

await Bun.write(outputPath, `${JSON.stringify(generated, null, 2)}\n`)
console.log(`Generated ${outputPath} from ${configPath}`)

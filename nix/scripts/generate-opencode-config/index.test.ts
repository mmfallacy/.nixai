import { afterEach, expect, test } from "bun:test"
import { mkdtemp, rm } from "node:fs/promises"
import { join } from "node:path"
import { tmpdir } from "node:os"
import { generateOpencodeConfig } from "./lib/generator"

const temporaryDirectories: string[] = []

afterEach(async () => {
  await Promise.all(temporaryDirectories.splice(0).map((directory) => rm(directory, { recursive: true, force: true })))
})

async function fixture(source: string) {
  const directory = await mkdtemp(join(tmpdir(), "generate-opencode-config-"))
  temporaryDirectories.push(directory)
  const configPath = join(directory, "index.ts")
  const outputDirectory = join(directory, "output")
  await Bun.write(configPath, source)
  return { configPath, outputDirectory }
}

test("generates multiple files with embedded hashes", async () => {
  const paths = await fixture(`export default {
    "opencode.json": { "$schema": "https://opencode.ai/config.json" },
    "tui.json": { "theme": "dark" },
  }`)

  await generateOpencodeConfig(paths.configPath, paths.outputDirectory)

  const opencode = await Bun.file(join(paths.outputDirectory, "opencode.json")).json()
  const tui = await Bun.file(join(paths.outputDirectory, "tui.json")).json()
  expect(typeof opencode.hash).toBe("string")
  expect(typeof tui.hash).toBe("string")
  expect(opencode["$schema"]).toBe("https://opencode.ai/config.json")
})

test("does not back up files whose hashes still match", async () => {
  const paths = await fixture(`export default { "opencode.json": { "model": "a/model" } }`)
  await generateOpencodeConfig(paths.configPath, paths.outputDirectory)
  await generateOpencodeConfig(paths.configPath, paths.outputDirectory)

  expect(await Bun.file(join(paths.outputDirectory, "opencode.json.bak")).exists()).toBe(false)
})

test("backs up manually modified files", async () => {
  const paths = await fixture(`export default { "opencode.json": { "model": "a/model" } }`)
  await generateOpencodeConfig(paths.configPath, paths.outputDirectory)
  await Bun.write(join(paths.outputDirectory, "opencode.json"), '{ "model": "manual" }\n')
  await generateOpencodeConfig(paths.configPath, paths.outputDirectory)

  expect((await Bun.file(join(paths.outputDirectory, "opencode.json.bak")).json()).model).toBe("manual")
})

test("fails before changing any file when a backup conflicts", async () => {
  const paths = await fixture(`export default {
    "one.json": { "value": 1 },
    "two.json": { "value": 2 },
  }`)
  await generateOpencodeConfig(paths.configPath, paths.outputDirectory)
  await Bun.write(join(paths.outputDirectory, "one.json"), '{ "value": "manual" }\n')
  await Bun.write(join(paths.outputDirectory, "two.json"), '{ "value": "manual" }\n')
  await Bun.write(join(paths.outputDirectory, "two.json.bak"), "existing\n")

  await expect(generateOpencodeConfig(paths.configPath, paths.outputDirectory)).rejects.toThrow("two.json.bak")
  expect((await Bun.file(join(paths.outputDirectory, "one.json")).json()).value).toBe("manual")
})

test("rejects invalid exports and unsafe filenames", async () => {
  const invalid = await fixture(`export default { "opencode.json": [] }`)
  await expect(generateOpencodeConfig(invalid.configPath, invalid.outputDirectory)).rejects.toThrow("JSON object")

  const unsafe = await fixture(`export default { "../config.json": { "value": 1 } }`)
  await expect(generateOpencodeConfig(unsafe.configPath, unsafe.outputDirectory)).rejects.toThrow("Unsafe")
})

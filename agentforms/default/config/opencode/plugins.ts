import type { Config } from "@opencode-ai/sdk/v2";
import path from "node:path";

const NIXAI_PLUGINS_DIR = path.resolve(
  Bun.env.NIXAI_AGENTFORMS_ROOT ?? `${import.meta.dir}/../../..`,
  "..",
  "plugins",
);

export const vendored = ["opencode-model-alias"];
export const npm = [];

export const plugins = {
  plugin: [
    // Handled by opencode
    ...npm,
    // Source from vendored plugins dir
    ...vendored.map((name) => `${NIXAI_PLUGINS_DIR}/${name}`),
  ],
} satisfies Pick<Config, "plugin">;

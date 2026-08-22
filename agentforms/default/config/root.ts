import type { Config } from "@opencode-ai/sdk/v2";

import { agents } from "./agents.ts";
import { mcp } from "./mcp.ts";
import { models } from "./models.ts";
import { tools } from "./tools.ts";
import { plugins } from "./plugins.ts";

const config = {
  $schema: "https://opencode.ai/config.json",
  ...mcp,
  ...models,
  ...agents,
  ...tools,
  ...plugins,
} satisfies Config;

export default config;

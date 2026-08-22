import type { Config } from "@opencode-ai/sdk/v2";

import { agents } from "./agents.ts";
import { mcp } from "./mcp.ts";
import { models } from "./models.ts";
import { opencode as defaultOpencode } from "@agentforms/default";
import { deepmerge } from "deepmerge-ts";

const config = deepmerge(
  ...[
    {
      $schema: "https://opencode.ai/config.json",
    },
    defaultOpencode.value,
    mcp,
    models,
    agents,
  ],
) satisfies Config;

export default config;

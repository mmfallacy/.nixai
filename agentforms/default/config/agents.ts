import type { Config } from "@opencode-ai/sdk/v2";

export const agents = {
  default_agent: "plan",
  agent: {},
} satisfies Pick<Config, "agent">;

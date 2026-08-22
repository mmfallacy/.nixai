import type { Config } from "@opencode-ai/sdk/v2";

export const agents = {
  agent: {
    build: {
      model: "cheap",
      variant: "xhigh",
    },
  },
} satisfies Pick<Config, "agent">;

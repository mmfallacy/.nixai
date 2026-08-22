import type { Config } from "@opencode-ai/sdk/v2";

export const agents = {
  agent: {
    plan: { disable: true },
    general: { disable: true },
    explore: { disable: true },
    scout: { disable: true },
    compaction: { disable: true },
    title: { disable: true },
    summary: { disable: true },
  },
} satisfies Pick<Config, "agent">;

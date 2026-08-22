import type { Config } from "@opencode-ai/sdk/v2";

export const tools = {
  permission: {
    "*": "deny",

    read: "allow",
    grep: "allow",
    lsp: "allow",

    write: "allow",
    edit: "allow",
    bash: "allow",

    question: "allow",
    task: "allow",
  },
} satisfies Pick<Config, "permission">;

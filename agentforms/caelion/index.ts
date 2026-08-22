import root from "./config/opencode";
import { aliases } from "./config/aliases";

export default {
  opencode: {
    file: "opencode.json",
    value: root,
  },
  aliases: {
    file: "model-aliases.json",
    value: aliases,
  },
};

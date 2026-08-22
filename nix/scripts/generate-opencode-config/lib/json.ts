import canonicalize from "canonicalize";
import type { JsonObject } from "./types";

export function isRecord(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

export function hashConfig(config: JsonObject) {
  const withoutHash = { ...config };
  delete withoutHash.hash;
  const canonical = canonicalize(withoutHash);
  if (canonical === undefined) throw new Error("Unable to canonicalize config");

  const hasher = new Bun.CryptoHasher("sha256");
  hasher.update(canonical);
  return hasher.digest("hex");
}

export type JsonObject = Record<string, unknown>;

export type GeneratedFile = {
  file: string;
  value: unknown;
};

export type PlannedFile = {
  outputPath: string;
  backupPath: string;
  contents: string;
  needsBackup: boolean;
};

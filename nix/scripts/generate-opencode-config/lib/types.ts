export type JsonObject = Record<string, unknown>;

export type PlannedFile = {
  outputPath: string;
  backupPath: string;
  contents: string;
  needsBackup: boolean;
};

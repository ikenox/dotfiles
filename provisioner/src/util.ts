import {access} from "node:fs/promises";

export const exists = (file: string) => access(file).then(() => true, () => false);

/** @todo Finish this. Want it to create the desired project structure */

import { $ } from 'bun';

type templateFile = string | string[];
type claudeMDTemplate = string;
type projectRoot = string | string[];
type outDir = string | string[];

const projectDir = $`${CLAUDE}`;

type AdditionalFiles = Map<templateFile, outDir>;

interface ProjectConfig {
  claudeFile: claudeMDTemplate;
  projectFiles?: AdditionalFiles;
  projectDir: projectRoot;
}

const file = Bun.file('path/to/');
await Bun.write('path/to/copy.txt', file);

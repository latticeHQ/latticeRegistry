import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';
import { marked } from 'marked';

const REGISTRY_PATH = path.join(process.cwd(), '..', 'registry');

export interface ModuleFrontmatter {
  display_name: string;
  description: string;
  icon: string;
  verified?: boolean;
  tags?: string[];
  supported_os?: string[];
}

export interface PresetFrontmatter {
  display_name: string;
  description: string;
  icon: string;
  category: string;
  domain: string;
  tags?: string[];
  difficulty?: string;
  duration?: string;
  sidecar_id?: string;
  voice_settings?: {
    voice_id?: string;
    speed?: number;
    pitch?: number;
    stability?: number;
  };
  model_settings?: {
    model_id?: string;
    temperature?: number;
    max_tokens?: number;
  };
}

export interface NamespaceFrontmatter {
  display_name: string;
  bio: string;
  avatar: string;
  github?: string;
  website?: string;
  linkedin?: string;
  support_email?: string;
  status: 'official' | 'partner' | 'community';
}

export interface Module {
  namespace: string;
  name: string;
  slug: string;
  frontmatter: ModuleFrontmatter;
  content: string;
  htmlContent: string;
  terraformCode?: string;
  inputs?: TableRow[];
  outputs?: TableRow[];
}

export interface Preset {
  namespace: string;
  name: string;
  slug: string;
  frontmatter: PresetFrontmatter;
  content: string;
  htmlContent: string;
  instructions?: string;
}

export interface Namespace {
  name: string;
  frontmatter: NamespaceFrontmatter;
  content: string;
  htmlContent: string;
  modules: Module[];
  templates: Module[];
  presets: Preset[];
}

export interface TableRow {
  name: string;
  description: string;
  type?: string;
  default?: string;
  required?: string;
}

function parseMarkdownTable(content: string, headerName: string): TableRow[] {
  const tableRegex = new RegExp(`## ${headerName}[\\s\\S]*?\\|([\\s\\S]*?)(?=##|$)`, 'i');
  const match = content.match(tableRegex);
  if (!match) return [];

  const lines = match[1].trim().split('\n').filter(line => line.trim().startsWith('|'));
  if (lines.length < 3) return []; // Need header, separator, and at least one row

  const rows: TableRow[] = [];
  for (let i = 2; i < lines.length; i++) {
    const cells = lines[i].split('|').map(cell => cell.trim()).filter(Boolean);
    if (cells.length >= 2) {
      rows.push({
        name: cells[0]?.replace(/`/g, '') || '',
        description: cells[1] || '',
        type: cells[2]?.replace(/`/g, ''),
        default: cells[3]?.replace(/`/g, ''),
        required: cells[4],
      });
    }
  }
  return rows;
}

function extractTerraformCode(content: string): string | undefined {
  const match = content.match(/```tf\n([\s\S]*?)```/);
  return match ? match[1].trim() : undefined;
}

export async function getNamespaces(): Promise<Namespace[]> {
  const namespaces: Namespace[] = [];

  if (!fs.existsSync(REGISTRY_PATH)) {
    return namespaces;
  }

  const dirs = fs.readdirSync(REGISTRY_PATH, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory() && !dirent.name.startsWith('.'));

  for (const dir of dirs) {
    const namespace = await getNamespace(dir.name);
    if (namespace) {
      namespaces.push(namespace);
    }
  }

  return namespaces;
}

export async function getNamespace(name: string): Promise<Namespace | null> {
  const namespacePath = path.join(REGISTRY_PATH, name);
  const readmePath = path.join(namespacePath, 'README.md');

  if (!fs.existsSync(readmePath)) {
    return null;
  }

  const fileContent = fs.readFileSync(readmePath, 'utf-8');
  const { data, content } = matter(fileContent);
  const htmlContent = await marked(content);

  const modules = await getModulesForNamespace(name);
  const templates = await getTemplatesForNamespace(name);
  const presets = await getPresetsForNamespace(name);

  return {
    name,
    frontmatter: data as NamespaceFrontmatter,
    content,
    htmlContent,
    modules,
    templates,
    presets,
  };
}

export async function getModulesForNamespace(namespace: string): Promise<Module[]> {
  const modulesPath = path.join(REGISTRY_PATH, namespace, 'modules');
  const modules: Module[] = [];

  if (!fs.existsSync(modulesPath)) {
    return modules;
  }

  const dirs = fs.readdirSync(modulesPath, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory());

  for (const dir of dirs) {
    const module = await getModule(namespace, dir.name);
    if (module) {
      modules.push(module);
    }
  }

  return modules;
}

export async function getTemplatesForNamespace(namespace: string): Promise<Module[]> {
  const templatesPath = path.join(REGISTRY_PATH, namespace, 'templates');
  const templates: Module[] = [];

  if (!fs.existsSync(templatesPath)) {
    return templates;
  }

  const dirs = fs.readdirSync(templatesPath, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory());

  for (const dir of dirs) {
    const template = await getTemplate(namespace, dir.name);
    if (template) {
      templates.push(template);
    }
  }

  return templates;
}

export async function getModule(namespace: string, moduleName: string): Promise<Module | null> {
  const modulePath = path.join(REGISTRY_PATH, namespace, 'modules', moduleName);
  const readmePath = path.join(modulePath, 'README.md');

  if (!fs.existsSync(readmePath)) {
    return null;
  }

  const fileContent = fs.readFileSync(readmePath, 'utf-8');
  const { data, content } = matter(fileContent);
  const htmlContent = await marked(content);
  const terraformCode = extractTerraformCode(content);
  const inputs = parseMarkdownTable(content, 'Inputs');
  const outputs = parseMarkdownTable(content, 'Outputs');

  return {
    namespace,
    name: moduleName,
    slug: `${namespace}/${moduleName}`,
    frontmatter: data as ModuleFrontmatter,
    content,
    htmlContent,
    terraformCode,
    inputs,
    outputs,
  };
}

export async function getTemplate(namespace: string, templateName: string): Promise<Module | null> {
  const templatePath = path.join(REGISTRY_PATH, namespace, 'templates', templateName);
  const readmePath = path.join(templatePath, 'README.md');

  if (!fs.existsSync(readmePath)) {
    return null;
  }

  const fileContent = fs.readFileSync(readmePath, 'utf-8');
  const { data, content } = matter(fileContent);
  const htmlContent = await marked(content);
  const terraformCode = extractTerraformCode(content);

  return {
    namespace,
    name: templateName,
    slug: `${namespace}/${templateName}`,
    frontmatter: data as ModuleFrontmatter,
    content,
    htmlContent,
    terraformCode,
  };
}

export async function getAllModules(): Promise<Module[]> {
  const namespaces = await getNamespaces();
  return namespaces.flatMap(ns => ns.modules);
}

export async function getAllTemplates(): Promise<Module[]> {
  const namespaces = await getNamespaces();
  return namespaces.flatMap(ns => ns.templates);
}

export function getIconPath(iconRelativePath: string, namespace: string): string {
  // Icons are stored in /.icons/ at registry root
  // The relative path from module is like "../../../../.icons/key.svg"
  const iconName = iconRelativePath.split('/').pop() || 'default.svg';
  return `/icons/${iconName}`;
}

export async function getPresetsForNamespace(namespace: string): Promise<Preset[]> {
  const presetsPath = path.join(REGISTRY_PATH, namespace, 'presets');
  const presets: Preset[] = [];

  if (!fs.existsSync(presetsPath)) {
    return presets;
  }

  const dirs = fs.readdirSync(presetsPath, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory());

  for (const dir of dirs) {
    const preset = await getPreset(namespace, dir.name);
    if (preset) {
      presets.push(preset);
    }
  }

  return presets;
}

export async function getPreset(namespace: string, presetName: string): Promise<Preset | null> {
  const presetPath = path.join(REGISTRY_PATH, namespace, 'presets', presetName);
  const readmePath = path.join(presetPath, 'README.md');

  if (!fs.existsSync(readmePath)) {
    return null;
  }

  const fileContent = fs.readFileSync(readmePath, 'utf-8');
  const { data, content } = matter(fileContent);
  const htmlContent = await marked(content);

  // Try to read instructions from separate file
  let instructions: string | undefined;
  const instructionsPath = path.join(presetPath, 'instructions.md');
  if (fs.existsSync(instructionsPath)) {
    instructions = fs.readFileSync(instructionsPath, 'utf-8');
  }

  return {
    namespace,
    name: presetName,
    slug: `${namespace}/${presetName}`,
    frontmatter: data as PresetFrontmatter,
    content,
    htmlContent,
    instructions,
  };
}

export async function getAllPresets(): Promise<Preset[]> {
  const namespaces = await getNamespaces();
  return namespaces.flatMap(ns => ns.presets);
}

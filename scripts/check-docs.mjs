import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { extname, relative, resolve } from 'node:path';

const root = process.cwd();
const ignored = new Set(['.git', 'node_modules', 'dist']);
const textExtensions = new Set(['.md', '.txt']);
const failures = [];

function walk(directory) {
    return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
        const fullPath = resolve(directory, entry.name);
        if (entry.isDirectory()) return ignored.has(entry.name) ? [] : walk(fullPath);
        return textExtensions.has(extname(entry.name).toLowerCase()) ? [fullPath] : [];
    });
}

function report(file, target) {
    failures.push(`${relative(root, file)} -> ${target}`);
}

for (const file of walk(root)) {
    const content = readFileSync(file, 'utf8');
    for (const match of content.matchAll(/!?\[[^\]]*\]\(([^)\s]+)(?:\s+[^)]*)?\)/g)) {
        const target = match[1];
        if (/^(https?:|mailto:|#)/i.test(target)) continue;
        const localPath = resolve(file, '..', decodeURIComponent(target.split('#')[0]));
        if (!existsSync(localPath)) report(file, target);
    }
    for (const match of content.matchAll(/`((?:references|examples|docs)\/[^`\s]+)/g)) {
        const target = match[1].replace(/[),.;:]+$/, '');
        if (!existsSync(resolve(root, target))) report(file, target);
    }
}

const sourceRegistry = resolve(root, 'references/sources.md');
if (!existsSync(sourceRegistry) || !readFileSync(sourceRegistry, 'utf8').includes('Last verified:')) {
    failures.push('references/sources.md must contain a Last verified date');
}

if (failures.length) {
    console.error('Documentation checks failed:\n' + failures.map((item) => `- ${item}`).join('\n'));
    process.exit(1);
}

console.log('Documentation links and source registry are valid.');


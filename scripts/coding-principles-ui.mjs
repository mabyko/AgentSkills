import { confirm, intro, isCancel, note, select, text } from '@clack/prompts';
import pc from 'picocolors';
import { cancelSymbol, searchMultiselect } from './vendor/skills-search-multiselect.ts';

// Only selection lives here; Bash resolves paths and performs every file change.
async function main() {
  const [major, minor] = process.versions.node.split('.').map(Number);
  if (major < 22 || (major === 22 && minor < 20)) process.exit(1);
  if (process.argv[2] === '--check') return;

  const [message, mode, initial, ...labels] = process.argv.slice(2);
  if (!process.stdin.isTTY || !process.stderr.isTTY) {
    throw new Error('Selection requires a terminal and options');
  }
  const signal = new AbortController();
  let cancellationCode = 2;
  const interrupt = () => { cancellationCode = 130; signal.abort(); };
  process.on('SIGINT', interrupt);
  process.on('SIGTERM', interrupt);
  process.stdin.on('keypress', (character, key) => {
    if (key?.ctrl && key.name === 'c') cancellationCode = 130;
    if (mode !== 'multiple' && mode !== 'text' && (character === 'q' || character === 'Q')) signal.abort();
  });
  process.stdin.on('end', () => signal.abort());

  const terminal = { input: process.stdin, output: process.stderr, signal: signal.signal };
  if (mode === 'note') {
    note([initial, '', ...labels.map(path => pc.cyan(path))].join('\n'), message, terminal);
    return;
  }
  if (mode === 'multiple') intro(pc.bgCyan(pc.black(' coding principles ')), terminal);
  const values = mode === 'multiple' || mode === 'single'
    ? initial.trim().split(/\s+/).filter(Boolean).map(Number) : [];
  const options = {
    message,
    options: labels.map((entry, value) => {
      const [label, hint] = entry.split('\t');
      return { label, hint, value };
    }),
    ...terminal,
  };
  if (message === 'Installation scope') {
    options.options[0].hint = 'Install in project directory (shared with your project)';
    if (options.options[1]) options.options[1].hint = 'Install in home directory (available across all projects)';
    else options.options[0].hint = 'Selected agents require project instructions';
  }
  let result;
  if (mode === 'multiple') {
    result = await searchMultiselect({ ...terminal, message, items: options.options, initialSelected: values, required: true });
  } else if (mode === 'confirm') {
    result = await confirm({ ...terminal, message, initialValue: true });
  } else if (mode === 'text') {
    result = await text({ ...terminal, message, placeholder: initial, defaultValue: initial });
  } else {
    result = await select({ ...options, initialValue: values[0] });
  }
  if (isCancel(result) || result === cancelSymbol) process.exit(cancellationCode);
  if (mode === 'confirm') result = result ? 0 : 1;
  process.stdout.write((Array.isArray(result) ? result.join(' ') : String(result)) + '\n');
}

main().catch(error => {
  process.stderr.write(`Selection failed: ${error.message}\n`);
  process.exitCode = 1;
});

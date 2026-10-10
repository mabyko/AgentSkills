import { isCancel, multiselect, select } from '@clack/prompts';

// Only selection lives here; Bash resolves paths and performs every file change.
async function main() {
  const [major, minor] = process.versions.node.split('.').map(Number);
  if (major < 22 || (major === 22 && minor < 20)) process.exit(1);
  if (process.argv[2] === '--check') return;

  const [message, mode, initial, ...labels] = process.argv.slice(2);
  if (!process.stdin.isTTY || !process.stderr.isTTY || !labels.length) {
    throw new Error('Selection requires a terminal and options');
  }
  const signal = new AbortController();
  let cancellationCode = 2;
  const interrupt = () => { cancellationCode = 130; signal.abort(); };
  process.on('SIGINT', interrupt);
  process.on('SIGTERM', interrupt);
  process.stdin.on('keypress', (character, key) => {
    if (key?.ctrl && key.name === 'c') cancellationCode = 130;
    if (character === 'q' || character === 'Q') signal.abort();
  });
  process.stdin.on('end', () => signal.abort());

  const values = initial.trim() ? initial.trim().split(/\s+/).map(Number) : [];
  const options = {
    message,
    options: labels.map((label, value) => ({ label, value })),
    input: process.stdin,
    output: process.stderr,
    signal: signal.signal,
  };
  const result = mode === 'multiple'
    ? await multiselect({ ...options, initialValues: values, cursorAt: 0, required: true })
    : await select({ ...options, initialValue: values[0] });
  if (isCancel(result)) process.exit(cancellationCode);
  process.stdout.write((Array.isArray(result) ? result : [result]).join(' ') + '\n');
}

main().catch(error => {
  process.stderr.write(`Selection failed: ${error.message}\n`);
  process.exitCode = 1;
});

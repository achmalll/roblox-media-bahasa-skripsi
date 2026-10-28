// Loopback-only editor bridge. Never rewrites WORKING or executes incoming code.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const crypto = require('node:crypto');
const { read, hash } = require('./rbxl-local.cjs');
const keyOf = v => JSON.stringify(v.instancePath) + ':' + (v.property || 'Source');
function createBridge(root, options = {}) {
  root = path.resolve(root);
  const config = JSON.parse(fs.readFileSync(path.join(root, 'studio-sync/project.json'), 'utf8'));
  const port = options.port ?? config.port;
  const stateDir = path.join(root, 'local-rbxl/bridge');
  fs.mkdirSync(path.join(stateDir, 'requests'), { recursive: true });
  fs.mkdirSync(path.join(stateDir, 'receipts'), { recursive: true });
  const token = crypto.randomBytes(32).toString('hex');
  const baseline = read(path.join(root, 'places/RobloxLearningMedia-WORKING.rbxl'));
  const scripts = config.scripts.map(item => {
    const names = baseline.props.find(p => p.class === item.className && p.property === 'Name')?.values || [];
    const hits = names.map((v, i) => v.toString() === item.instancePath.at(-1) ? i : -1).filter(i => i >= 0);
    if (hits.length !== 1) throw Error('Baseline script missing/ambiguous');
    const source = baseline.props.find(p => p.class === item.className && p.property === 'Source').values[hits[0]].toString('utf8');
    const file = path.resolve(root, item.file);
    if (!file.startsWith(root + path.sep)) throw Error('Source file escapes repo');
    fs.mkdirSync(path.dirname(file), { recursive: true });
    if (!fs.existsSync(file)) fs.writeFileSync(file, source, { flag: 'wx' });
    return { item, file, expected: source, attempted: null, status: 'awaiting_studio' };
  });
  let session = null, snapshot = null, lastSeen = 0;
  const jobs = new Map();
  let disposed = false;
  const writeJson = (file, value) => {
    const temp = file + '.tmp'; fs.writeFileSync(temp, JSON.stringify(value, null, 2)); fs.renameSync(temp, file);
  };
  function publicStatus() {
    return { projectKey: config.projectKey, port, online: !!session && Date.now() - lastSeen < 8000,
      sessionId: session, lastSeen: lastSeen ? new Date(lastSeen).toISOString() : null,
      running: snapshot?.running ?? null, gameName: snapshot?.gameName ?? null,
      baselineSha256: hash(baseline.bytes), scripts: scripts.map(s => ({ instancePath: s.item.instancePath, file: s.item.file, status: s.status })),
      properties: snapshot?.properties || [],
      jobs: [...jobs.values()].map(j => ({ id: j.command.id, op: j.command.op, state: j.state,
        result: j.receipt?.result?.source !== undefined ? { status: j.receipt.result.status, sourceSha256: hash(Buffer.from(j.receipt.result.source)) } : j.receipt?.result,
        error: j.receipt?.error })) };
  }
  function persist() { writeJson(path.join(stateDir, 'status.json'), publicStatus()); }
  function checkCommand(command) {
    if (!command || typeof command.id !== 'string' || !/^[a-zA-Z0-9_-]{1,100}$/.test(command.id)) throw Error('Invalid command ID');
    if (!['set_property', 'read_property', 'update_source'].includes(command.op)) throw Error('Unsupported command');
    const list = command.op === 'update_source' ? config.scripts : config.properties;
    if (!list.some(v => keyOf(v) === keyOf(command) && v.className === command.className)) throw Error('Target outside project scope');
    if (command.op === 'set_property' && (command.property !== 'HoldDuration' || !Number.isFinite(command.value) || command.value < 0 || command.value > 10 || !Number.isFinite(command.before))) throw Error('Invalid property write');
    if (command.op === 'update_source' && (typeof command.source !== 'string' || typeof command.beforeSource !== 'string')) throw Error('Missing compare-and-set source');
  }
  function enqueue(command) {
    checkCommand(command);
    const previous = jobs.get(command.id);
    if (previous) { if (JSON.stringify(previous.command) !== JSON.stringify(command)) throw Error('Command ID reused with different payload'); return; }
    jobs.set(command.id, { command, state: 'queued', sessionId: session });
  }
  function reconcile() {
    if (!snapshot || snapshot.running || !session || Date.now() - lastSeen >= 8000) return;
    for (const s of scripts) {
      const current = snapshot.scripts.find(v => keyOf(v) === keyOf(s.item));
      if (!current || current.className !== s.item.className || typeof current.source !== 'string') { s.status = 'missing_or_wrong_class'; continue; }
      const local = fs.readFileSync(s.file, 'utf8'), studio = current.source;
      if (local === studio) { s.expected = studio; s.status = 'synced_in_editor'; continue; }
      if (studio !== s.expected) {
        if (local === s.expected) {
          if (fs.readFileSync(s.file, 'utf8') === local) { fs.writeFileSync(s.file, studio); s.expected = studio; s.status = 'imported_from_studio'; }
        } else {
          s.status = 'conflict';
          fs.writeFileSync(path.join(stateDir, path.basename(s.file) + '.studio-conflict.luau'), studio);
        }
        continue;
      }
      const desiredHash = hash(Buffer.from(local));
      if (s.attempted === desiredHash) continue;
      if ([...jobs.values()].some(j => j.state === 'queued' && keyOf(j.command) === keyOf(s.item))) continue;
      const command = { id: 'source-' + crypto.randomUUID(), op: 'update_source', ...s.item, beforeSource: studio, source: local };
      delete command.file;
      enqueue(command); s.attempted = desiredHash; s.status = 'pending_apply';
    }
  }
  function scanRequests() {
    for (const name of fs.readdirSync(path.join(stateDir, 'requests')).filter(n => n.endsWith('.json'))) {
      const file = path.join(stateDir, 'requests', name);
      try {
        const command = JSON.parse(fs.readFileSync(file, 'utf8'));
        enqueue(command);
      } catch (error) { writeJson(path.join(stateDir, 'receipts', name + '.rejected.json'), { ok: false, error: error.message }); }
    }
    reconcile(); persist();
  }
  const server = http.createServer(async (req, res) => {
    function reply(code, value) { res.writeHead(code, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }); res.end(JSON.stringify(value)); }
    try {
      // Custom header + no CORS/Origin prevents browser pages from pairing via CSRF.
      if (req.method !== 'POST' || req.headers.origin || req.headers['x-codex-bridge'] !== 'rbxl-v1' || ![`127.0.0.1:${port}`, `localhost:${port}`].includes(req.headers.host)) return reply(403, { error: 'Loopback native client only' });
      let body = ''; for await (const chunk of req) { body += chunk; if (body.length > 4 * 1024 * 1024) return reply(413, { error: 'Body too large' }); }
      const data = JSON.parse(body || '{}');
      if (req.url === '/health') return reply(200, { projectKey: config.projectKey, workspaceRoot: root, online: publicStatus().online });
      if (req.url === '/pair') {
        if (data.projectKey !== config.projectKey || typeof data.sessionId !== 'string') return reply(409, { error: 'Wrong project/session' });
        if (session && session !== data.sessionId && Date.now() - lastSeen < 12000) return reply(409, { error: 'Another Studio session is connected' });
        if (session !== data.sessionId) {
          for (const j of jobs.values()) if (j.state === 'queued' && j.sessionId) j.state = 'cancelled_session_changed';
          snapshot = null;
        }
        session = data.sessionId; lastSeen = Date.now(); persist();
        return reply(200, { token, sessionId: session, config });
      }
      if (req.headers['x-bridge-token'] !== token || req.headers['x-studio-session'] !== session || !session) return reply(403, { error: 'Session authentication failed' });
      lastSeen = Date.now();
      if (req.url === '/snapshot') {
        if (!Array.isArray(data.scripts) || !Array.isArray(data.properties) || typeof data.running !== 'boolean') throw Error('Invalid snapshot');
        snapshot = data; reconcile(); persist(); return reply(200, { ok: true });
      }
      if (req.url === '/poll') {
        if (!snapshot || snapshot.running) return reply(200, {});
        const job = [...jobs.values()].find(j => j.state === 'queued');
        if (job) job.sessionId = session;
        return reply(200, job ? { command: job.command } : {});
      }
      if (req.url === '/result') {
        const job = jobs.get(data.id);
        if (!job || job.sessionId !== session) throw Error('Unknown command');
        if (job.receipt && JSON.stringify(job.receipt) !== JSON.stringify(data)) throw Error('Conflicting duplicate receipt');
        job.receipt = data; job.state = data.ok ? 'applied_readback' : 'failed';
        if (job.command.op === 'update_source') {
          const s = scripts.find(v => keyOf(v.item) === keyOf(job.command));
          if (data.ok && data.result?.source === job.command.source) {
            s.expected = data.result.source; s.status = 'applied_waiting_snapshot';
            const view = snapshot?.scripts.find(v => keyOf(v) === keyOf(job.command));
            if (view) view.source = data.result.source;
          }
          else s.status = 'apply_failed';
        }
        writeJson(path.join(stateDir, 'receipts', data.id + '.json'), { receivedAt: new Date().toISOString(), ...data });
        persist(); return reply(200, { ok: true });
      }
      return reply(404, { error: 'Unknown route' });
    } catch (error) { reply(400, { error: error.message }); }
  });
  const timer = setInterval(() => { try { scanRequests(); } catch (e) { writeJson(path.join(stateDir, 'last-error.json'), { error: e.message }); } }, 500);
  return {
    server, config, stateDir, enqueue, status: publicStatus,
    start: () => new Promise((resolve, reject) => { server.once('error', reject); server.listen(port, '127.0.0.1', () => { persist(); resolve(publicStatus()); }); }),
    close: () => new Promise(resolve => { if (disposed) return resolve(); disposed = true; clearInterval(timer); server.close(resolve); })
  };
}
module.exports = { createBridge };
if (require.main === module) {
  const bridge = createBridge(path.resolve(__dirname, '..'));
  bridge.start().then(status => console.log(JSON.stringify({ message: 'Bridge ready; localhost only; WORKING is not written', port: status.port }))).catch(e => { console.error(e.message); process.exit(1); });
  process.on('SIGINT', () => bridge.close().then(() => process.exit(0)));
}

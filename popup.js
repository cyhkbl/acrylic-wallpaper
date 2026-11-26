const DEFAULTS = { enabled: true, strength: 'normal', themeMode: 'auto', disabledHosts: [] };

const $ = (id) => document.getElementById(id);
let currentHost = '';
let settings = { ...DEFAULTS };

const save = (patch) => {
  settings = { ...settings, ...patch };
  chrome.storage.sync.set(settings);
  render();
};

const render = () => {
  $('enabled').checked = Boolean(settings.enabled);
  $('strength').value = settings.strength || 'normal';
  $('themeMode').value = settings.themeMode || 'auto';
  $('host').textContent = currentHost || '当前站点';
  const disabled = currentHost ? settings.disabledHosts.includes(currentHost) : false;
  $('hostState').textContent = !currentHost
    ? '这个页面不能用（浏览器内部页）'
    : disabled
      ? '已在本站禁用'
      : '已启用';
  $('toggleHost').textContent = disabled ? '恢复本站' : '禁用本站';
  $('toggleHost').disabled = !currentHost;
};

chrome.storage.sync.get(DEFAULTS, (stored) => {
  settings = { ...DEFAULTS, ...stored };
  chrome.tabs.query({ active: true, currentWindow: true }, ([tab]) => {
    try {
      const url = new URL(tab?.url ?? '');
      if (url.protocol === 'http:' || url.protocol === 'https:') currentHost = url.hostname;
    } catch {
      currentHost = '';
    }
    render();
  });
});

$('enabled').addEventListener('change', (e) => save({ enabled: e.target.checked }));
$('strength').addEventListener('change', (e) => save({ strength: e.target.value }));
$('themeMode').addEventListener('change', (e) => save({ themeMode: e.target.value }));

$('toggleHost').addEventListener('click', () => {
  if (!currentHost) return;
  const list = new Set(settings.disabledHosts);
  if (list.has(currentHost)) list.delete(currentHost);
  else list.add(currentHost);
  save({ disabledHosts: [...list] });
});

$('openNewTab').addEventListener('click', () => {
  chrome.tabs.create({ url: chrome.runtime.getURL('newtab.html') });
});

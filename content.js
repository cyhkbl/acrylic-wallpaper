/*
 * Acrylic Wallpaper — content script.
 *
 * Puts a blurred copy of the wallpaper behind every page and makes the page's
 * own surfaces transparent so it shows through. Settings live in
 * chrome.storage.sync:
 *   enabled       master switch
 *   strength      light | normal | strong
 *   themeMode     auto (follow the page's own text colour) | system
 *   disabledHosts hostnames opted out
 */
(() => {
  const host = location.hostname || '';
  const DEFAULTS = { enabled: true, strength: 'normal', themeMode: 'auto', disabledHosts: [] };
  const LIGHT = { bg: '#dfe7f2', veil: 'rgba(255, 255, 255, 0.62)' };
  const DARK = { bg: '#0a0d13', veil: 'rgba(8, 10, 14, 0.66)' };

  const parseRgb = (value) => {
    const m = String(value).match(/rgba?\(([^)]+)\)/);
    if (!m) return null;
    const parts = m[1].split(',').map((n) => parseFloat(n));
    if (parts.length < 3 || parts.some((n) => Number.isNaN(n))) return null;
    if (parts.length === 4 && parts[3] === 0) return null;
    return parts;
  };

  const isDarkColor = (value) => {
    const rgb = parseRgb(value);
    if (!rgb) return false;
    const [r, g, b] = rgb;
    return 0.2126 * r + 0.7152 * g + 0.0722 * b < 128;
  };

  const pickPalette = (themeMode) => {
    if (themeMode === 'system') {
      return matchMedia('(prefers-color-scheme: dark)').matches ? DARK : LIGHT;
    }
    // auto: the page keeps its own text colour, so the veil has to match that,
    // not the desktop scheme — otherwise light sites go dark-on-dark.
    const el = document.body || document.documentElement;
    const textColor = el ? getComputedStyle(el).color : '';
    if (!textColor) return matchMedia('(prefers-color-scheme: dark)').matches ? DARK : LIGHT;
    return isDarkColor(textColor) ? LIGHT : DARK;
  };

  const applyPalette = (palette) => {
    document.documentElement.style.setProperty('--dsh-wallpaper-bg-color', palette.bg);
    document.documentElement.style.setProperty('--dsh-wallpaper-veil', palette.veil);
  };

  const buildCss = (blurUrl, strength) => `
    #dsh-wallpaper-bg {
      position: fixed;
      inset: -12vh -12vw;
      z-index: -2147483647;
      pointer-events: none;
      background: var(--dsh-wallpaper-bg-color, #dfe7f2) url("${blurUrl}") center / cover no-repeat;
      filter: blur(34px) saturate(1.25);
    }
    #dsh-wallpaper-bg::after {
      content: "";
      position: absolute;
      inset: 0;
      background: var(--dsh-wallpaper-veil, rgba(255, 255, 255, 0.62));
    }
    html, body { background: transparent !important; background-color: transparent !important; }
    ${
      strength !== 'light'
        ? `body > div, body > main, body > header, body > section,
           #app, #root, #content, #main, main, .app, .container, .wrapper, .page {
             background-color: transparent !important;
           }`
        : ''
    }
    ${
      strength === 'strong'
        ? `body *:not(img):not(video):not(canvas):not(svg):not(iframe):not(input):not(button):not(select):not(textarea):not([class*="icon"]):not([class*="logo"]) {
             background-color: transparent !important;
           }`
        : ''
    }
  `;

  const inject = (blurUrl, strength) => {
    if (!document.documentElement || document.getElementById('dsh-wallpaper-bg')) return;
    const style = document.createElement('style');
    style.id = 'dsh-wallpaper-style';
    style.textContent = buildCss(blurUrl, strength);
    (document.head || document.documentElement).appendChild(style);
    const layer = document.createElement('div');
    layer.id = 'dsh-wallpaper-bg';
    layer.setAttribute('aria-hidden', 'true');
    document.documentElement.insertBefore(layer, document.documentElement.firstChild);
  };

  try {
    chrome.storage.sync.get(DEFAULTS, (settings) => {
      if (!settings.enabled) return;
      if (host && settings.disabledHosts.includes(host)) return;
      const mode = settings.themeMode || 'auto';
      applyPalette(pickPalette(mode));
      inject(chrome.runtime.getURL('wallpaper-blur.jpg'), settings.strength || 'normal');
      if (mode === 'auto') {
        const refine = () => applyPalette(pickPalette(mode));
        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', refine, { once: true });
        } else {
          setTimeout(refine, 0);
        }
      }
    });
  } catch {
    /* chrome.storage is unavailable on some internal pages — leave them alone */
  }
})();

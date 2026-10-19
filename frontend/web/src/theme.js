/** Light/dark theme: stored per device, defaults to the phone's system setting.
 *  index.html applies it before React loads to avoid a flash. */
import { useCallback, useEffect, useState } from 'react';

const KEY = 'agrishield.theme';
const META = { light: '#e9f4ee', dark: '#0a1310' };

function current() {
  const t = document.documentElement.getAttribute('data-theme');
  return t === 'dark' ? 'dark' : 'light';
}

function apply(t) {
  document.documentElement.setAttribute('data-theme', t);
  const m = document.querySelector('meta[name="theme-color"]');
  if (m) m.setAttribute('content', META[t]);
}

export function useTheme() {
  const [theme, setTheme] = useState(current);

  useEffect(() => { apply(theme); }, [theme]);

  const toggle = useCallback(() => {
    setTheme((t) => {
      const next = t === 'dark' ? 'light' : 'dark';
      try { localStorage.setItem(KEY, next); } catch { /* private mode: still switches for this visit */ }
      return next;
    });
  }, []);

  return { theme, toggle };
}

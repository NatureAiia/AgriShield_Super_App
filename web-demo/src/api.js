/** Real API client for the AgriShield FastAPI backend.
 * Base URL comes from VITE_AGRISHIELD_API_URL (set on Vercel),
 * defaulting to local dev. Session = farmer record in localStorage. */

const BASE = (import.meta.env.VITE_AGRISHIELD_API_URL || 'http://localhost:8000').replace(/\/$/, '');
const SUPABASE_URL = 'https://flvurqihcfcibsxcxxpx.supabase.co';
const SUPABASE_KEY = 'sb_publishable_6SV_vyDXOhmbmmEmFpwz9w_iy1fjnNW';

export const apiBase = BASE;

async function req(path, opts = {}) {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json', ...(opts.headers || {}) },
    ...opts,
  });
  const text = await res.text();
  let body = null;
  try { body = text ? JSON.parse(text) : null; } catch { body = { detail: text }; }
  if (!res.ok) {
    const msg = body?.detail || `Request failed (${res.status})`;
    throw new Error(typeof msg === 'string' ? msg : JSON.stringify(msg));
  }
  return body;
}

export const api = {
  health: () => req('/health'),
  // SIGN UP: Bypass backend and write directly to Supabase via PostgREST
  signUp: async (f) => {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/farmers`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify(f),
    });
    if (!res.ok) {
      const err = await res.json();
      throw new Error(err.detail || 'Sign up failed');
    }
    return res.json();
  },
  // SIGN IN: Read directly from Supabase
  signIn: async (phone) => {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/farmers?phone=eq.${phone}&select=*`, {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
      },
    });
    const data = await res.json();
    if (!data || data.length === 0) throw new Error('No account for this phone number');
    return data[0];
  },
  updateFarmer: (id, f) => req(`/farmers/${id}`, { method: 'PATCH', body: JSON.stringify(f) }),
  readings: (farmerId) => req(`/storage/readings/${farmerId}`),
  logReading: (r) => req('/storage/readings', { method: 'POST', body: JSON.stringify(r) }),
  scans: (farmerId) => req(`/scans/${farmerId}`),
  logScan: (s) => req('/scans', { method: 'POST', body: JSON.stringify(s) }),
  diagnose: async (file) => {
    const form = new FormData();
    form.append('file', file);
    const res = await fetch(`${BASE}/scans/diagnose`, { method: 'POST', body: form });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.detail || `Diagnosis failed (${res.status})`);
    return body;
  },
  zones: () => req('/satellite/zones'),
  sendAlert: (farmer, message) => req('/alerts/send', { method: 'POST', body: JSON.stringify({ farmer, message }) }),
  crop: (inputs) => req('/recommendations/crop', { method: 'POST', body: JSON.stringify(inputs) }),
  fertilizer: (inputs) => req('/recommendations/fertilizer', { method: 'POST', body: JSON.stringify(inputs) }),
  weather: (lat, lon) => req(`/weather/current?lat=${lat}&lon=${lon}`),
  prices: () => req('/prices/vegetables'),
};

const KEY = 'agrishield.farmer';
export const session = {
  load: () => { try { return JSON.parse(localStorage.getItem(KEY)); } catch { return null; } },
  save: (f) => localStorage.setItem(KEY, JSON.stringify(f)),
  clear: () => localStorage.removeItem(KEY),
};


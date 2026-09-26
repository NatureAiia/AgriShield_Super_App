/**
 * AgriShield MVP webapp — wired to the real FastAPI backend.
 * Auth, storage readings, scans + server diagnosis, satellite zones,
 * crop/fertilizer advice, weather (Open-Meteo), alerts — all live API.
 * Satellite is mock-grid until GEE credentials exist; prices show the
 * backend's snapshot state honestly instead of invented numbers.
 */
import React, { useCallback, useEffect, useState } from 'react';
import {
  Shield, Thermometer, Camera, Map as MapIcon, Sprout, CloudRain,
  Phone, LogOut, MapPin, WifiOff, AlertTriangle, CheckCircle2, Leaf,
} from 'lucide-react';
import { api, apiBase, session } from './api.js';

const HARARE = { lat: -17.82, lon: 31.05 };
const TABS = [
  { id: 'home', label: 'Home', icon: Shield },
  { id: 'storage', label: 'Storage', icon: Thermometer },
  { id: 'scan', label: 'Scan', icon: Camera },
  { id: 'map', label: 'Map', icon: MapIcon },
  { id: 'advise', label: 'Advise', icon: Sprout },
];

function Err({ msg, clear }) {
  if (!msg) return null;
  return (
    <div className="alert" style={{ margin: '0 16px' }}>
      <AlertTriangle size={16} color="#fbbf24" />
      <div style={{ flex: 1 }}><p style={{ margin: 0 }}>{msg}</p></div>
      <button className="link" onClick={clear}>Dismiss</button>
    </div>
  );
}

function Field({ label, ...props }) {
  return (
    <label style={{ display: 'flex', flexDirection: 'column', gap: 4, fontSize: 12, color: '#94a3b8', fontWeight: 700 }}>
      {label}
      <input {...props} className="field" />
    </label>
  );
}

/* ---------------- Auth ---------------- */
function Landing({ onEnter }) {
  return (
    <div className="shell">
      <header className="topbar">
        <div className="brand">
          <div className="logo"><Shield size={22} /></div>
          <div><h1>AgriShield</h1><p>Climate & Yield Resilience</p></div>
        </div>
      </header>
      <main style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 24 }}>
        <div className="logo" style={{ width: 120, height: 120, fontSize: 60 }}><Shield size={80} color="#34d399" /></div>
        <div>
          <h2 className="name" style={{ fontSize: 28, margin: 0 }}>Keep your harvest safe</h2>
          <p className="sub" style={{ fontSize: 16, marginTop: 8 }}>On any phone, even with no signal.</p>
        </div>
        <button className="btn btn-green" style={{ padding: '16px 32px', fontSize: 18 }} onClick={onEnter}>Get Started</button>
        <p className="honesty" style={{ marginTop: 20 }}>V1 MVP: Storage, Scan, Satellite & Alerts</p>
      </main>
    </div>
  );
}

function Auth({ onDone }) {
  const [mode, setMode] = useState('in');
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState('');
  const [f, setF] = useState({ phone: '', name: '', location: 'Harare South', crop: 'Maize', storage_hub: 'Mbare Collection Point' });
  const set = (k) => (e) => setF({ ...f, [k]: e.target.value });

  const go = async () => {
    setBusy(true); setErr('');
    try {
      const farmer = mode === 'in' ? await api.signIn(f.phone.trim()) : await api.signUp({
        phone: f.phone.trim(), name: f.name.trim(), location: f.location.trim(),
        crop: f.crop.trim(), storage_hub: f.storage_hub.trim(),
      });
      session.save(farmer); onDone(farmer);
    } catch (e) { setErr(e.message); } finally { setBusy(false); }
  };

  return (
    <div className="shell">
      <header className="topbar">
        <div className="brand">
          <div className="logo"><Shield size={22} /></div>
          <div><h1>AgriShield</h1><p>Keep your harvest safe</p></div>
        </div>
      </header>
      <main>
        <Err msg={err} clear={() => setErr('')} />
        <div className="card">
          <span className="pill">MANGWANANI · PHONE SIGN-IN</span>
          <h2 className="name" style={{ fontSize: 20 }}>On any phone, even with no signal.</h2>
          <p className="sub">No password. Your phone number is your account.</p>
          <div style={{ display: 'flex', gap: 8, margin: '12px 0' }}>
            <button className={mode === 'in' ? 'btn btn-green' : 'btn btn-ghost'} style={{ flex: 1 }} onClick={() => setMode('in')}>Sign in</button>
            <button className={mode === 'up' ? 'btn btn-green' : 'btn btn-ghost'} style={{ flex: 1 }} onClick={() => setMode('up')}>Sign up</button>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <Field label="PHONE NUMBER" value={f.phone} onChange={set('phone')} placeholder="+263…" inputMode="tel" />
            {mode === 'up' && (
              <>
                <Field label="NAME" value={f.name} onChange={set('name')} placeholder="Tendai Moyo" />
                <Field label="LOCATION" value={f.location} onChange={set('location')} />
                <Field label="CROP" value={f.crop} onChange={set('crop')} />
                <Field label="STORAGE HUB" value={f.storage_hub} onChange={set('storage_hub')} />
              </>
            )}
            <button className="btn btn-green" disabled={busy || !f.phone.trim()} onClick={go}>
              {busy ? 'Please wait…' : mode === 'in' ? 'Sign in' : 'Create account'}
            </button>
          </div>
        </div>
        <p className="honesty">API: {apiBase} · farmer record syncs to Postgres in prod, local SQLite in dev.</p>
      </main>
    </div>
  );
}

/* ---------------- App ---------------- */
export default function App() {
  const [farmer, setFarmer] = useState(() => session.load());
  const [showLanding, setShowLanding] = useState(!farmer);
  const [tab, setTab] = useState('home');
  const [err, setErr] = useState('');
  const [readings, setReadings] = useState([]);
  const [scans, setScans] = useState([]);
  const [zones, setZones] = useState([]);
  const [weather, setWeather] = useState(null);
  const [prices, setPrices] = useState(null);
  const [busy, setBusy] = useState(false);
  const [alertOut, setAlertOut] = useState(null);
  const [diag, setDiag] = useState(null);
  const [cropOut, setCropOut] = useState(null);
  const [fertOut, setFertOut] = useState(null);
  const [selZone, setSelZone] = useState(null);

  const fail = (e) => setErr(e.message || String(e));

  const refresh = useCallback(async () => {
    if (!farmer) return;
    try {
      const [r, s, z, w, p] = await Promise.all([
        api.readings(farmer.id).catch(() => []),
        api.scans(farmer.id).catch(() => []),
        api.zones().catch(() => []),
        api.weather(HARARE.lat, HARARE.lon).catch(() => null),
        api.prices().catch(() => null),
      ]);
      setReadings(r); setScans(s); setZones(z); setWeather(w); setPrices(p);
    } catch (e) { fail(e); }
  }, [farmer]);

  useEffect(() => { refresh(); }, [refresh]);

  if (showLanding) return <Landing onEnter={() => setShowLanding(false)} />;
  if (!farmer) return <Auth onDone={setFarmer} />;
  const latest = readings[0];

  const logReading = async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    setBusy(true); setErr('');
    try {
      await api.logReading({
        farmer_id: farmer.id,
        temperature_c: parseFloat(fd.get('t')),
        humidity_percent: parseFloat(fd.get('h')),
        co2_ppm: parseFloat(fd.get('c') || '420'),
      });
      e.target.reset(); await refresh();
    } catch (e2) { fail(e2); } finally { setBusy(false); }
  };

  const runDiagnose = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setBusy(true); setErr(''); setDiag(null);
    try {
      const d = await api.diagnose(file);
      setDiag(d);
      await api.logScan({ farmer_id: farmer.id, likely_issue: d.likely_issue, confidence: 0.8, source: 'server' });
      await refresh();
    } catch (e2) { fail(e2); } finally { setBusy(false); }
  };

  const sendAlert = async () => {
    setBusy(true); setErr(''); setAlertOut(null);
    try {
      const msg = latest
        ? `Your ${farmer.crop} has ~${latest.temperature_c.toFixed(0)}°C / ${latest.humidity_percent.toFixed(0)}% humidity in store — check it today.`
        : `AgriShield check-in for your ${farmer.crop} — all quiet.`;
      setAlertOut(await api.sendAlert(farmer, msg));
    } catch (e2) { fail(e2); } finally { setBusy(false); }
  };

  const runCrop = async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    setBusy(true); setErr('');
    try {
      setCropOut(await api.crop({
        nitrogen: +fd.get('n'), phosphorous: +fd.get('p'), potassium: +fd.get('k'),
        ph: +fd.get('ph'), rainfall: +fd.get('r'), temperature: +fd.get('t'), humidity: +fd.get('h'),
      }));
    } catch (e2) { fail(e2); } finally { setBusy(false); }
  };

  const runFert = async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    setBusy(true); setErr('');
    try {
      setFertOut(await api.fertilizer({
        crop: fd.get('crop'), nitrogen: +fd.get('n'), phosphorous: +fd.get('p'), potassium: +fd.get('k'),
      }));
    } catch (e2) { fail(e2); } finally { setBusy(false); }
  };

  const zoneColor = (s) => s === 'healthy' ? '#2D6A4F' : s === 'stressed' ? '#D97706' : '#B45309';

  return (
    <div className="shell">
      <header className="topbar">
        <div className="brand">
          <div className="logo"><Shield size={22} /></div>
          <div><h1>AgriShield</h1><p>{farmer.name} · {farmer.location}</p></div>
        </div>
        <button className="link" onClick={() => { session.clear(); setFarmer(null); }} title="Sign out">
          <LogOut size={15} /> Sign out
        </button>
      </header>

      <div className="offline"><WifiOff size={14} /><span>Offline-first — readings queue on the phone, sync here</span></div>

      <div style={{ height: 10 }} />
      <Err msg={err} clear={() => setErr('')} />

      <main>
        {tab === 'home' && (
          <div className="fadein" style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div className="card">
              <span className="pill"><span className="live-dot" />LIVE · {farmer.crop.toUpperCase()} · {farmer.storage_hub}</span>
              {latest ? (
                <div style={{ display: 'flex', gap: 14, marginTop: 10 }}>
                  <div><small className="sub">TEMP</small><div className="big-num" style={{ fontSize: 34 }}>{latest.temperature_c.toFixed(0)}°C</div></div>
                  <div><small className="sub">HUMIDITY</small><div className="big-num" style={{ fontSize: 34 }}>{latest.humidity_percent.toFixed(0)}%</div></div>
                  <div><small className="sub">CO₂</small><div className="big-num" style={{ fontSize: 34 }}>{latest.co2_ppm.toFixed(0)}</div></div>
                </div>
              ) : (
                <p className="sub" style={{ marginTop: 10 }}>No readings yet — log the first one in Storage.</p>
              )}
              <div className="grid2" style={{ marginTop: 12 }}>
                <button className="btn btn-green" disabled={busy} onClick={sendAlert}><Phone size={15} /> Alert me now</button>
                <button className="btn btn-ghost" onClick={refresh}>Refresh</button>
              </div>
              {alertOut && (
                <div className="mini" style={{ marginTop: 10 }}>
                  <small>{alertOut.sent ? 'ALERT ACCEPTED' : 'ALERT QUEUED'} · {alertOut.channel}</small>
                  <b style={{ fontSize: 12, display: 'block', marginTop: 4 }}>{alertOut.detail}</b>
                </div>
              )}
            </div>

            <div className="card plain">
              <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                <CloudRain size={18} color="#38bdf8" />
                <b>Weather — Harare ({HARARE.lat}, {HARARE.lon})</b>
              </div>
              {weather ? (
                <>
                  <div className="grid3" style={{ marginTop: 10 }}>
                    <div className="mini"><small>TEMP</small><b>{weather.temperature_c?.toFixed(1)}°C</b></div>
                    <div className="mini"><small>HUMIDITY</small><b>{weather.humidity_percent?.toFixed(0)}%</b></div>
                    <div className="mini"><small>RAIN 24H</small><b>{weather.rain_mm_24h?.toFixed(1)}mm</b></div>
                  </div>
                  <p className="sub" style={{ marginTop: 8 }}>{weather.advice}</p>
                  <p className="honesty" style={{ textAlign: 'left' }}>Source: {weather.data_source}</p>
                </>
              ) : <p className="sub">Weather unavailable — check connection.</p>}
            </div>

            <div className="card plain">
              <b style={{ fontSize: 13 }}>Recent scans ({scans.length})</b>
              {scans.slice(0, 3).map((s) => (
                <div key={s.id} className="mini" style={{ marginTop: 8 }}>
                  <small>{s.source} · {(s.confidence * 100).toFixed(0)}%</small>
                  <b style={{ fontSize: 13, display: 'block' }}>{s.likely_issue}</b>
                </div>
              ))}
              {!scans.length && <p className="sub">No scans yet.</p>}
            </div>
          </div>
        )}

        {tab === 'storage' && (
          <div className="fadein" style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <form className="card plain" onSubmit={logReading}>
              <b>Log a sensor reading</b>
              <div className="grid3" style={{ marginTop: 10, textAlign: 'left' }}>
                <Field label="TEMP °C" name="t" type="number" step="0.1" required placeholder="31" />
                <Field label="HUMIDITY %" name="h" type="number" step="0.1" required placeholder="68" />
                <Field label="CO₂ PPM" name="c" type="number" step="1" placeholder="430" />
              </div>
              <button className="btn btn-green" style={{ width: '100%', marginTop: 12 }} disabled={busy}>
                {busy ? 'Saving…' : 'Save reading'}
              </button>
            </form>
            {readings.map((r) => (
              <div key={r.id} className="mini">
                <small>{new Date(r.taken_at).toLocaleString()}</small>
                <b>{r.temperature_c.toFixed(1)}°C · {r.humidity_percent.toFixed(0)}% · {r.co2_ppm.toFixed(0)}ppm</b>
              </div>
            ))}
            {!readings.length && <p className="sub">No readings synced yet.</p>}
          </div>
        )}

        {tab === 'scan' && (
          <div className="fadein" style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div className="viewport">
              <div>
                <div style={{ width: 72, height: 72, borderRadius: 999, background: 'rgba(52,211,153,.12)', display: 'grid', placeItems: 'center', margin: '0 auto 10px', color: '#34d399' }}>
                  <Leaf size={30} />
                </div>
                <small style={{ color: '#cbd5e1', fontWeight: 700 }}>Upload a leaf photo for server diagnosis</small><br /><br />
                <label className="btn btn-green" style={{ cursor: 'pointer' }}>
                  <Camera size={15} /> {busy ? 'Diagnosing…' : 'Choose photo'}
                  <input type="file" accept="image/*" hidden onChange={runDiagnose} disabled={busy} />
                </label>
              </div>
            </div>
            {diag && (
              <div className="card result fadein">
                <span className="pill"><CheckCircle2 size={11} /> SERVER DIAGNOSIS</span>
                <b style={{ display: 'block', marginTop: 8, fontSize: 16 }}>{diag.likely_issue}</b>
                <p className="sub" style={{ marginTop: 6 }}>{diag.advice}</p>
                <p className="honesty" style={{ textAlign: 'left' }}>Logged to your record as a server scan. First opinion — confirm with an extension officer.</p>
              </div>
            )}
            {scans.map((s) => (
              <div key={s.id} className="mini">
                <small>{s.source} · {(s.confidence * 100).toFixed(0)}% · {new Date(s.scanned_at).toLocaleDateString()}</small>
                <b style={{ display: 'block' }}>{s.likely_issue}</b>
              </div>
            ))}
          </div>
        )}

        {tab === 'map' && (
          <div className="fadein" style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div className="card plain">
              <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                <MapPin size={16} color="#34d399" /><b>Mashonaland East · district view</b>
              </div>
              <div className="zones" style={{ marginTop: 12 }}>
                {zones.map((z, i) => (
                  <button key={z.id} className="zone" style={{ background: zoneColor(z.status), outline: z.is_farmer_plot ? '3px solid #fff' : 'none', outlineOffset: 2 }} onClick={() => setSelZone(z)}>
                    {z.is_farmer_plot ? 'YOU' : ''}
                  </button>
                ))}
              </div>
              <div className="legend" style={{ marginTop: 10 }}>
                <span><span className="dot" style={{ background: '#2D6A4F' }} />Healthy</span>
                <span><span className="dot" style={{ background: '#D97706' }} />Stressed</span>
                <span><span className="dot" style={{ background: '#B45309' }} />Drought risk</span>
              </div>
              {selZone && <p className="sub" style={{ marginTop: 8 }}>Zone {selZone.id} — {selZone.status}{selZone.is_farmer_plot ? ' (your plot)' : ''}.</p>}
              <p className="honesty" style={{ textAlign: 'left' }}>Mock grid until GEE credentials are configured on the backend.</p>
            </div>
          </div>
        )}

        {tab === 'advise' && (
          <div className="fadein" style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <form className="card plain" onSubmit={runCrop}>
              <b>Crop recommendation</b>
              <div className="grid3" style={{ marginTop: 10, textAlign: 'left' }}>
                <Field label="N" name="n" type="number" step="any" required placeholder="90" />
                <Field label="P" name="p" type="number" step="any" required placeholder="42" />
                <Field label="K" name="k" type="number" step="any" required placeholder="43" />
              </div>
              <div className="grid3" style={{ marginTop: 8, textAlign: 'left' }}>
                <Field label="pH" name="ph" type="number" step="any" required placeholder="6.5" />
                <Field label="RAIN MM" name="r" type="number" step="any" required placeholder="200" />
                <Field label="TEMP °C" name="t" type="number" step="any" required placeholder="25" />
              </div>
              <div style={{ marginTop: 8, textAlign: 'left' }}>
                <Field label="HUMIDITY %" name="h" type="number" step="any" required placeholder="80" />
              </div>
              <button className="btn btn-green" style={{ width: '100%', marginTop: 12 }} disabled={busy}>Recommend crop</button>
            </form>
            {cropOut && (
              <div className="card fadein">
                <span className="pill">TOP PICK · {cropOut.crop}</span>
                {cropOut.suggestions?.map((s) => (
                  <div key={s.crop} style={{ marginTop: 8 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}><span>{s.crop}</span><b>{(s.confidence * 100).toFixed(0)}%</b></div>
                    <div className="confbar"><div style={{ width: `${s.confidence * 100}%` }} /></div>
                  </div>
                ))}
                <p className="honesty" style={{ textAlign: 'left' }}>{cropOut.limitations}</p>
              </div>
            )}
            <form className="card plain" onSubmit={runFert}>
              <b>Fertilizer advice</b>
              <div className="grid3" style={{ marginTop: 10, textAlign: 'left' }}>
                <Field label="CROP" name="crop" required placeholder="maize" />
                <Field label="N" name="n" type="number" step="any" required placeholder="90" />
                <Field label="P" name="p" type="number" step="any" required placeholder="42" />
              </div>
              <div style={{ marginTop: 8, textAlign: 'left' }}>
                <Field label="K" name="k" type="number" step="any" required placeholder="43" />
              </div>
              <button className="btn btn-ghost" style={{ width: '100%', marginTop: 12 }} disabled={busy}>Get fertilizer advice</button>
            </form>
            {fertOut && (
              <div className="mini fadein"><small>{fertOut.nutrient} · {fertOut.direction}</small><b style={{ display: 'block' }}>{fertOut.advice}</b></div>
            )}
            <div className="card plain">
              <b style={{ fontSize: 13 }}>Vegetable prices</b>
              {prices?.prices?.length ? prices.prices.map((p, i) => (
                <div key={i} className="mini" style={{ marginTop: 8 }}><b>{p.commodity} · {p.market}</b><small>${p.price_usd_per_kg}/kg · {p.observed}</small></div>
              )) : <p className="sub">No snapshot published yet.</p>}
              {prices && <p className="honesty" style={{ textAlign: 'left' }}>{prices.data_source}</p>}
            </div>
          </div>
        )}
      </main>

      <nav className="bottom">
        {TABS.map((t) => (
          <button key={t.id} className={tab === t.id ? 'active' : ''} onClick={() => setTab(t.id)}>
            <t.icon size={20} /><span>{t.label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}

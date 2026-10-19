/**
 * AgriShield MVP webapp — wired to the real FastAPI backend.
 * Auth, storage readings, scans + server diagnosis, satellite zones,
 * crop/fertilizer advice, weather (Open-Meteo), alerts — all live API.
 * Satellite is mock-grid until GEE credentials exist; prices show the
 * backend's snapshot state honestly instead of invented numbers.
 *
 * UI: soft "modern farming" design with light/dark theme (theme.js),
 * logo splash screen, and offline SVG illustrations (FieldArt.jsx).
 */
import React, { useCallback, useEffect, useState } from 'react';
import brandLogo from '../../assets/logo/1.jpeg';
import {
  House, Thermometer, Camera, Map as MapIcon, Sprout, Phone, LogOut, MapPin,
  WifiOff, AlertTriangle, CheckCircle2, Leaf, Sun, Moon, Bell, ChevronRight,
  ArrowRight, ArrowLeft, ArrowUpRight, Droplets, CloudSun, RefreshCw, User,
  ShieldCheck, Pencil, Stethoscope, Info,
} from 'lucide-react';
import { api, apiBase, session } from './api.js';
import { useTheme } from './theme.js';
import FieldArt from './FieldArt.jsx';

const HARARE = { lat: -17.82, lon: 31.05 };
const TABS = [
  { id: 'home', label: 'Home', icon: House },
  { id: 'storage', label: 'Storage', icon: Thermometer },
  { id: 'scan', label: 'Scan', icon: Camera },
  { id: 'map', label: 'Map', icon: MapIcon },
  { id: 'advise', label: 'Advise', icon: Sprout },
  { id: 'profile', label: 'Profile', icon: User },
];
const TITLES = { storage: 'Crop Storage', scan: 'Leaf Scan', map: 'Satellite View', advise: 'Farm Advice', profile: 'My Profile' };

const plural = (n, w) => `${n} ${w}${n === 1 ? '' : 's'}`;
const initials = (name = '') => name.trim().split(/\s+/).slice(0, 2).map((w) => w[0]?.toUpperCase()).join('') || 'A';
const greeting = () => {
  const h = new Date().getHours();
  return h < 12 ? 'Mangwanani · Good morning' : h < 17 ? 'Masikati · Good afternoon' : 'Manheru · Good evening';
};

/* ---------------- Small building blocks ---------------- */
function ThemeButton({ theme, toggle }) {
  return (
    <button className="icon-btn" onClick={toggle} title={theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'} aria-label="Toggle theme">
      {theme === 'dark' ? <Sun size={19} /> : <Moon size={19} />}
    </button>
  );
}

function Err({ msg, clear }) {
  if (!msg) return null;
  return (
    <div className="alert fadein">
      <AlertTriangle size={17} />
      <p>{msg}</p>
      <button className="link" onClick={clear}>Dismiss</button>
    </div>
  );
}

function Field({ label, ...props }) {
  return (
    <label className="lbl">
      {label}
      <input {...props} className="field" />
    </label>
  );
}

function Dots({ value, max = 100, n = 16 }) {
  const on = Math.round((Math.min(Math.max(value, 0), max) / max) * n);
  return <div className="dots">{Array.from({ length: n }, (_, i) => <i key={i} className={i < on ? 'on' : ''} />)}</div>;
}

function ActionRow({ icon: Icon, tone = '', title, sub, onClick, disabled }) {
  return (
    <button className="row" onClick={onClick} disabled={disabled}>
      <span className={`ic ${tone}`}><Icon size={20} /></span>
      <span className="txt"><b>{title}</b><small>{sub}</small></span>
      <ChevronRight size={18} className="chev" />
    </button>
  );
}

/* ---------------- Splash (loading) ---------------- */
function Splash({ leaving }) {
  return (
    <div className={`splash ${leaving ? 'out' : ''}`} role="status" aria-label="Loading AgriShield">
      <div className="splash-logo"><img src={brandLogo} alt="AgriShield logo" /></div>
      <h1>AgriShield</h1>
      <p>Keep your harvest safe</p>
      <div className="splash-bar"><div /></div>
    </div>
  );
}

/* ---------------- Onboarding ---------------- */
function Landing({ onEnter, theme, toggle }) {
  return (
    <div className="shell no-nav" style={{ paddingBottom: 0 }}>
      <div className="onboard">
        <FieldArt variant="sunrise" />
        <div className="onboard-top">
          <div className="onboard-brand"><img src={brandLogo} alt="" />AgriShield</div>
          <ThemeButton theme={theme} toggle={toggle} />
        </div>
        <div className="onboard-body fadein">
          <h2>Protecting the Future of Zimbabwe's Harvests</h2>
          <p>Storage monitoring, leaf disease screening and satellite field checks — built for smallholder farmers, even with no signal.</p>
          <ul className="onboard-feats">
            <li><Thermometer size={18} /><span><b>Crop storage</b>Live temperature, humidity and CO₂ with mold-risk alerts</span></li>
            <li><Leaf size={18} /><span><b>Leaf scan</b>Photo-based disease check with treatment steps</span></li>
            <li><MapIcon size={18} /><span><b>Satellite view</b>Field health and drought risk across your district</span></li>
          </ul>
          <button className="slide-btn" onClick={onEnter}>
            <span className="knob"><ArrowRight size={20} /></span>
            <span className="lbl-txt">Get Started</span>
            <span className="chevs"><ChevronRight size={18} /><ChevronRight size={18} /><ChevronRight size={18} /></span>
          </button>
        </div>
      </div>
    </div>
  );
}

/* ---------------- Auth ---------------- */
function Auth({ onDone, onBack, theme, toggle }) {
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
    } catch (e) {
      const m = e.message || String(e);
      setErr(m === 'Failed to fetch' ? `Can't reach the AgriShield server at ${apiBase}. Is the backend running?` : m);
    } finally { setBusy(false); }
  };

  return (
    <div className="shell no-nav">
      <div className="auth-hero">
        <FieldArt variant="day" />
        <div className="onboard-top">
          <button className="icon-btn" onClick={onBack} aria-label="Back"><ArrowLeft size={19} /></button>
          <ThemeButton theme={theme} toggle={toggle} />
        </div>
      </div>
      <div className="auth-sheet stack fadein">
        <div className="card stack">
          <div className="who">
            <img src={brandLogo} alt="" style={{ width: 46, height: 46, borderRadius: 999 }} />
            <div><small>Welcome to</small><b>AgriShield</b></div>
          </div>
          <p className="sub">No password needed — your phone number is your account.</p>
          <div className="seg">
            <button className={mode === 'in' ? 'on' : ''} onClick={() => setMode('in')}>Sign in</button>
            <button className={mode === 'up' ? 'on' : ''} onClick={() => setMode('up')}>Sign up</button>
          </div>
          <Field label="Phone number" value={f.phone} onChange={set('phone')} placeholder="+263 77 123 4567" inputMode="tel" />
          {mode === 'up' && (
            <div className="stack fadein">
              <Field label="Full name" value={f.name} onChange={set('name')} placeholder="Tendai Moyo" />
              <Field label="Location" value={f.location} onChange={set('location')} />
              <div className="grid2">
                <Field label="Main crop" value={f.crop} onChange={set('crop')} />
                <Field label="Storage hub" value={f.storage_hub} onChange={set('storage_hub')} />
              </div>
            </div>
          )}
          <Err msg={err} clear={() => setErr('')} />
          <button className="btn btn-primary btn-block" disabled={busy || !f.phone.trim() || (mode === 'up' && !f.name.trim())} onClick={go}>
            {busy ? 'Please wait…' : mode === 'in' ? 'Sign in' : 'Create account'} {!busy && <ArrowRight size={17} />}
          </button>
        </div>
        <p className="note">Server: {apiBase}</p>
      </div>
    </div>
  );
}

/* ---------------- App ---------------- */
export default function App() {
  const { theme, toggle } = useTheme();
  const [splash, setSplash] = useState('in'); // 'in' → 'out' → 'done'
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
  const [preview, setPreview] = useState(null);
  const [cropOut, setCropOut] = useState(null);
  const [fertOut, setFertOut] = useState(null);
  const [selZone, setSelZone] = useState(null);
  const [editF, setEditF] = useState(false);
  const [adviseTab, setAdviseTab] = useState('crop');

  useEffect(() => {
    const a = setTimeout(() => setSplash('out'), 1700);
    const b = setTimeout(() => setSplash('done'), 2250);
    return () => { clearTimeout(a); clearTimeout(b); };
  }, []);

  const fail = (e) => {
    const m = e.message || String(e);
    setErr(m === 'Failed to fetch' ? `Can't reach the AgriShield server at ${apiBase}.` : m);
  };

  const refresh = useCallback(async () => {
    if (!farmer || !farmer.id) return;
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
  useEffect(() => { window.scrollTo({ top: 0 }); }, [tab]);

  const splashEl = splash !== 'done' ? <Splash leaving={splash === 'out'} /> : null;

  if (showLanding) return <>{splashEl}<Landing onEnter={() => setShowLanding(false)} theme={theme} toggle={toggle} /></>;
  if (!farmer) return <>{splashEl}<Auth onDone={setFarmer} onBack={() => setShowLanding(true)} theme={theme} toggle={toggle} /></>;
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
    e.target.value = ''; // let the same photo be picked again
    setBusy(true); setErr(''); setDiag(null);
    setPreview((old) => { if (old) URL.revokeObjectURL(old); return URL.createObjectURL(file); });
    try {
      const d = await api.diagnose(file);
      setDiag(d);
      await api.logScan({ farmer_id: farmer.id, likely_issue: d.likely_issue, confidence: d.confidence ?? 0.8, source: 'server' });
      await refresh();
    } catch (e2) {
      const m = e2.message || '';
      setErr(m === 'Method Not Allowed'
        ? "Leaf diagnosis isn't switched on for this server yet. In the backend folder run: pip install -r requirements-ml.txt — then restart it."
        : m === 'Failed to fetch' ? `Can't reach the AgriShield server at ${apiBase}.` : m);
    } finally { setBusy(false); }
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

  const saveProfile = async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    setBusy(true); setErr('');
    try {
      const updated = await api.updateFarmer(farmer.id, {
        name: fd.get('name'), location: fd.get('location'),
        crop: fd.get('crop'), storage_hub: fd.get('storage_hub'),
      });
      session.save(updated);
      setFarmer(updated);
      setEditF(false);
    } catch (e2) { fail(e2); } finally { setBusy(false); }
  };

  const signOut = () => { session.clear(); setFarmer(null); setTab('home'); };
  const zoneColor = (s) => s === 'healthy' ? '#3f8a4f' : s === 'stressed' ? '#d99a2b' : '#c2410c';
  const storageRisk = latest ? (latest.humidity_percent > 70 || latest.temperature_c > 30 ? 'Check store' : 'Healthy') : 'No data';

  return (
    <div className="shell">
      {splashEl}

      {tab === 'home' ? (
        <header className="header">
          <div className="who">
            <div className="avatar">{initials(farmer.name)}</div>
            <div style={{ minWidth: 0 }}><small>{greeting()}</small><b>{farmer.name}</b></div>
          </div>
          <div className="header-actions">
            <ThemeButton theme={theme} toggle={toggle} />
            <button className="icon-btn" onClick={sendAlert} disabled={busy} title="Send me an alert now" aria-label="Alerts"><Bell size={19} /></button>
          </div>
        </header>
      ) : (
        <header className="page-head">
          <button className="icon-btn back" onClick={() => setTab('home')} aria-label="Back to home"><ArrowLeft size={19} /></button>
          <h1>{TITLES[tab]}</h1>
          <ThemeButton theme={theme} toggle={toggle} />
        </header>
      )}

      <main>
        <Err msg={err} clear={() => setErr('')} />

        {/* ---------------- HOME ---------------- */}
        {tab === 'home' && (
          <div className="stack home fadein">
            <div className="hero b-hero">
              <FieldArt variant="day" />
              <div className="hero-content">
                <span className="hero-tag"><span className="live-dot" style={{ color: 'var(--primary)' }} />{farmer.crop} · {farmer.storage_hub}</span>
              </div>
              <div className="stat-row">
                <div className="stat leaf"><small>Storage</small><b>{storageRisk}</b><span className="stat-ic"><ShieldCheck size={17} /></span></div>
                <div className="stat sun"><small>Weather</small><b>{weather ? `${weather.temperature_c?.toFixed(0)}°C` : '—'}</b><span className="stat-ic"><CloudSun size={17} /></span></div>
                <div className="stat sky"><small>Humidity</small><b>{latest ? `${latest.humidity_percent.toFixed(0)}%` : weather ? `${weather.humidity_percent?.toFixed(0)}%` : '—'}</b><span className="stat-ic"><Droplets size={17} /></span></div>
              </div>
            </div>

            <div className="offline-strip b-strip"><WifiOff size={14} />Works offline — data syncs when you're back online</div>

            <div className="block b-services">
            <div className="section-title"><h2>Your services</h2><span>{farmer.location}</span></div>
            <div className="hscroll">
              <button className="svc" onClick={() => setTab('storage')}>
                <div className="svc-art"><FieldArt variant="storage" /><span className="badge">{plural(readings.length, 'log')}</span></div>
                <b>Crop Storage</b><span>Temp & humidity</span>
              </button>
              <button className="svc" onClick={() => setTab('scan')}>
                <div className="svc-art"><FieldArt variant="leaf" /><span className="badge">{plural(scans.length, 'scan')}</span></div>
                <b>Leaf Scan</b><span>Disease screening</span>
              </button>
              <button className="svc" onClick={() => setTab('map')}>
                <div className="svc-art"><FieldArt variant="map" /><span className="badge">{plural(zones.length, 'zone')}</span></div>
                <b>Satellite View</b><span>Field health</span>
              </button>
              <button className="svc" onClick={() => setTab('advise')}>
                <div className="svc-art"><FieldArt variant="wheat" /><span className="badge">Advice</span></div>
                <b>Farm Advice</b><span>Crops & fertilizer</span>
              </button>
            </div>
            </div>

            <div className="block b-actions">
            <div className="section-title"><h2>Instant actions</h2></div>
            <div className="list">
              <ActionRow icon={Phone} title={busy ? 'Sending…' : 'Alert me now'} sub="SMS / voice check on your store" onClick={sendAlert} disabled={busy} />
              <ActionRow icon={Thermometer} tone="sun" title="Log a storage reading" sub="Temperature, humidity, CO₂" onClick={() => setTab('storage')} />
              <ActionRow icon={Camera} tone="sky" title="Scan a leaf" sub="Get a first-opinion diagnosis" onClick={() => setTab('scan')} />
              <ActionRow icon={RefreshCw} title="Refresh data" sub="Pull the latest from the server" onClick={refresh} />
            </div>

            {alertOut && (
              <div className="card fadein">
                <span className="pill">{alertOut.sent ? 'Alert accepted' : 'Alert queued'} · {alertOut.channel}</span>
                <p className="sub" style={{ marginTop: 8 }}>{alertOut.detail}</p>
              </div>
            )}
            </div>

            <div className="card b-weather">
              <div className="card-head">
                <span className="ic" style={{ background: 'var(--chip-sky)', color: 'var(--sky-ink)' }}><CloudSun size={19} /></span>
                <div><h3>Weather · Harare</h3><small>{HARARE.lat}, {HARARE.lon}</small></div>
              </div>
              {weather ? (
                <>
                  <div className="metrics">
                    <div className="metric"><small>Temp</small><b>{weather.temperature_c?.toFixed(1)}°</b></div>
                    <div className="metric"><small>Humidity</small><b>{weather.humidity_percent?.toFixed(0)}%</b></div>
                    <div className="metric"><small>Rain 24h</small><b>{weather.rain_mm_24h?.toFixed(1)}<span style={{ fontSize: 11 }}>mm</span></b></div>
                  </div>
                  <p className="sub" style={{ marginTop: 10 }}>{weather.advice}</p>
                  <p className="note" style={{ justifyContent: 'flex-start', marginTop: 6 }}>Source: {weather.data_source}</p>
                </>
              ) : <p className="sub">Weather unavailable — check your connection.</p>}
            </div>

            <div className="block b-scans">
            <div className="section-title"><h2>Recent scans</h2>{scans.length > 0 && <button onClick={() => setTab('scan')}>See all</button>}</div>
            {scans.length ? (
              <div className="tiles">
                {scans.slice(0, 4).map((s) => (
                  <div className="tile" key={s.id}>
                    <div className="svc-art"><FieldArt variant="leaf" /><span className="badge">{(s.confidence * 100).toFixed(0)}%</span></div>
                    <b>{s.likely_issue}</b>
                    <Dots value={s.confidence * 100} n={12} />
                    <div className="tile-foot"><small>{s.source}</small><span className="mini-arrow"><ArrowUpRight size={14} /></span></div>
                  </div>
                ))}
              </div>
            ) : <div className="card"><p className="sub">No scans yet — try scanning a leaf.</p></div>}
            </div>
          </div>
        )}

        {/* ---------------- STORAGE ---------------- */}
        {tab === 'storage' && (
          <div className="stack page fadein">
            <div className="hero short">
              <FieldArt variant="storage" />
              <div className="hero-content"><span className="hero-tag"><MapPin size={12} />{farmer.storage_hub}</span></div>
            </div>
            <div className="card stack">
              <div className="card-head" style={{ marginBottom: 0 }}>
                <span className="ic"><ShieldCheck size={19} /></span>
                <div style={{ flex: 1 }}><h3>{farmer.crop} in store</h3><small>{latest ? new Date(latest.taken_at).toLocaleString() : 'No readings yet'}</small></div>
                <span className={`pill ${latest ? 'solid' : ''}`}>{storageRisk}</span>
              </div>
              {latest && (
                <div className="panel">
                  <div className="big-num">{latest.temperature_c.toFixed(0)}<small>°C</small></div>
                  <div style={{ flex: 1 }}>
                    <small className="sub"><b style={{ color: 'var(--text)' }}>{latest.humidity_percent.toFixed(0)}%</b> humidity · {latest.co2_ppm.toFixed(0)} ppm CO₂</small>
                    <Dots value={latest.humidity_percent} />
                  </div>
                </div>
              )}
            </div>
            <form className="card stack" onSubmit={logReading}>
              <h3>Log a sensor reading</h3>
              <div className="grid3">
                <Field label="Temp °C" name="t" type="number" step="0.1" required placeholder="31" />
                <Field label="Humidity %" name="h" type="number" step="0.1" required placeholder="68" />
                <Field label="CO₂ ppm" name="c" type="number" step="1" placeholder="430" />
              </div>
              <button className="btn btn-primary btn-block" disabled={busy}>{busy ? 'Saving…' : 'Save reading'}</button>
            </form>
            {readings.length > 0 && (
              <div className="block">
              <div className="section-title"><h2>History</h2><span>{plural(readings.length, 'reading')}</span></div>
              <div className="list">
                {readings.map((r) => (
                  <div key={r.id} className="row" style={{ cursor: 'default' }}>
                    <span className="ic sun"><Thermometer size={18} /></span>
                    <span className="txt"><b>{r.temperature_c.toFixed(1)}°C · {r.humidity_percent.toFixed(0)}% · {r.co2_ppm.toFixed(0)} ppm</b><small>{new Date(r.taken_at).toLocaleString()}</small></span>
                  </div>
                ))}
              </div>
              </div>
            )}
          </div>
        )}

        {/* ---------------- SCAN ---------------- */}
        {tab === 'scan' && (
          <div className="stack page fadein">
            <div className="viewport" style={preview ? { padding: 0, minHeight: 260 } : undefined}>
              {preview && <img className="art" src={preview} alt="Your leaf photo" />}
              {busy && <div className="scanline" style={{ zIndex: 2 }} />}
              {!preview ? (
                <div>
                  <div className="scan-ic"><Leaf size={32} /></div>
                  <h3 style={{ margin: '0 0 4px' }}>Check a leaf</h3>
                  <p className="sub" style={{ marginBottom: 16 }}>Take or upload a clear photo of one leaf, in daylight, filling the frame.</p>
                  <label className="btn btn-primary" style={{ cursor: 'pointer' }}>
                    <Camera size={17} /> Choose photo
                    <input type="file" accept="image/*" capture="environment" hidden onChange={runDiagnose} disabled={busy} />
                  </label>
                </div>
              ) : (
                <label className="btn btn-primary" style={{ cursor: 'pointer', position: 'absolute', bottom: 14, zIndex: 3 }}>
                  <Camera size={17} /> {busy ? 'Analysing leaf…' : 'Scan another leaf'}
                  <input type="file" accept="image/*" capture="environment" hidden onChange={runDiagnose} disabled={busy} />
                </label>
              )}
            </div>

            {diag && (
              <div className="card stack fadein">
                <div className="card-head" style={{ marginBottom: 0 }}>
                  <span className="ic" style={diag.healthy ? undefined : { background: 'var(--chip-sun)', color: 'var(--sun-ink)' }}>
                    {diag.healthy ? <CheckCircle2 size={20} /> : <Stethoscope size={20} />}
                  </span>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <small>{diag.crop || 'Leaf'}</small>
                    <h3>{diag.healthy ? 'Looks healthy' : (diag.disease || diag.likely_issue)}</h3>
                  </div>
                  {diag.confidence != null && <span className={`pill ${diag.low_confidence ? '' : 'solid'}`}>{Math.round(diag.confidence * 100)}%</span>}
                </div>

                {diag.confidence != null && (
                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
                      <span className="sub">How sure the model is</span>
                      <b>{diag.confidence >= 0.85 ? 'Likely match' : diag.confidence >= 0.7 ? 'Possible match' : 'Not sure'}</b>
                    </div>
                    <div className="confbar"><div style={{ width: `${diag.confidence * 100}%` }} /></div>
                  </div>
                )}

                {diag.low_confidence && (
                  <div className="alert"><Info size={17} /><p>The model isn't sure. Retake the photo closer, in daylight, with one leaf filling the frame — or ask an extension officer.</p></div>
                )}

                {diag.healthy && <p className="sub">No disease found on this leaf. Keep checking your plants every week, especially after rain.</p>}

                {!diag.healthy && diag.treatment?.length > 0 && (
                  <div>
                    <h3 style={{ fontSize: 14 }}>What to do</h3>
                    <ol className="steps">{diag.treatment.map((t, i) => <li key={i}>{t}</li>)}</ol>
                  </div>
                )}

                {!diag.healthy && diag.causes?.length > 0 && (
                  <details className="more">
                    <summary>Why it happens</summary>
                    <ul className="steps">{diag.causes.map((t, i) => <li key={i}>{t}</li>)}</ul>
                  </details>
                )}

                {diag.local_note && (
                  <div className="panel" style={{ alignItems: 'flex-start', background: 'var(--chip-leaf)' }}>
                    <MapPin size={18} color="var(--leaf-ink)" style={{ flex: 'none', marginTop: 2 }} />
                    <p className="sub" style={{ color: 'var(--text)', whiteSpace: 'pre-line' }}>{diag.local_note}</p>
                  </div>
                )}

                {diag.causes === undefined && <p className="sub" style={{ whiteSpace: 'pre-line' }}>{diag.advice}</p>}

                {diag.alternatives?.length > 0 && (
                  <div>
                    <small className="sub">It could also be</small>
                    <div className="chips" style={{ marginTop: 6, flexWrap: 'wrap' }}>
                      {diag.alternatives.map((a, i) => (
                        <span key={i} className="chip" style={{ cursor: 'default', fontSize: 12 }}>{a.crop} · {a.disease} · {Math.round(a.confidence * 100)}%</span>
                      ))}
                    </div>
                  </div>
                )}

                <p className="note" style={{ justifyContent: 'flex-start' }}>
                  First opinion only — trained on PlantVillage photos of 14 crops (incl. maize, tomato, potato, pepper). Field photos are harder; confirm before spraying. {diag.model ? `Model: ${diag.model}.` : ''}
                </p>
              </div>
            )}
            {scans.length > 0 && (
              <div className="block">
              <div className="section-title"><h2>Scan history</h2><span>{scans.length}</span></div>
              <div className="list">
                {scans.map((s) => (
                  <div key={s.id} className="row" style={{ cursor: 'default' }}>
                    <span className="ic"><Leaf size={18} /></span>
                    <span className="txt"><b>{s.likely_issue}</b><small>{s.source} · {(s.confidence * 100).toFixed(0)}% · {new Date(s.scanned_at).toLocaleDateString()}</small></span>
                  </div>
                ))}
              </div>
              </div>
            )}
          </div>
        )}

        {/* ---------------- MAP ---------------- */}
        {tab === 'map' && (
          <div className="stack page fadein">
            <div className="hero short">
              <FieldArt variant="map" />
              <div className="hero-content"><span className="hero-tag"><MapPin size={12} />Mashonaland East · district view</span></div>
            </div>
            <div className="card stack">
              <div className="zones">
                {zones.map((z) => (
                  <button key={z.id} className={`zone ${z.is_farmer_plot ? 'me' : ''}`} style={{ background: zoneColor(z.status) }} onClick={() => setSelZone(z)}>
                    {z.is_farmer_plot ? 'YOU' : ''}
                  </button>
                ))}
              </div>
              {!zones.length && <p className="sub">No zones loaded yet.</p>}
              <div className="legend">
                <span><span className="dot" style={{ background: zoneColor('healthy') }} />Healthy</span>
                <span><span className="dot" style={{ background: zoneColor('stressed') }} />Stressed</span>
                <span><span className="dot" style={{ background: zoneColor('drought') }} />Drought risk</span>
              </div>
              {selZone && <div className="panel fadein"><MapPin size={18} color="var(--primary)" /><p className="sub" style={{ color: 'var(--text)' }}>Zone {selZone.id} — <b>{selZone.status}</b>{selZone.is_farmer_plot ? ' (your plot)' : ''}</p></div>}
              <p className="note">Mock grid until satellite (GEE) credentials are set on the backend.</p>
            </div>
          </div>
        )}

        {/* ---------------- ADVISE ---------------- */}
        {tab === 'advise' && (
          <div className="stack page fadein">
            <div className="hero short full">
              <FieldArt variant="wheat" />
              <div className="hero-content"><span className="hero-tag"><Sprout size={12} />Soil-based recommendations</span></div>
            </div>
            <div className="chips full">
              {[['crop', 'Crop pick'], ['fert', 'Fertilizer'], ['prices', 'Market prices']].map(([id, l]) => (
                <button key={id} className={`chip ${adviseTab === id ? 'on' : ''}`} onClick={() => setAdviseTab(id)}>{l}</button>
              ))}
            </div>

            {adviseTab === 'crop' && (
              <>
                <form className="card stack fadein" onSubmit={runCrop}>
                  <h3>What should I plant?</h3>
                  <div className="grid3">
                    <Field label="N" name="n" type="number" step="any" required placeholder="90" />
                    <Field label="P" name="p" type="number" step="any" required placeholder="42" />
                    <Field label="K" name="k" type="number" step="any" required placeholder="43" />
                    <Field label="pH" name="ph" type="number" step="any" required placeholder="6.5" />
                    <Field label="Rain mm" name="r" type="number" step="any" required placeholder="200" />
                    <Field label="Temp °C" name="t" type="number" step="any" required placeholder="25" />
                  </div>
                  <Field label="Humidity %" name="h" type="number" step="any" required placeholder="80" />
                  <button className="btn btn-primary btn-block" disabled={busy}>Recommend crop</button>
                </form>
                {cropOut && (
                  <div className="card fadein">
                    <span className="pill solid">Top pick · {cropOut.crop}</span>
                    {cropOut.suggestions?.map((s) => (
                      <div key={s.crop} style={{ marginTop: 12 }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13 }}><span>{s.crop}</span><b>{(s.confidence * 100).toFixed(0)}%</b></div>
                        <div className="confbar"><div style={{ width: `${s.confidence * 100}%` }} /></div>
                      </div>
                    ))}
                    <p className="note" style={{ justifyContent: 'flex-start', marginTop: 12 }}>{cropOut.limitations}</p>
                  </div>
                )}
              </>
            )}

            {adviseTab === 'fert' && (
              <>
                <form className="card stack fadein" onSubmit={runFert}>
                  <h3>Fertilizer advice</h3>
                  <Field label="Crop" name="crop" required placeholder="maize" />
                  <div className="grid3">
                    <Field label="N" name="n" type="number" step="any" required placeholder="90" />
                    <Field label="P" name="p" type="number" step="any" required placeholder="42" />
                    <Field label="K" name="k" type="number" step="any" required placeholder="43" />
                  </div>
                  <button className="btn btn-primary btn-block" disabled={busy}>Get fertilizer advice</button>
                </form>
                {fertOut && (
                  <div className="card fadein">
                    <span className="pill">{fertOut.nutrient} · {fertOut.direction}</span>
                    <p className="sub" style={{ marginTop: 10, color: 'var(--text)' }}>{fertOut.advice}</p>
                  </div>
                )}
              </>
            )}

            {adviseTab === 'prices' && (
              <div className="fadein stack full">
                {prices?.prices?.length ? (
                  <div className="list">
                    {prices.prices.map((p, i) => (
                      <div key={i} className="row" style={{ cursor: 'default' }}>
                        <span className="ic sun"><Sprout size={18} /></span>
                        <span className="txt"><b>{p.commodity}</b><small>{p.market} · {p.observed}</small></span>
                        <b style={{ fontSize: 15 }}>${p.price_usd_per_kg}<small style={{ color: 'var(--muted)', fontWeight: 500 }}>/kg</small></b>
                      </div>
                    ))}
                  </div>
                ) : <div className="card"><p className="sub">No price snapshot published yet.</p></div>}
                {prices && <p className="note">{prices.data_source}</p>}
              </div>
            )}
          </div>
        )}

        {/* ---------------- PROFILE ---------------- */}
        {tab === 'profile' && (
          <div className="stack page fadein">
            <div className="card stack">
              <div className="card-head" style={{ marginBottom: 0 }}>
                <div className="avatar">{initials(farmer.name)}</div>
                <div style={{ flex: 1, minWidth: 0 }}><h3>{farmer.name}</h3><small>{farmer.phone}</small></div>
                <button className="btn btn-primary" style={{ padding: '9px 14px', fontSize: 12 }} onClick={() => setEditF(!editF)}><Pencil size={14} />Edit</button>
              </div>
              <div className="panel">
                <div className="big-num">{readings.length + scans.length}<small>logs</small></div>
                <div style={{ flex: 1 }}>
                  <small className="sub">{plural(readings.length, 'reading')} · {plural(scans.length, 'scan')}</small>
                  <Dots value={Math.min(readings.length + scans.length, 20)} max={20} />
                </div>
              </div>
            </div>

            {editF ? (
              <form className="card stack fadein" onSubmit={saveProfile}>
                <h3>Update information</h3>
                <Field label="Full name" name="name" defaultValue={farmer.name} required />
                <Field label="Location" name="location" defaultValue={farmer.location} required />
                <Field label="Main crop" name="crop" defaultValue={farmer.crop} required />
                <Field label="Storage hub" name="storage_hub" defaultValue={farmer.storage_hub} required />
                <div className="grid2">
                  <button className="btn btn-primary" disabled={busy}>Save</button>
                  <button type="button" className="btn btn-soft" onClick={() => setEditF(false)}>Cancel</button>
                </div>
              </form>
            ) : (
              <div className="card" style={{ paddingTop: 6, paddingBottom: 6 }}>
                <div className="kv"><small>Location</small><b>{farmer.location}</b></div>
                <div className="kv"><small>Main crop</small><b>{farmer.crop}</b></div>
                <div className="kv"><small>Storage hub</small><b>{farmer.storage_hub}</b></div>
                <div className="kv"><small>Phone</small><b>{farmer.phone}</b></div>
              </div>
            )}

            <div className="block">
            <div className="section-title"><h2>Settings</h2></div>
            <div className="list">
              <div className="row" style={{ cursor: 'default' }}>
                <span className="ic sky">{theme === 'dark' ? <Moon size={18} /> : <Sun size={18} />}</span>
                <span className="txt"><b>Dark mode</b><small>{theme === 'dark' ? 'On' : 'Off'} · easier on the eyes at night</small></span>
                <button className={`switch ${theme === 'dark' ? 'on' : ''}`} onClick={toggle} role="switch" aria-checked={theme === 'dark'} aria-label="Dark mode"><i /></button>
              </div>
              <button className="row" onClick={signOut}>
                <span className="ic sun"><LogOut size={18} /></span>
                <span className="txt"><b>Sign out</b><small>You can sign back in with your phone number</small></span>
                <ChevronRight size={18} className="chev" />
              </button>
            </div>
            </div>
            <p className="note full">Server: {apiBase}</p>
          </div>
        )}
      </main>

      <nav className="bottom" aria-label="Main">
        <div className="nav-brand"><img src={brandLogo} alt="" /><div><b>AgriShield</b><small>Keep your harvest safe</small></div></div>
        {TABS.map((t) => (
          <button key={t.id} className={tab === t.id ? 'active' : ''} onClick={() => setTab(t.id)} aria-label={t.label}>
            <t.icon size={20} /><span>{t.label}</span>
          </button>
        ))}
        <div className="nav-foot">
          <div className="avatar" style={{ width: 38, height: 38, fontSize: 13 }}>{initials(farmer.name)}</div>
          <div style={{ minWidth: 0 }}><b>{farmer.name}</b><small>{farmer.location}</small></div>
        </div>
      </nav>
    </div>
  );
}

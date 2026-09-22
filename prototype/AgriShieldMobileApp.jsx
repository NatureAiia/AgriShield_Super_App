/**
 * AgriShield — mobile UI demo prototype, built from
 * /docs/roadmap/UI_UX_DESIGN_SPEC.md.
 *
 * A SEPARATE design direction from AgriShieldApp.jsx (dark, aesthetic
 * "super app" showcase). This one follows the spec's usability-first
 * brief: low-end Android target, high-contrast, icon-led, large tap
 * targets, minimal text, low-literacy/low-data friendly. Palette is the
 * spec's own (#1B4332 / #2D6A4F / #B45309 / #F1F8F4), not the other
 * prototype's slate/emerald/sky/indigo theme — see the spec doc's
 * "Reconciling with the existing prototype" note.
 *
 * All data is hardcoded/simulated for demo purposes — no backend.
 *
 * Screen map (spec's 8 screens onto 5 bottom-nav tabs + Home shortcuts):
 *   Bottom nav: Home, Storage, Disease Scan, Satellite Map, Market Connect
 *   Reached from Home: Alerts, Profile, Agri-Rover
 *
 * The Agri-Rover screen is explicitly flagged in-app as a future-vision
 * idea, not a committed part of the V1/V2/V3 roadmap (see the roadmap
 * README's "out of scope beyond V3" list) — this UI shows it because the
 * spec asked for it, but never implies it's built or planned.
 */
import React, { useState } from 'react';
import {
  Home, Thermometer, Camera, Map as MapIcon, Users, Bot, Bell, UserCircle,
  Droplets, Leaf, AlertTriangle, Phone, Battery, Navigation, ChevronLeft,
  Check, WifiOff, Sun, CloudRain
} from 'lucide-react';

const COLORS = {
  primary: '#1B4332',
  accent: '#2D6A4F',
  alert: '#B45309',
  bg: '#F1F8F4',
};

const TABS = [
  { id: 'home', label: 'Home', icon: Home },
  { id: 'storage', label: 'Storage', icon: Thermometer },
  { id: 'scan', label: 'Scan', icon: Camera },
  { id: 'map', label: 'Map', icon: MapIcon },
  { id: 'market', label: 'Market', icon: Users },
];

function OfflineBar() {
  return (
    <div
      className="flex items-center justify-center gap-2 py-1.5 text-xs font-semibold text-white"
      style={{ backgroundColor: COLORS.alert }}
    >
      <WifiOff className="w-3.5 h-3.5" />
      <span>Working offline — will sync when connected</span>
    </div>
  );
}

function ScreenHeader({ title, onBack }) {
  return (
    <div
      className="flex items-center gap-2 px-4 py-4 text-white"
      style={{ backgroundColor: COLORS.primary }}
    >
      {onBack && (
        <button onClick={onBack} aria-label="Back" className="p-1 -ml-1 rounded-lg active:bg-white/10">
          <ChevronLeft className="w-6 h-6" />
        </button>
      )}
      <h1 className="text-lg font-bold">{title}</h1>
    </div>
  );
}

function Card({ children, className = '' }) {
  return (
    <div
      className={`rounded-2xl p-4 shadow-sm border ${className}`}
      style={{ backgroundColor: '#FFFFFF', borderColor: '#DCE6E0' }}
    >
      {children}
    </div>
  );
}

function RiskBadge({ level }) {
  const map = {
    green: { bg: '#DCF5E4', fg: '#166534', label: 'Low mold risk' },
    amber: { bg: '#FEF3C7', fg: '#92400E', label: 'Moderate mold risk' },
    red: { bg: '#FEE2E2', fg: '#991B1B', label: 'High mold risk' },
  };
  const s = map[level];
  return (
    <span
      className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-bold"
      style={{ backgroundColor: s.bg, color: s.fg }}
    >
      <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: s.fg }} />
      {s.label}
    </span>
  );
}

// ---------- Screens ----------

function HomeScreen({ go, farmer }) {
  return (
    <div className="p-4 space-y-4">
      <div>
        <p className="text-sm" style={{ color: COLORS.accent }}>Good morning,</p>
        <h2 className="text-2xl font-extrabold" style={{ color: COLORS.primary }}>{farmer.name}</h2>
      </div>

      <Card>
        <div className="flex items-center gap-3">
          <div className="p-3 rounded-xl" style={{ backgroundColor: COLORS.bg }}>
            <Leaf className="w-6 h-6" style={{ color: COLORS.accent }} />
          </div>
          <div className="flex-1">
            <p className="text-xs font-semibold text-gray-500">SHELF LIFE — MAIZE</p>
            <p className="text-xl font-extrabold" style={{ color: COLORS.primary }}>14 hours left</p>
            <p className="text-xs text-gray-500">Sell or move to a cooler spot today</p>
          </div>
        </div>
      </Card>

      <div className="flex items-center justify-between">
        <RiskBadge level="amber" />
        <div className="flex items-center gap-1.5 text-sm font-semibold" style={{ color: COLORS.primary }}>
          <Sun className="w-4 h-4" />
          27°C · rain expected tomorrow
        </div>
      </div>

      <div>
        <p className="text-sm font-bold mb-2" style={{ color: COLORS.primary }}>Quick alerts</p>
        <div className="flex gap-3 overflow-x-auto pb-1 -mx-1 px-1">
          {[
            { icon: AlertTriangle, text: 'Mold risk rising', tone: 'amber' },
            { icon: CloudRain, text: 'Rain in 2 days', tone: 'green' },
            { icon: Users, text: 'Buyer found for wheat', tone: 'green' },
          ].map((a, i) => (
            <div
              key={i}
              className="min-w-[150px] rounded-xl p-3 flex flex-col gap-2 shrink-0"
              style={{ backgroundColor: a.tone === 'amber' ? '#FEF3C7' : '#DCF5E4' }}
            >
              <a.icon className="w-5 h-5" style={{ color: a.tone === 'amber' ? '#92400E' : '#166534' }} />
              <p className="text-sm font-semibold" style={{ color: a.tone === 'amber' ? '#92400E' : '#166534' }}>{a.text}</p>
            </div>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-3 gap-3 pt-2">
        <button onClick={() => go('alerts')} className="flex flex-col items-center gap-1.5 py-3 rounded-2xl active:opacity-70" style={{ backgroundColor: '#FFFFFF', border: '1px solid #DCE6E0' }}>
          <Bell className="w-6 h-6" style={{ color: COLORS.primary }} />
          <span className="text-xs font-semibold" style={{ color: COLORS.primary }}>Alerts</span>
        </button>
        <button onClick={() => go('rover')} className="flex flex-col items-center gap-1.5 py-3 rounded-2xl active:opacity-70" style={{ backgroundColor: '#FFFFFF', border: '1px solid #DCE6E0' }}>
          <Bot className="w-6 h-6" style={{ color: COLORS.primary }} />
          <span className="text-xs font-semibold" style={{ color: COLORS.primary }}>Agri-Rover</span>
        </button>
        <button onClick={() => go('profile')} className="flex flex-col items-center gap-1.5 py-3 rounded-2xl active:opacity-70" style={{ backgroundColor: '#FFFFFF', border: '1px solid #DCE6E0' }}>
          <UserCircle className="w-6 h-6" style={{ color: COLORS.primary }} />
          <span className="text-xs font-semibold" style={{ color: COLORS.primary }}>Profile</span>
        </button>
      </div>
    </div>
  );
}

function StorageScreen() {
  // 24h sample readings for a simple sparkline
  const points = [24, 25, 27, 30, 33, 35, 34, 31, 28, 26, 25, 24];
  const max = Math.max(...points), min = Math.min(...points);
  const path = points
    .map((v, i) => {
      const x = (i / (points.length - 1)) * 280;
      const y = 60 - ((v - min) / (max - min || 1)) * 50;
      return `${i === 0 ? 'M' : 'L'}${x},${y}`;
    })
    .join(' ');

  return (
    <div className="p-4 space-y-4">
      <div className="grid grid-cols-2 gap-3">
        <Card>
          <div className="flex items-center gap-2 mb-1">
            <Thermometer className="w-5 h-5" style={{ color: COLORS.alert }} />
            <p className="text-xs font-semibold text-gray-500">TEMPERATURE</p>
          </div>
          <p className="text-3xl font-extrabold" style={{ color: COLORS.primary }}>31°C</p>
        </Card>
        <Card>
          <div className="flex items-center gap-2 mb-1">
            <Droplets className="w-5 h-5" style={{ color: COLORS.accent }} />
            <p className="text-xs font-semibold text-gray-500">HUMIDITY</p>
          </div>
          <p className="text-3xl font-extrabold" style={{ color: COLORS.primary }}>68%</p>
        </Card>
      </div>

      <Card>
        <p className="text-xs font-semibold text-gray-500 mb-2">LAST 24 HOURS</p>
        <svg viewBox="0 0 280 60" className="w-full h-16">
          <path d={path} fill="none" stroke={COLORS.accent} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </Card>

      <Card className="flex items-start gap-3">
        <Leaf className="w-5 h-5 mt-0.5 shrink-0" style={{ color: COLORS.accent }} />
        <p className="text-sm" style={{ color: COLORS.primary }}>
          It's warmer than usual, so your maize is spoiling faster — about <strong>14 hours</strong> of good condition left.
        </p>
      </Card>
    </div>
  );
}

function ScanScreen() {
  const [scanning, setScanning] = useState(false);
  const [result, setResult] = useState(null);

  const runScan = () => {
    setScanning(true);
    setResult(null);
    setTimeout(() => {
      setScanning(false);
      setResult({ issue: 'Maize Northern Leaf Blight', confidence: 'Likely match' });
    }, 1600);
  };

  return (
    <div className="p-4 space-y-4">
      <div
        className="rounded-2xl border-2 border-dashed flex flex-col items-center justify-center gap-3 py-10"
        style={{ borderColor: COLORS.accent, backgroundColor: '#FFFFFF' }}
      >
        {scanning ? (
          <p className="text-sm font-semibold animate-pulse" style={{ color: COLORS.accent }}>Checking leaf photo…</p>
        ) : (
          <button
            onClick={runScan}
            className="flex flex-col items-center gap-2 active:opacity-70"
            aria-label="Photograph a leaf"
          >
            <div className="p-6 rounded-full" style={{ backgroundColor: COLORS.primary }}>
              <Camera className="w-10 h-10 text-white" />
            </div>
            <span className="text-sm font-bold" style={{ color: COLORS.primary }}>Tap to photograph a leaf</span>
          </button>
        )}
      </div>

      {result && (
        <Card className="space-y-3">
          <div>
            <p className="text-xs font-semibold text-gray-500">LIKELY ISSUE</p>
            <p className="text-lg font-extrabold" style={{ color: COLORS.primary }}>{result.issue}</p>
          </div>
          <p className="text-xs italic text-gray-500">{result.confidence} — first opinion, not a final answer.</p>
          <button
            className="w-full py-3 rounded-xl text-white font-bold flex items-center justify-center gap-2"
            style={{ backgroundColor: COLORS.alert }}
          >
            <Phone className="w-4 h-4" />
            Find an extension officer nearby
          </button>
        </Card>
      )}
    </div>
  );
}

function MapScreen() {
  const [selected, setSelected] = useState(null);
  const zones = ['green', 'green', 'amber', 'green', 'red', 'amber', 'green', 'green', 'green'];
  const colorFor = { green: '#2D6A4F', amber: '#D97706', red: '#B45309' };
  const yourPlotIndex = 4;

  return (
    <div className="p-4 space-y-4">
      <Card>
        <div className="grid grid-cols-3 gap-1.5">
          {zones.map((z, i) => (
            <button
              key={i}
              onClick={() => setSelected(i)}
              className="aspect-square rounded-lg relative"
              style={{
                backgroundColor: colorFor[z],
                outline: i === yourPlotIndex ? `3px solid ${COLORS.primary}` : 'none',
                outlineOffset: '2px',
              }}
              aria-label={`Zone ${i + 1}, ${z}`}
            >
              {i === yourPlotIndex && (
                <span className="absolute inset-0 flex items-center justify-center text-white text-xs font-bold">You</span>
              )}
            </button>
          ))}
        </div>
      </Card>

      <div className="flex items-center justify-around text-xs font-semibold" style={{ color: COLORS.primary }}>
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full" style={{ backgroundColor: colorFor.green }} />Healthy</span>
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full" style={{ backgroundColor: colorFor.amber }} />Stressed</span>
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full" style={{ backgroundColor: colorFor.red }} />Drought risk</span>
      </div>

      {selected !== null && (
        <Card>
          <p className="text-sm font-bold" style={{ color: COLORS.primary }}>
            {selected === yourPlotIndex ? 'Your plot' : `Zone ${selected + 1}`}
          </p>
          <p className="text-xs text-gray-500 mt-1">
            Status: {zones[selected] === 'green' ? 'Healthy' : zones[selected] === 'amber' ? 'Stressed — watch for dryness' : 'Drought risk — check soon'}
          </p>
        </Card>
      )}
    </div>
  );
}

function MarketScreen() {
  return (
    <div className="p-4 space-y-4">
      <Card className="space-y-3">
        <p className="text-xs font-semibold text-gray-500">GOOD NEWS</p>
        <p className="text-lg font-extrabold" style={{ color: COLORS.primary }}>Your wheat has a buyer</p>
        <div className="flex items-center justify-between text-sm">
          <span className="font-semibold" style={{ color: COLORS.accent }}>Tapiwa Marimo</span>
          <span className="text-gray-500">6 km away</span>
        </div>
        <button
          className="w-full py-4 rounded-xl text-white text-lg font-extrabold flex items-center justify-center gap-2"
          style={{ backgroundColor: COLORS.accent }}
        >
          <Phone className="w-5 h-5" />
          Call now
        </button>
        <p className="text-xs text-center text-gray-400">You and the buyer agree the price directly — AgriShield just makes the introduction.</p>
      </Card>
    </div>
  );
}

function RoverScreen() {
  return (
    <div className="p-4 space-y-4">
      <Card className="flex items-start gap-3" style={{ backgroundColor: '#FEF3C7', borderColor: '#FDE68A' }}>
        <AlertTriangle className="w-5 h-5 mt-0.5 shrink-0" style={{ color: '#92400E' }} />
        <p className="text-xs font-semibold" style={{ color: '#92400E' }}>
          Future vision — not part of the current build. No Agri-Rover exists yet; this screen shows the idea, not a working feature.
        </p>
      </Card>

      <div className="grid grid-cols-2 gap-3">
        <Card>
          <div className="flex items-center gap-2 mb-1">
            <Battery className="w-5 h-5" style={{ color: COLORS.accent }} />
            <p className="text-xs font-semibold text-gray-500">BATTERY</p>
          </div>
          <p className="text-3xl font-extrabold" style={{ color: COLORS.primary }}>82%</p>
          <p className="text-xs text-gray-400">Solar-charged</p>
        </Card>
        <Card>
          <div className="flex items-center gap-2 mb-1">
            <Navigation className="w-5 h-5" style={{ color: COLORS.accent }} />
            <p className="text-xs font-semibold text-gray-500">POSITION</p>
          </div>
          <p className="text-sm font-bold" style={{ color: COLORS.primary }}>Zone 4, North field</p>
        </Card>
      </div>

      <Card>
        <p className="text-xs font-semibold text-gray-500 mb-1">LAST SCOUTING RESULT</p>
        <p className="text-sm" style={{ color: COLORS.primary }}>No disease spotted in Zone 4 — checked 40 minutes ago.</p>
      </Card>

      <button
        disabled
        className="w-full py-4 rounded-xl text-white text-lg font-extrabold opacity-50"
        style={{ backgroundColor: COLORS.primary }}
      >
        Send to Zone
      </button>
    </div>
  );
}

function AlertsScreen() {
  const days = [
    { day: 'Today', items: ['Mold risk rising in maize storage', 'Rain expected in 2 days'] },
    { day: 'Yesterday', items: ['Buyer found for your wheat', 'Leaf scan: Northern Leaf Blight detected'] },
    { day: '2 days ago', items: ['Temperature crossed 30°C in storage box'] },
  ];
  return (
    <div className="p-4 space-y-5">
      {days.map((d) => (
        <div key={d.day}>
          <p className="text-xs font-bold uppercase tracking-wide mb-2" style={{ color: COLORS.accent }}>{d.day}</p>
          <div className="space-y-2">
            {d.items.map((text, i) => (
              <Card key={i} className="flex items-start gap-3">
                <Bell className="w-4 h-4 mt-0.5 shrink-0" style={{ color: COLORS.alert }} />
                <p className="text-sm" style={{ color: COLORS.primary }}>{text}</p>
              </Card>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

function ProfileScreen() {
  const [editing, setEditing] = useState(null);
  const [farmer, setFarmer] = useState({
    name: 'Tendai Moyo',
    location: 'Harare South',
    crop: 'Maize',
    hub: 'Mbare Collection Point',
  });

  const fields = [
    { key: 'name', label: 'Name' },
    { key: 'location', label: 'Location' },
    { key: 'crop', label: 'Crop' },
    { key: 'hub', label: 'Storage hub' },
  ];

  return (
    <div className="p-4 space-y-3">
      {fields.map((f) => (
        <Card key={f.key} className="flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-gray-500">{f.label.toUpperCase()}</p>
            {editing === f.key ? (
              <input
                autoFocus
                value={farmer[f.key]}
                onChange={(e) => setFarmer({ ...farmer, [f.key]: e.target.value })}
                onBlur={() => setEditing(null)}
                className="text-base font-bold bg-transparent border-b outline-none"
                style={{ color: COLORS.primary, borderColor: COLORS.accent }}
              />
            ) : (
              <p className="text-base font-bold" style={{ color: COLORS.primary }}>{farmer[f.key]}</p>
            )}
          </div>
          <button
            onClick={() => setEditing(editing === f.key ? null : f.key)}
            className="p-2 rounded-lg active:opacity-70"
            style={{ backgroundColor: COLORS.bg }}
            aria-label={`Edit ${f.label}`}
          >
            {editing === f.key ? <Check className="w-5 h-5" style={{ color: COLORS.accent }} /> : <UserCircle className="w-5 h-5" style={{ color: COLORS.primary }} />}
          </button>
        </Card>
      ))}
      <p className="text-xs text-center text-gray-400 pt-2">Tap the icon, edit, tap the check — two taps to update.</p>
    </div>
  );
}

// ---------- App shell ----------

const SCREEN_TITLES = {
  home: 'AgriShield',
  storage: 'Storage Sensor',
  scan: 'Disease Scan',
  map: 'Satellite Map',
  market: 'Market Connect',
  rover: 'Agri-Rover',
  alerts: 'Alerts',
  profile: 'Profile',
};

export default function AgriShieldMobileApp() {
  const [screen, setScreen] = useState('home');
  const farmer = { name: 'Tendai Moyo' };
  const isSecondary = ['rover', 'alerts', 'profile'].includes(screen);

  return (
    <div
      className="max-w-sm mx-auto min-h-screen flex flex-col font-sans"
      style={{ backgroundColor: COLORS.bg }}
    >
      <OfflineBar />
      <ScreenHeader
        title={SCREEN_TITLES[screen]}
        onBack={isSecondary ? () => setScreen('home') : null}
      />

      <main className="flex-1 overflow-y-auto pb-24">
        {screen === 'home' && <HomeScreen go={setScreen} farmer={farmer} />}
        {screen === 'storage' && <StorageScreen />}
        {screen === 'scan' && <ScanScreen />}
        {screen === 'map' && <MapScreen />}
        {screen === 'market' && <MarketScreen />}
        {screen === 'rover' && <RoverScreen />}
        {screen === 'alerts' && <AlertsScreen />}
        {screen === 'profile' && <ProfileScreen />}
      </main>

      {!isSecondary && (
        <nav
          className="fixed bottom-0 left-0 right-0 max-w-sm mx-auto grid grid-cols-5 border-t"
          style={{ backgroundColor: '#FFFFFF', borderColor: '#DCE6E0' }}
        >
          {TABS.map((t) => {
            const active = screen === t.id;
            return (
              <button
                key={t.id}
                onClick={() => setScreen(t.id)}
                className="flex flex-col items-center gap-1 py-3"
                aria-label={t.label}
              >
                <t.icon className="w-6 h-6" style={{ color: active ? COLORS.primary : '#9CA3AF' }} />
                <span
                  className="text-[10px] font-bold"
                  style={{ color: active ? COLORS.primary : '#9CA3AF' }}
                >
                  {t.label}
                </span>
              </button>
            );
          })}
        </nav>
      )}
    </div>
  );
}

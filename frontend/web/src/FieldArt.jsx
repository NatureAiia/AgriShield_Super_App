/**
 * FieldArt — lightweight, offline SVG farm illustrations used for heroes and
 * cards. No image downloads (the app must work on weak/no signal), and they
 * scale crisply on any screen.
 *
 * variants: 'sunrise' | 'day' | 'wheat' | 'storage' | 'map' | 'leaf'
 */
import React, { useId } from 'react';

const W = 400;
const H = 260;

const PALETTES = {
  sunrise: { sky: ['#1f3d5c', '#e9874c', '#ffc978'], sun: '#fff0c4', hill: '#4c7a55', hill2: '#3a6345', rowA: '#3f7f45', rowB: '#2f6a39', plant: '#7fcf6b', plant2: '#5fb455' },
  day:     { sky: ['#7cc8ee', '#bfe6f7', '#eaf8fd'], sun: '#fff7d6', hill: '#97cc86', hill2: '#7cb871', rowA: '#5aa64f', rowB: '#478f40', plant: '#9be27f', plant2: '#6cc35c' },
  wheat:   { sky: ['#f7c873', '#fde3a7', '#fff4d8'], sun: '#fffbea', hill: '#d8a646', hill2: '#c6923a', rowA: '#e5b453', rowB: '#cf9a37', plant: '#f6d27a', plant2: '#e0b24f' },
  storage: { sky: ['#9fd4ea', '#d3eef8', '#f1fafd'], sun: '#fff7d6', hill: '#a9d394', hill2: '#8fc37c', rowA: '#69b25b', rowB: '#57a04b', plant: '#9be27f', plant2: '#6cc35c' },
};

function Sky({ id, p, sunX = 300, sunY = 70, sunR = 30 }) {
  return (
    <>
      <defs>
        <linearGradient id={`${id}-sky`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor={p.sky[0]} />
          <stop offset="0.6" stopColor={p.sky[1]} />
          <stop offset="1" stopColor={p.sky[2]} />
        </linearGradient>
        <radialGradient id={`${id}-sun`}>
          <stop offset="0" stopColor={p.sun} stopOpacity="1" />
          <stop offset="0.45" stopColor={p.sun} stopOpacity="0.55" />
          <stop offset="1" stopColor={p.sun} stopOpacity="0" />
        </radialGradient>
      </defs>
      <rect width={W} height={H} fill={`url(#${id}-sky)`} />
      <circle cx={sunX} cy={sunY} r={sunR * 3} fill={`url(#${id}-sun)`} />
      <circle cx={sunX} cy={sunY} r={sunR} fill={p.sun} />
    </>
  );
}

function Hills({ p, y = 132 }) {
  return (
    <>
      <path d={`M0 ${y} Q 70 ${y - 34} 150 ${y - 8} T 300 ${y - 14} T ${W} ${y - 26} V ${H} H 0 Z`} fill={p.hill} />
      <path d={`M0 ${y + 10} Q 110 ${y - 12} 210 ${y + 6} T ${W} ${y} V ${H} H 0 Z`} fill={p.hill2} />
    </>
  );
}

/** Perspective crop rows converging on a vanishing point, plus sprouts. */
function Rows({ p, horizon = 142, plants = true, wheat = false }) {
  const vx = W / 2;
  const vy = horizon - 70;
  const stripes = [];
  const n = 14;
  const span = 110;
  for (let i = -n; i < n; i++) {
    const x0 = vx + i * span * 0.5;
    const x1 = vx + (i + 1) * span * 0.5;
    // where the converging lines cross the horizon
    const t = (horizon - vy) / (H - vy);
    const hx0 = vx + (x0 - vx) * t;
    const hx1 = vx + (x1 - vx) * t;
    stripes.push(
      <path key={i} d={`M${hx0} ${horizon} L${hx1} ${horizon} L${x1} ${H} L${x0} ${H} Z`} fill={i % 2 ? p.rowA : p.rowB} />,
    );
  }
  const sprouts = [];
  if (plants) {
    for (let i = -n; i < n; i++) {
      const cx = vx + (i + 0.5) * span * 0.5;
      for (let k = 0; k < 6; k++) {
        const tt = 0.15 + k * 0.17; // 0 = horizon, 1 = bottom
        const y = horizon + (H - horizon) * tt;
        const t2 = (y - vy) / (H - vy);
        const x = vx + (cx - vx) * t2;
        if (x < -20 || x > W + 20) continue;
        const s = 0.25 + tt * 1.1;
        sprouts.push(wheat ? <Stalk key={`${i}-${k}`} x={x} y={y} s={s} p={p} /> : <Sprout key={`${i}-${k}`} x={x} y={y} s={s} p={p} />);
      }
    }
  }
  return (
    <>
      <rect x="0" y={horizon} width={W} height={H - horizon} fill={p.rowB} />
      {stripes}
      {sprouts}
    </>
  );
}

function Sprout({ x, y, s, p }) {
  return (
    <g transform={`translate(${x} ${y}) scale(${s})`}>
      <path d="M0 0 C -2 -6 -1 -10 0 -12" stroke={p.plant2} strokeWidth="1.6" fill="none" />
      <ellipse cx="-5" cy="-9" rx="6" ry="3" transform="rotate(-30 -5 -9)" fill={p.plant} />
      <ellipse cx="5" cy="-11" rx="6" ry="3" transform="rotate(25 5 -11)" fill={p.plant2} />
      <ellipse cx="0" cy="-15" rx="3.2" ry="5" fill={p.plant} />
    </g>
  );
}

function Stalk({ x, y, s, p }) {
  return (
    <g transform={`translate(${x} ${y}) scale(${s})`}>
      <path d="M0 0 L0 -18" stroke={p.plant2} strokeWidth="1.4" />
      <ellipse cx="0" cy="-20" rx="2.4" ry="6" fill={p.plant} />
      <ellipse cx="-3" cy="-13" rx="2" ry="4.4" transform="rotate(-25 -3 -13)" fill={p.plant} />
      <ellipse cx="3" cy="-13" rx="2" ry="4.4" transform="rotate(25 3 -13)" fill={p.plant} />
    </g>
  );
}

function Clouds({ y = 46, op = 0.85 }) {
  return (
    <g fill="#fff" opacity={op}>
      <ellipse cx="70" cy={y} rx="34" ry="11" />
      <ellipse cx="92" cy={y - 8} rx="22" ry="12" />
      <ellipse cx="190" cy={y + 18} rx="26" ry="8" />
      <ellipse cx="206" cy={y + 12} rx="16" ry="9" />
    </g>
  );
}

function Storage({ p }) {
  // collection hub: barn + two grain silos
  return (
    <g>
      <rect x="236" y="88" width="34" height="62" rx="4" fill="#e8eef0" />
      <path d="M236 92 Q253 68 270 92 Z" fill="#c9d6db" />
      <rect x="276" y="76" width="38" height="74" rx="4" fill="#f3f6f7" />
      <path d="M276 80 Q295 52 314 80 Z" fill="#d6e1e5" />
      {[100, 112, 124, 136].map((yy) => <rect key={yy} x="276" y={yy} width="38" height="1.4" fill="#cfd9dd" />)}
      <path d="M120 150 L120 108 L160 84 L200 108 L200 150 Z" fill="#b5523b" />
      <path d="M114 110 L160 80 L206 110" stroke="#8f3c2a" strokeWidth="6" fill="none" strokeLinejoin="round" />
      <rect x="146" y="118" width="28" height="32" fill="#7a2f20" />
      <path d="M146 118 L174 150 M174 118 L146 150" stroke="#e9c9bd" strokeWidth="2" />
      <rect x="128" y="112" width="12" height="10" fill="#f6e0b5" />
      <rect x="180" y="112" width="12" height="10" fill="#f6e0b5" />
    </g>
  );
}

function MapArt({ id }) {
  // top-down patchwork, like a satellite tile
  const cells = [
    ['#4f9d4a', '#6fb85f', '#d9b25a', '#3f8a43', '#86c06e'],
    ['#89c36f', '#3f8a43', '#5aa64f', '#c99a3c', '#5aa64f'],
    ['#d9b25a', '#5aa64f', '#2f6a39', '#7cb871', '#3f8a43'],
    ['#6fb85f', '#c99a3c', '#7cb871', '#4f9d4a', '#d9b25a'],
  ];
  return (
    <>
      <rect width={W} height={H} fill="#cfe3c4" />
      <g transform="rotate(-8 200 130) translate(-30 -30)">
        {cells.map((row, r) => row.map((c, ci) => (
          <rect key={`${r}-${ci}`} x={ci * 96} y={r * 82} width="92" height="78" rx="6" fill={c} />
        )))}
        {cells.map((row, r) => row.map((_, ci) => (
          [0, 1, 2, 3, 4, 5].map((k) => (
            <rect key={`${r}-${ci}-${k}`} x={ci * 96 + 6} y={r * 82 + 8 + k * 11} width="80" height="2" rx="1" fill="#ffffff" opacity="0.12" />
          ))
        )))}
      </g>
      <path d="M-10 190 C 90 150 160 230 260 170 S 380 120 420 140" stroke="#7ec3e6" strokeWidth="9" fill="none" opacity="0.9" />
      <circle cx="218" cy="118" r="10" fill="#fff" />
      <circle cx="218" cy="118" r="5" fill="#2e6a4f" />
      <circle cx="218" cy="118" r="22" fill="none" stroke="#fff" strokeWidth="2" opacity="0.7" />
      <defs>
        <radialGradient id={`${id}-vig`} cx="0.5" cy="0.5" r="0.75">
          <stop offset="0.6" stopColor="#000" stopOpacity="0" />
          <stop offset="1" stopColor="#000" stopOpacity="0.25" />
        </radialGradient>
      </defs>
      <rect width={W} height={H} fill={`url(#${id}-vig)`} />
    </>
  );
}

function LeafArt({ id }) {
  return (
    <>
      <defs>
        <linearGradient id={`${id}-bg`} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#d9f0d8" />
          <stop offset="1" stopColor="#9fd39a" />
        </linearGradient>
        <linearGradient id={`${id}-lf`} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#7fcf6b" />
          <stop offset="1" stopColor="#2f7d3c" />
        </linearGradient>
      </defs>
      <rect width={W} height={H} fill={`url(#${id}-bg)`} />
      <circle cx="320" cy="40" r="80" fill="#fff" opacity="0.35" />
      <g transform="translate(200 140) rotate(-28)">
        <path d="M-150 0 C -90 -90 90 -90 150 0 C 90 90 -90 90 -150 0 Z" fill={`url(#${id}-lf)`} />
        <path d="M-150 0 L150 0" stroke="#d9f5cf" strokeWidth="3" opacity="0.8" />
        {[-100, -55, -10, 35, 80].map((x) => (
          <g key={x} stroke="#d9f5cf" strokeWidth="2" opacity="0.6" fill="none">
            <path d={`M${x} 0 Q ${x + 25} -30 ${x + 45} -50`} />
            <path d={`M${x} 0 Q ${x + 25} 30 ${x + 45} 50`} />
          </g>
        ))}
        <circle cx="40" cy="-22" r="9" fill="#b7791f" opacity="0.75" />
        <circle cx="62" cy="18" r="6" fill="#b7791f" opacity="0.6" />
      </g>
      {/* scan corners */}
      <g stroke="#fff" strokeWidth="5" fill="none" strokeLinecap="round">
        <path d="M70 60 V40 H90" /><path d="M330 60 V40 H310" />
        <path d="M70 200 V220 H90" /><path d="M330 200 V220 H310" />
      </g>
    </>
  );
}

/* ---------- Real photos (optional) ----------
 * Drop JPG/PNG/WebP files into frontend/assets/photos/ with these names and
 * they replace the drawings automatically — no code changes needed:
 *   onboarding · home · storage · scan · map · advice
 * Any name that's missing keeps its drawing. */
const PHOTO_FILES = import.meta.glob('../../assets/photos/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}', { eager: true, import: 'default' });
const PHOTOS = Object.fromEntries(
  Object.entries(PHOTO_FILES).map(([path, url]) => [path.split('/').pop().replace(/\.[^.]+$/, '').toLowerCase(), url]),
);
const PHOTO_FOR = { sunrise: 'onboarding', day: 'home', storage: 'storage', leaf: 'scan', map: 'map', wheat: 'advice' };

export default function FieldArt({ variant = 'day', className = '' }) {
  const id = useId().replace(/:/g, '');
  const photo = PHOTOS[PHOTO_FOR[variant]];
  if (photo) return <img className={`art photo ${className}`} src={photo} alt="" loading="lazy" decoding="async" />;
  const p = PALETTES[variant] || PALETTES.day;
  let body;
  if (variant === 'map') body = <MapArt id={id} />;
  else if (variant === 'leaf') body = <LeafArt id={id} />;
  else if (variant === 'sunrise') {
    body = (<><Sky id={id} p={p} sunX={200} sunY={132} sunR={18} /><Hills p={p} y={140} /><Rows p={p} horizon={150} /></>);
  } else if (variant === 'wheat') {
    body = (<><Sky id={id} p={p} sunX={310} sunY={60} sunR={24} /><Clouds y={40} op={0.6} /><Hills p={p} y={128} /><Rows p={p} horizon={138} wheat /></>);
  } else if (variant === 'storage') {
    body = (<><Sky id={id} p={p} sunX={80} sunY={50} sunR={20} /><Clouds y={36} /><Hills p={p} y={140} /><Storage p={p} /><Rows p={p} horizon={150} plants={false} /></>);
  } else {
    body = (<><Sky id={id} p={p} sunX={320} sunY={52} sunR={22} /><Clouds /><Hills p={p} y={128} /><Rows p={p} horizon={140} /></>);
  }
  return (
    <svg className={`art ${className}`} viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="xMidYMid slice" aria-hidden="true">
      {body}
    </svg>
  );
}

# AgriShield Super App — Roadmap

This is the single source of truth for what AgriShield builds, in what order, and why. It reconciles three inputs gathered during planning: the team's own six planning documents (root of this repo), a fintech-forward "super app" concept (AgriShield Score, parametric insurance, agrifinance/BNPL, marketplace), and a UI vision prototype (`/prototype`). Detail lives in three version docs:

- [`V1_HACKATHON_DEMO.md`](./V1_HACKATHON_DEMO.md) — target: **2026-09-28**, the Hack4Africa pitch
- [`V2_INTELLIGENCE_LAYER.md`](./V2_INTELLIGENCE_LAYER.md) — post-hackathon, through the POTRAZ Innovation Expo (Sept 29–Oct 2, 2026) and beyond
- [`V3_ECOSYSTEM_FINANCE_MARKET.md`](./V3_ECOSYSTEM_FINANCE_MARKET.md) — later, evidence-gated
- [`UI_UX_DESIGN_SPEC.md`](./UI_UX_DESIGN_SPEC.md) — an 8-screen mobile UI design brief (written spec only, not yet built), a low-end-device-first companion to `/prototype`

## The problem, simply put

Crops get lost or spoiled in three different ways, at three different times — plus a fourth, even when a harvest survives:

1. **Before harvest** — a disease spreads on a plant, or a district dries out, before anyone notices in time.
2. **Right after harvest, in storage** — food sits somewhere too hot or too damp, and spoils before it can be sold.
3. **Getting it to a good market** — even good produce sells for less than it should, with no cold storage nearby and no easy way to know where the best price is.
4. **Getting good advice at all** — most smallholder farmers have no regular access to an agronomist or extension officer.

FAO estimates about a fifth of fruit-and-vegetable value is lost post-harvest worldwide, roughly double that share in Sub-Saharan Africa versus North America/Europe. Zimbabwe's renewable-energy agency estimated in 2025 that solar cold storage could cut these losses by at least half, in a market worth around $128M locally — and ColdHubs (Nigeria) and SoKo Fresh (Kenya) already run pay-as-you-go solar cold rooms elsewhere on the continent, cutting spoilage from as much as half down to under 2%.

## The foundation (built once, everything else plugs into it)

One shared farmer/field record (name, rough location, crop, storage hub), offline-first sync (works with no signal, syncs when a connection returns), and one communication channel — **Africa's Talking** (SMS, USSD, and voice call, confirmed to support all three) — also the channel V3 later reuses for mobile-money disbursement. Every module below plugs into this rather than building its own.

## The three versions, at a glance

| | V1 — Hackathon Demo | V2 — Intelligence Layer | V3 — Ecosystem, Market & Finance |
|---|---|---|---|
| **When** | By 2026-09-28 | Post-hackathon → POTRAZ Expo and beyond | Later, gated by real usage evidence |
| **Builds** | Storage sensor + zeer cooler, offline disease checker, satellite district view | Weather, market prices (vegetables), planting advice, waste-to-feed guide, seasonal pest reminder, AgriShield reliability-score seed | Buyer/seller contact-intro → scored marketplace, parametric insurance, agrifinance/BNPL, real cold room |
| **Proves** | The hardware + on-device AI actually works, live, in front of judges | The app is a season-long companion with real, cited free data sources behind every alert | The trust/reliability signal V1+V2 generated is real enough to plug into actual financial products and a real market layer |
| **Needs before it starts** | Nothing — this is the foundation | V1's telemetry pipeline (sensors, scans, satellite feed) | Real partners: buyer/seller lists, an insurance underwriter, a lender — none confirmed yet |

**Why this order:** the project's own design principle, applied consistently — *don't build unproven infrastructure on a guess; let real usage data justify it*. It's the same argument the source docs use for not building the $30,000 cold room on day one, and it applies equally to insurance, credit, and BNPL: AgriShield earns a real reliability signal in V1/V2 before V3 tries to spend it on real financial products.

## The honesty principle (carried through every version doc)

The team's own planning documents score themselves 9/10 on "every claim is backed up or flagged" — every version doc in this roadmap holds to the same standard:

- Every data source is named (Open-Meteo, FAO, Sentinel-2 via Google Earth Engine, PlantVillage, Zimbabwe Agricultural Marketing Authority, Africa's Talking, etc.), or the claim is marked explicitly unconfirmed.
- Known limitations are stated in the same breath as the feature that has them, not buried in a separate appendix.
- V1 is never inflated: only Parts 1–3 (storage sensor, disease checker, satellite view) are demo-ready by the hackathon. Everything else — Modules 4–8, the market layer, and the entire fintech layer (AgriShield Score as a credit product, parametric insurance, BNPL, marketplace) — is roadmap, said plainly, not built yet.
- The fintech layer in particular arrived far less sourced than the rest of the plan (a UI-mockup style "app builder" prompt, not a cited spec). It's included because it's a natural, well-precedented extension (real-world analogues: ACRE Africa, Pula Advisors for parametric insurance) — but **no insurance underwriter, lender, or credit bureau partner is confirmed for AgriShield**, and the roadmap says so at every mention, not once and then forgotten.

## What's explicitly out of scope, beyond V3

A separate "blue-sky" document (`AgriShield_Innovate.docx`) proposes a further tier this roadmap does **not** commit to: an "Agri-Rover" field robot, a paid PlanetScope satellite upgrade with multi-index remote sensing (NDVI/NDMI/NDRE/MSAVI) and variable-rate application, black-soldier-fly/hydroponic/aquaculture automation, a full solar buildout across every hardware piece, and one unified rover+sensor+satellite+pricing architecture. These stay a named moonshot tier — real ideas, explicitly not part of the committed V1/V2/V3 roadmap.

## The prototype

[`/prototype`](../../prototype) holds two React + Tailwind UI prototypes and a first-pass database schema/architecture sketch (`schema.sql`, `ARCHITECTURE.md`):

- `AgriShieldApp.jsx` — an aesthetic "super app" showcase spanning all three versions' features in one dark-themed screen.
- `AgriShieldMobileApp.jsx` — a usability-first, low-end-Android build of the brief in [`UI_UX_DESIGN_SPEC.md`](./UI_UX_DESIGN_SPEC.md), in that spec's own lighter palette.

Both are UI shells with hardcoded/simulated data, no backend. The two use different palettes and design intents by design — not yet reconciled into one canonical direction (see the spec doc's honest flags).

## The real build

[`/app`](../../app) (Flutter) and [`/backend`](../../backend) (FastAPI) are a V1 scaffold — real, running code, not a mockup, but every external integration (sensor hardware, the TFLite model, satellite, Africa's Talking) is mocked behind a small interface until the real thing exists. See [`V1_HACKATHON_DEMO.md`](./V1_HACKATHON_DEMO.md)'s "Build status" for exactly what's verified.

## Source documents

This roadmap was synthesized from `AgriShield_SuperApp_Hybrid.docx` (the master reconciliation of six earlier concepts — CEAShack, farmScreen, an earlier Agri-Shield draft, AgriChill Africa, MbudziGuard, Mari Hub), `AgriShield_Feasibility_Innovation_Improvement_Study.docx`, `AgriShield_POTRAZ_SolutionSpecification.docx`, and `AgriShield_Innovate.docx`, plus a fintech concept and a UI/schema prototype provided directly during planning. The original documents have been superseded by this roadmap and removed from the repo to avoid drift between two sources of truth; recover them from git history if needed.

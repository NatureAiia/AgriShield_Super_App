# AgriShield — Mobile UI Design Spec (8-Screen Demo)

**Status: written design brief only — not yet built.** This documents a UI/UX brief provided during planning, for a future interactive prototype or screen-mockup pass. No code was generated from it in this session; see [`/prototype`](../../prototype) for the one prototype that does exist (a different, earlier 5-tab build with its own palette — see **Reconciling with the existing prototype** below).

## Brief, as given

> Design a mobile app UI demo called "AgriShield" — a super app for smallholder farmers in Zimbabwe that bundles crop storage monitoring, offline disease screening, satellite field monitoring, a market/buyer connect feature, and a field robot control screen. Target device: a low-end Android phone, so the UI must be simple, high-contrast, icon-led, and readable at a glance — large tap targets, minimal text per screen, no clutter, designed for users who may have low literacy or limited data.

## Target device & usability constraints

- Low-end Android phone: simple, high-contrast, icon-led.
- Large tap targets, minimal text per screen, no clutter — designed for low-literacy and limited-data users.
- A persistent **offline indicator** in the top bar at all times: *"Working offline — will sync when connected"* — a constant, visible reminder that this app works without steady internet, not just a one-time toast.
- Interactions should feel like a real, usable low-bandwidth product, not a flashy concept app.

## Visual style

| Token | Value | Use |
|---|---|---|
| Primary | `#1B4332` (deep forest green) | primary brand color |
| Accent / active state | `#2D6A4F` (brighter leaf green) | accents, active nav/tab states |
| Alert / highlight | `#B45309` (warm amber) | alerts, highlights |
| Background | `#F1F8F4` (soft off-white) | app background |

Rounded cards, generous spacing, a bottom navigation bar with 5 icon tabs. Overall vibe: clean and warm, not corporate-cold.

## Screen flow (8 connected screens)

1. **Home dashboard** — greets the farmer by name; shelf-life countdown card ("Your maize: 14 hours of good condition left"); mold-risk status badge (green/amber/red); today's weather in one line; a scrollable row of quick-alert cards.
2. **Storage/Sensor screen** — live temperature and humidity reading from the solar sensor box; a simple 24-hour graph; the shelf-life countdown explained in one plain sentence.
3. **Disease Scan screen** — a big camera button to photograph a leaf; a result screen showing the likely issue, a confidence note ("first opinion, not a final answer"), and a button to "find an extension officer nearby."
4. **Satellite Map screen** — a simple district map, color-coded zones (green = healthy, amber = stressed, red = drought risk), a legend, tap-to-zoom on the farmer's own plot.
5. **Market Connect screen** — a card showing "Your wheat has a buyer," the buyer's name, distance, and a large "Call now" button — deliberately simple, no in-app pricing or checkout, just a direct contact introduction.
6. **Agri-Rover screen** — a status card: battery level (solar-charged), current field position on a mini-map, last scouting result, and a big "Send to Zone" button.
7. **Alerts/Notifications screen** — a chronological feed of every SMS/voice/text alert the farmer has received, grouped by day.
8. **Profile/Setup screen** — farmer name, rough location, crop type, and storage hub, editable in two taps.

With only 5 bottom-nav tabs for 8 screens, the natural split (not specified in the brief, left as an open question for whoever builds this) is: **5 primary tabs** — Home, Storage, Disease Scan, Satellite Map, Market Connect — with **Alerts and Profile** reached from Home (e.g. a header icon / quick-action card), matching the "Quick Services" pattern already used in `/prototype/AgriShieldApp.jsx`.

## Honest flags on this brief

Consistent with this roadmap's honesty principle (see [`README.md`](./README.md)):

- **The Agri-Rover screen conflicts with this roadmap's own scope.** `README.md` names the Agri-Rover explicitly as part of the out-of-scope "blue-sky" tier (`AgriShield_Innovate.docx`) — a real prior capstone-project robot design, not something any committed V1/V2/V3 version builds. If this screen gets built, it should be visibly marked as illustrating a **moonshot / future-vision** feature, not implying a working rover exists or is planned in the committed roadmap. This isn't a reason to drop the screen — the source docs treat the Agri-Rover as a real, named idea worth showing — just a reason not to present it as more built than it is.
- **This brief's screens roughly span V1 + V3, skipping V2 and most of the fintech layer.** Storage/Disease/Satellite map to V1 (hackathon demo); Market Connect maps to V3's simple contact-introduction feature (§14.5 in the original source material); none of V2's weather/price/planting/waste-to-feed/pest modules, and none of V3's insurance/BNPL/wallet features, appear here. That's a reasonable smaller cut for a design demo, not an error — just noted so nobody reads this as the full app's screen count.
- **The palette here differs from `/prototype/AgriShieldApp.jsx`'s existing dark slate/emerald/sky/indigo theme.** This brief specifies a lighter, warmer palette (`#1B4332` / `#2D6A4F` / `#B45309` / `#F1F8F4` on an off-white background) explicitly for low-end-device, high-contrast, low-literacy readability — a different design intent (usability-first) than the existing prototype (aesthetic super-app showcase). If both get built, they should be treated as two distinct design directions, not merged silently — pick one as canonical before a real build, or keep them as labeled alternatives.

## What unlocks building this

Nothing blocks starting a prototype build from this spec today — it depends on no unconfirmed partner or data source beyond what V1/V3 already name (see those docs). The one thing worth resolving first is the palette/scope reconciliation above, so a build doesn't have to be redone once that's settled.

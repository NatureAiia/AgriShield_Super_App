# V3 — Ecosystem, Market & Financial Services Layer

**When: later, gated by real evidence from V1/V2 — not a fixed date.**

## Goal

Turn the real reliability signal V1/V2 generated into real market access and real financial products, applying the same sequencing logic the source docs already use for the cold room: don't build unproven infrastructure on a guess, let real usage data — and real confirmed partners — justify it.

## Scope — what's built

### Market & hub access — simple version first
No scoring engine, no in-app payment. Once several collection points are running Parts 1 and 3, and Module 5 has proven itself: AgriShield sends one message — *"Your wheat in the storage bin has a buyer: [name], [location], [phone]"* — using Part 1's readiness signal and a maintained buyer list. Modeled on inDrive's approach: the app makes the introduction and never sets a price or touches the deal; farmer and buyer negotiate directly. **Flagged:** needs a real buyer-contact list (a cooperative's membership, a grain-marketing board's registered buyers, an agro-dealer directory) not yet sourced or confirmed.

### Marketplace & spot-price advisory — fuller version
Once real buyer/seller volume justifies it: a Kuwana-powered Best-Comparison-Index (BCI) scoring engine, extended to both produce buyers *and* input sellers (fertilizer, seed, solar kits) — reusing the same account/permission/explainable-match/audit-trail pattern Kuwana already runs in a live product (ZivaBasa). Every match carries a plain-language reason, never a bare score ("supplier X is cheapest, supplier Y costs more but reliably has stock, supplier Z is further but includes delivery"). The vegetable-only price feed from V2's Module 5 extends here to more commodities (maize, soybeans, tobacco, wheat) as real sources are found — grain prices were a named gap since V2, not invented here. **Flagged:** no partnership with a national grain buyer, transport broker, telecom, manufacturer, or agro-dealer has been discussed or confirmed; a good match-making design only becomes useful once real sellers actually sign up and keep listings current (the same cold-start challenge Kuwana's own bulk-import process is careful about, requiring a cited source for every price entered).

### Parametric micro-insurance
Satellite-index-triggered drought/moisture cover, reusing Part 3's Sentinel-2/GEE NDVI and soil-moisture pipeline from V1 — built once, no new data source needed — with automated payouts over the existing Africa's Talking mobile-money channel. Real-world analogues exist (index-insurance programs run by ACRE Africa and Pula Advisors elsewhere on the continent), which is why this is a credible direction, not a novel claim. **Said as plainly as everything else in this roadmap: no insurance underwriter partner is confirmed for AgriShield, and this does not ship until one is.**

### Agrifinance & BNPL wallet
Input-purchase credit (seed, fertilizer, solar kits), scored against the V2 AgriShield reliability score and disbursed through the input-seller matching layer above, repayable at harvest. **Flagged the same way: no lending or microfinance partner is confirmed**, and AgriShield does not set or guarantee BNPL terms/interest any more than the produce-matching layer sets a crop's price — its role stops at the introduction and the score, exactly like the simple market-intro layer above.

### Real solar cold room (~$30,000)
Built only once Part 1's own sensor data (accumulated across V1 and V2) proves real demand at a specific collection point — the same evidence-based case ColdHubs (Nigeria) and SoKo Fresh (Kenya) already prove works elsewhere in Africa. Not built on a guess.

### Cross-hub feedback loop
Once several collection points run Parts 1+3 together, a risk signal seen at one hub (a pest surge, a drought signal) can automatically flag a heightened risk to every nearby hub. Viable only after V1/V2 infrastructure exists at real scale — the concept isn't doubted, it's sequenced last because it needs several real hubs already running.

## Explicitly excluded from V3 and beyond

A separate "blue-sky" document (`AgriShield_Innovate.docx`, superseded and removed — see git history) proposed a further tier this roadmap does not commit to: an "Agri-Rover" field robot (see `V4_FUTURE_EXPLORATION.md`), a paid PlanetScope satellite upgrade with multi-index remote sensing (NDVI/NDMI/NDRE/MSAVI) and variable-rate application, black-soldier-fly/hydroponic/aquaculture automation, a full solar buildout across every hardware piece, and one unified rover+sensor+satellite+pricing architecture. These stay a named moonshot tier, not a committed phase — real ideas, explicitly out of scope here.

Even that blue-sky tier draws its own line, on purpose: drone spraying, seeding, and aerial mapping; fully autonomous tractors, combine harvesters, and robotic weeders sold as standalone products; heavy machinery implements (rotavators, ploughs, balers); RTK centimetre-accuracy positioning; and general agronomic-practice advice (permaculture, crop rotation) are all real technologies, just a different project from what AgriShield's own mechanism — sensors, phones, and the data they generate — naturally extends into.

## Tech / data sources

Kuwana's Best-Comparison-Index pattern (reused from its live ZivaBasa product) for scored matching; Part 3's existing Sentinel-2/GEE pipeline as the insurance trigger, no new satellite integration needed; Africa's Talking for both farmer messaging and mobile-money disbursement (BNPL, insurance payouts); Python/FastAPI + PostgreSQL extended with wallet/ledger and policy-record tables (see `/prototype/schema.sql` for a first-pass sketch of `insurance_policies` and `bnpl_loans`).

## Demo / acceptance criteria

- A real, sourced buyer-contact list exists for at least one crop/region before the simple market-intro feature ships.
- A named insurance underwriter and a named lending partner are confirmed and documented before parametric insurance or BNPL ship — not simulated as if they already exist.
- The cold-room funding case is backed by actual V1/V2 sensor data from a specific collection point, not a projection.

## Known limitations (said plainly)

- This entire version depends on real-world partnerships (buyers, an insurer, a lender, agro-dealers) that do not exist yet for AgriShield — say so at every mention, not once and then forgotten.
- A two-sided marketplace only works once enough real sellers sign up and keep listings current — the same cold-start problem every marketplace like this has.
- `/prototype`'s UI (wallet balance, active policy card, BNPL limit) shows illustrative sample data; none of it reflects a live integration.

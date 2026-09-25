import 'package:flutter/material.dart';

/// Which small animated teaser a coming-soon feature shows on its detail
/// page. Every preview runs on sample numbers and says so on screen.
enum FeaturePreview { forecast, prices, score, message }

/// A roadmap feature shown in the "Coming soon" showcase — V2/V3 items from
/// docs/roadmap/, labelled as not built yet everywhere they appear, with
/// the thing each one still needs said in the same breath (the roadmap's
/// honesty principle: the pitch says it's roadmap rather than implying it
/// exists).
class UpcomingFeature {
  final String id;
  final String version;
  final String title;
  final String tagline;
  final String description;
  final List<String> highlights;
  final String needsFirst;
  final IconData icon;
  final List<Color> gradient;
  final FeaturePreview preview;

  const UpcomingFeature({
    required this.id,
    required this.version,
    required this.title,
    required this.tagline,
    required this.description,
    required this.highlights,
    required this.needsFirst,
    required this.icon,
    required this.gradient,
    required this.preview,
  });
}

const upcomingFeatures = [
  UpcomingFeature(
    id: 'weather',
    version: 'V2',
    title: 'Weather alerts',
    tagline: 'Know when rain is coming',
    description:
        'A plain-language forecast for your own area, sent as an SMS or a voice call, even to phones with no data plan.',
    highlights: [
      '"Rain expected in two days — a good time to plant"',
      '"Dry spell ahead — check soil moisture"',
      'Up to 16 days ahead, free (Open-Meteo)',
    ],
    needsFirst: 'Built on a free public forecast API — no partner needed, just build time.',
    icon: Icons.thunderstorm_rounded,
    gradient: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    preview: FeaturePreview.forecast,
  ),
  UpcomingFeature(
    id: 'prices',
    version: 'V2',
    title: 'Market prices',
    tagline: 'Sell where the price is best',
    description:
        'Real vegetable prices from Mbare, Sakubva, Chipadze and Renkini markets, so you know where to sell before you travel.',
    highlights: [
      'Public prices from the Agricultural Marketing Authority',
      'Price alerts over SMS',
      'Vegetables first — grain prices still need a source',
    ],
    needsFirst: 'Vegetables only at first; grain prices are a named gap until a real source is found.',
    icon: Icons.storefront_rounded,
    gradient: [Color(0xFF7C2D12), Color(0xFFF59E0B)],
    preview: FeaturePreview.prices,
  ),
  UpcomingFeature(
    id: 'score',
    version: 'V2',
    title: 'AgriShield Score',
    tagline: 'Your good farming, counted',
    description:
        'A simple gauge that grows every time you act on an alert, scan a leaf, or protect your harvest — a record of good practice you own.',
    highlights: [
      'Built from what the app already sees',
      'Goes up when you act on alerts',
      'Transparent — you see what moved it',
    ],
    needsFirst: 'Not a credit score — no lender or credit bureau is involved yet.',
    icon: Icons.verified_rounded,
    gradient: [Color(0xFF14532D), Color(0xFF22C55E)],
    preview: FeaturePreview.score,
  ),
  UpcomingFeature(
    id: 'insurance',
    version: 'V3',
    title: 'Drought cover',
    tagline: 'Paid when the rain fails',
    description:
        'Micro-insurance triggered by the same satellite view you use today. If your district dries out, the payout goes straight to mobile money.',
    highlights: [
      'Uses the satellite map already in the app',
      'No claim forms — the satellite is the trigger',
      'Paid out over mobile money',
    ],
    needsFirst: 'Needs an insurance underwriter partner — none is confirmed yet, so this does not ship until one is.',
    icon: Icons.umbrella_rounded,
    gradient: [Color(0xFF4C1D95), Color(0xFFA855F7)],
    preview: FeaturePreview.message,
  ),
  UpcomingFeature(
    id: 'market',
    version: 'V3',
    title: 'Buyer connect',
    tagline: 'Your harvest meets a buyer',
    description:
        'When your stored crop is ready, AgriShield introduces you to a buyer nearby. You agree the price directly — the app never takes a cut of the deal.',
    highlights: [
      '"Your maize has a buyer: name, place, phone"',
      'You negotiate directly',
      'Later: inputs like seed and fertilizer too',
    ],
    needsFirst: 'Needs a real, sourced buyer list — not sourced yet.',
    icon: Icons.handshake_rounded,
    gradient: [Color(0xFF134E4A), Color(0xFF14B8A6)],
    preview: FeaturePreview.message,
  ),
  UpcomingFeature(
    id: 'coldroom',
    version: 'V3',
    title: 'Solar cold room',
    tagline: 'Shared cold storage at your hub',
    description:
        'A pay-as-you-go solar cold room at your collection point, like ColdHubs in Nigeria and SoKo Fresh in Kenya already run.',
    highlights: [
      'Pay per crate, per day',
      'Built where the sensor data proves the need',
      'Book a slot from your phone',
    ],
    needsFirst: 'About \$30,000 — built only once sensor data from a real hub proves demand.',
    icon: Icons.ac_unit_rounded,
    gradient: [Color(0xFF0C4A6E), Color(0xFF38BDF8)],
    preview: FeaturePreview.message,
  ),
];

/// Sample message each message-style preview "receives" — shown under a
/// "Preview — sample" label, never as a real notification.
const previewMessages = {
  'insurance': 'Drought detected in your district by satellite. Your cover has paid out to your mobile money.',
  'market': 'Good news! Your maize in storage has a buyer nearby. Reply 1 to get their name and number.',
  'coldroom': 'Your cold-room slot at Mbare Collection Point is booked for 3 crates, from tomorrow.',
};

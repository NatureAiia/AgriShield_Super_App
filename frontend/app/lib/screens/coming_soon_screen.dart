import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/upcoming_feature.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/coming_soon_carousel.dart';

/// Detail page for one roadmap feature: a gradient header (Hero-flown from
/// the Home card), what it will do, an animated preview on sample data,
/// and — in the same view — what it still needs before it can ship.
class ComingSoonScreen extends StatefulWidget {
  final UpcomingFeature feature;
  const ComingSoonScreen({super.key, required this.feature});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  bool _notify = false;

  String get _prefsKey => 'notify_${widget.feature.id}';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() => _notify = prefs.getBool(_prefsKey) ?? false);
    }).catchError((_) {});
  }

  Future<void> _toggleNotify() async {
    setState(() => _notify = !_notify);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, _notify);
    } catch (_) {
      // Remembering the choice is a convenience; the toggle still works.
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(feature: f)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Text(f.description, style: TextStyle(fontSize: 16, height: 1.4, color: context.colors.onSurface))
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 400.ms),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('PREVIEW', style: context.text.labelSmall),
                          const Spacer(),
                          Text(
                            'Sample data',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: context.colors.onSurface.withValues(alpha: 0.55)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Preview(feature: f),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                for (var i = 0; i < f.highlights.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 20, color: f.gradient.last),
                        const SizedBox(width: 10),
                        Expanded(child: Text(f.highlights[i], style: TextStyle(color: context.colors.onSurface))),
                      ],
                    ),
                  ).animate().fadeIn(delay: (500 + i * 100).ms, duration: 350.ms).slideX(begin: 0.1, end: 0),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      AgriShieldStatus.moderate.withValues(alpha: context.isDark ? 0.22 : 0.14),
                      context.colors.surface,
                    ),
                    borderRadius: BorderRadius.circular(AgriShieldRadii.control),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.flag_rounded, size: 18, color: AgriShieldStatus.text(AgriShieldStatus.moderate, context.isDark)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Before it ships: ${f.needsFirst}',
                          style: TextStyle(fontSize: 13, color: AgriShieldStatus.text(AgriShieldStatus.moderate, context.isDark)),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _toggleNotify,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                      child: Icon(
                        _notify ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                        key: ValueKey(_notify),
                      ),
                    ),
                    label: Text(_notify ? "You'll be told first" : 'Notify me when it launches'),
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UpcomingFeature feature;
  const _Header({required this.feature});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Hero(
      tag: 'feature-${feature.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, top + 8, 16, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: feature.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Stack(
            children: [
              // Soft drifting glow behind the icon — ambient motion only.
              Positioned(
                right: -30,
                top: 10,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.10)),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 0.85, end: 1.1, duration: 2600.ms, curve: Curves.easeInOut),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    tooltip: 'Back',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(feature.icon, color: Colors.white, size: 44)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .rotate(begin: -0.02, end: 0.02, duration: 1600.ms, curve: Curves.easeInOut),
                      const SizedBox(width: 12),
                      ComingSoonBadge(label: 'COMING SOON · ${feature.version}'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    feature.title,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(feature.tagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final UpcomingFeature feature;
  const _Preview({required this.feature});

  @override
  Widget build(BuildContext context) {
    switch (feature.preview) {
      case FeaturePreview.forecast:
        return const _ForecastPreview();
      case FeaturePreview.prices:
        return _PricesPreview(color: feature.gradient.last);
      case FeaturePreview.score:
        return _ScorePreview(color: feature.gradient.last);
      case FeaturePreview.message:
        return _MessagePreview(text: previewMessages[feature.id] ?? '', color: feature.gradient.last);
    }
  }
}

class _ForecastPreview extends StatelessWidget {
  const _ForecastPreview();

  static const _days = [
    ('Thu', Icons.wb_sunny_rounded, '31°', Color(0xFFF59E0B)),
    ('Fri', Icons.wb_cloudy_rounded, '28°', Color(0xFF94A3B8)),
    ('Sat', Icons.grain_rounded, '24°', Color(0xFF3B82F6)),
    ('Sun', Icons.thunderstorm_rounded, '22°', Color(0xFF6366F1)),
    ('Mon', Icons.wb_sunny_rounded, '27°', Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _days.length; i++)
              Column(
                children: [
                  Text(_days[i].$1, style: context.text.labelSmall),
                  const SizedBox(height: 6),
                  Icon(_days[i].$2, color: _days[i].$4, size: 30)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: 0, end: -4, delay: (i * 150).ms, duration: 900.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 6),
                  Text(_days[i].$3, style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                ],
              ).animate().fadeIn(delay: (450 + i * 90).ms).slideY(begin: 0.3, end: 0),
          ],
        ),
        const SizedBox(height: 14),
        const _MessagePreview(
          text: 'Rain expected on Saturday — a good time to plant your maize.',
          color: Color(0xFF3B82F6),
          delayMs: 1100,
        ),
      ],
    );
  }
}

class _PricesPreview extends StatelessWidget {
  final Color color;
  const _PricesPreview({required this.color});

  static const _markets = [('Mbare', 0.92), ('Sakubva', 0.70), ('Chipadze', 0.58), ('Renkini', 0.76)];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Tomatoes, per crate', style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < _markets.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (i == 0)
                          Icon(Icons.emoji_events_rounded, size: 18, color: color)
                              .animate()
                              .fadeIn(delay: 1300.ms)
                              .scaleXY(begin: 0.3, end: 1, curve: Curves.easeOutBack),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _markets[i].$2),
                          duration: Duration(milliseconds: 900 + i * 120),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => Container(
                            height: 90 * v,
                            decoration: BoxDecoration(
                              color: i == 0 ? color : color.withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_markets[i].$1, style: TextStyle(fontSize: 11, color: context.colors.onSurface)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScorePreview extends StatelessWidget {
  final Color color;
  const _ScorePreview({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 0.72),
        duration: const Duration(milliseconds: 1800),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(170),
                painter: _ArcPainter(progress: v, color: color, track: context.colors.outline),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (v * 100).toStringAsFixed(0),
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: context.colors.onSurface),
                  ),
                  Text('of 100', style: context.text.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 270° gauge arc, open at the bottom.
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  _ArcPainter({required this.progress, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    const start = pi * 0.75;
    const sweep = pi * 1.5;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, start, sweep, false, base..color = track);
    canvas.drawArc(arcRect, start, sweep * progress, false, base..color = color);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.color != color || old.track != track;
}

/// An SMS arriving on a basic phone: typing dots, then the bubble pops in.
class _MessagePreview extends StatelessWidget {
  final String text;
  final Color color;
  final int delayMs;
  const _MessagePreview({required this.text, required this.color, this.delayMs = 400});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color,
          backgroundImage: const AssetImage('assets/branding/logo.jpeg'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // Typing indicator, fades out as the bubble lands.
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 4, bottom: 10),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.6), shape: BoxShape.circle),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -4, delay: (i * 120).ms, duration: 300.ms),
                ],
              ).animate().fadeOut(delay: (delayMs + 700).ms, duration: 150.ms),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(color.withValues(alpha: context.isDark ? 0.28 : 0.14), context.colors.surface),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AgriShield · SMS', style: context.text.labelSmall),
                    const SizedBox(height: 4),
                    Text(text, style: TextStyle(color: context.colors.onSurface, height: 1.35)),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (delayMs + 750).ms, duration: 250.ms)
                  .scaleXY(begin: 0.8, end: 1, alignment: Alignment.bottomLeft, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ],
    );
  }
}

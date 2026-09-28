import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/upcoming_feature.dart';
import '../screens/coming_soon_screen.dart';
import '../theme.dart';
import 'pressable.dart';

/// Home's "Coming soon" row — V2/V3 roadmap features as tappable gradient
/// cards, each carrying a COMING SOON badge so nothing reads as built.
/// Sits below the real V1 signals, never mixed in with them.
class ComingSoonCarousel extends StatelessWidget {
  const ComingSoonCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.rocket_launch_rounded, size: 18, color: context.colors.secondary),
            const SizedBox(width: 6),
            Expanded(child: Text("WHAT'S COMING NEXT", style: context.text.labelSmall)),
            Text('Swipe', style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.5))),
            Icon(Icons.chevron_right, size: 16, color: context.colors.onSurface.withValues(alpha: 0.5))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: -2, end: 3, duration: 700.ms, curve: Curves.easeInOut),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: upcomingFeatures.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _FeatureCard(feature: upcomingFeatures[i])
                .animate()
                .fadeIn(delay: (400 + i * 90).ms, duration: 400.ms)
                .slideX(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final UpcomingFeature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => ComingSoonScreen(feature: feature),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      child: Hero(
        tag: 'feature-${feature.id}',
        // Hero flies the card's gradient into the detail page's header.
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: feature.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AgriShieldRadii.card),
              boxShadow: [
                BoxShadow(
                  color: feature.gradient.last.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(feature.icon, color: Colors.white, size: 26)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 1, end: 1.12, duration: 1400.ms, curve: Curves.easeInOut),
                    const Spacer(),
                    const ComingSoonBadge(),
                  ],
                ),
                const Spacer(),
                Text(
                  feature.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small shimmering "SOON" pill — white on a dark translucent backdrop so
/// it stays legible on every card gradient.
class ComingSoonBadge extends StatelessWidget {
  final String label;
  const ComingSoonBadge({super.key, this.label = 'SOON'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1800.ms, delay: 1200.ms, color: Colors.white54);
  }
}

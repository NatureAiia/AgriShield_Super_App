import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

/// Branded loading screen — the AgriShield logo with soft ripples and a
/// sliding progress bar. Shown at startup while the local sign-in check
/// and farmer record load (see main.dart).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 0.9,
            colors: [context.colors.surface, Theme.of(context).scaffoldBackgroundColor],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final delay in [0, 1000])
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primary.withValues(alpha: 0.45), width: 2),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(), delay: delay.ms)
                        .scaleXY(begin: 0.92, end: 1.3, duration: 2000.ms, curve: Curves.easeOut)
                        .fadeOut(duration: 2000.ms, curve: Curves.easeOut),
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: context.softShadow),
                    child: ClipOval(child: Image.asset('assets/branding/logo.jpeg', fit: BoxFit.cover)),
                  ).animate().scaleXY(begin: 0.7, end: 1, duration: 700.ms, curve: Curves.easeOutBack).fadeIn(duration: 400.ms),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'AgriShield',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: primary),
            ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 4),
            Text(
              'Keep your harvest safe',
              style: TextStyle(fontSize: 13, color: context.palette.muted),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            const SizedBox(height: 26),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 140,
                height: 5,
                color: context.palette.surface3,
                alignment: Alignment.centerLeft,
                child: Container(width: 56, height: 5, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(99)))
                    .animate(onPlay: (c) => c.repeat())
                    .moveX(begin: -60, end: 150, duration: 1200.ms, curve: Curves.easeInOut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

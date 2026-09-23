import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

/// First screen a new install shows — a returning, already-signed-in
/// farmer skips straight past this to the app (see main.dart), matching
/// the research-backed pattern of not re-gating access behind a login
/// screen every launch.
class LandingScreen extends StatelessWidget {
  final AuthService authService;
  final VoidCallback onAuthenticated;

  const LandingScreen({super.key, required this.authService, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _glow(context.colors.secondary, 220),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _glow(context.colors.primary, 260),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/branding/logo.jpeg', width: 96, height: 96, fit: BoxFit.cover),
                  ).animate().scaleXY(begin: 0.7, end: 1, duration: 500.ms, curve: Curves.easeOutBack).fadeIn(duration: 350.ms),
                  const SizedBox(height: 24),
                  Text(
                    'AgriShield',
                    style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: context.colors.onSurface),
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 10),
                  Text(
                    'Watch your storage, check a sick plant, and see your\nfield from space — even with no signal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.5, color: context.colors.onSurface.withValues(alpha: 0.65)),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const Spacer(flex: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SignUpScreen(authService: authService, onAuthenticated: onAuthenticated),
                        ),
                      ),
                      child: const Text('Get started'),
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SignInScreen(authService: authService, onAuthenticated: onAuthenticated),
                        ),
                      ),
                      child: const Text('I already have an account'),
                    ),
                  ).animate().fadeIn(delay: 420.ms, duration: 400.ms),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)]),
      ),
    );
  }
}

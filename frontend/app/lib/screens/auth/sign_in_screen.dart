import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../repositories/farmer_repository.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

class SignInScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onAuthenticated;

  const SignInScreen({super.key, required this.authService, required this.onAuthenticated});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController = TextEditingController();
  bool _signingIn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canContinue => _phoneController.text.trim().length >= 9 && !_signingIn;

  Future<void> _signIn() async {
    setState(() {
      _signingIn = true;
      _errorMessage = null;
    });
    try {
      final farmer = await widget.authService.signIn(phone: _phoneController.text.trim());
      await FarmerRepository().save(farmer);
      if (!mounted) return;
      widget.onAuthenticated();
    } on NoAccountFound {
      if (!mounted) return;
      setState(() {
        _signingIn = false;
        _errorMessage = 'No account found for this number — go back and use "Get started" instead.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _signingIn = false;
        _errorMessage = 'Could not reach the server — check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: context.colors.onSurface, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back', style: context.text.headlineSmall)
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 6),
            Text(
              'Enter the phone number you signed up with.',
              style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.6)),
            ).animate().fadeIn(delay: 80.ms, duration: 350.ms),
            const SizedBox(height: 28),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+263 77 123 4567',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ).animate().fadeIn(delay: 140.ms, duration: 350.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue ? _signIn : null,
                child: _signingIn
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onSecondary),
                      )
                    : const Text('Sign in'),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: context.colors.error, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ).animate().fadeIn(duration: 200.ms),
          ],
        ),
      ),
    );
  }
}

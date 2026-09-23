import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/farmer.dart';
import '../../repositories/farmer_repository.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/otp_input.dart';

/// Shared code-entry step for both sign-up and sign-in — the phone number
/// and (for a new account) the farmer record collected on the previous
/// screen are just carried through and saved once the code checks out.
class OtpScreen extends StatefulWidget {
  final AuthService authService;
  final String phone;
  final Farmer? farmerDraft;
  final VoidCallback onAuthenticated;

  const OtpScreen({
    super.key,
    required this.authService,
    required this.phone,
    required this.onAuthenticated,
    this.farmerDraft,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpKey = GlobalKey<OtpInputState>();
  String? _demoCode;
  bool _verifying = false;
  bool _shakeError = false;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  Future<void> _sendCode() async {
    final code = await widget.authService.requestOtp(widget.phone);
    if (!mounted) return;
    setState(() => _demoCode = code);
  }

  Future<void> _verify(String code) async {
    setState(() {
      _verifying = true;
      _shakeError = false;
    });
    final ok = await widget.authService.verifyOtp(widget.phone, code);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _verifying = false;
        _shakeError = true;
      });
      _otpKey.currentState?.clear();
      return;
    }
    final draft = widget.farmerDraft;
    if (draft != null) {
      await FarmerRepository().save(draft);
    }
    if (!mounted) return;
    widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: context.colors.onSurface, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Icon(Icons.sms_outlined, size: 40, color: context.colors.secondary)
                .animate()
                .fadeIn(duration: 350.ms)
                .scaleXY(begin: 0.6, end: 1, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text('Enter the code', style: context.text.titleMedium)
                .animate()
                .fadeIn(delay: 80.ms, duration: 350.ms),
            const SizedBox(height: 6),
            Text(
              'Sent to ${widget.phone} over Africa\'s Talking',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.colors.onSurface.withValues(alpha: 0.6)),
            ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
            const SizedBox(height: 32),
            OtpInput(key: _otpKey, onCompleted: _verify)
                .animate(target: _shakeError ? 1 : 0)
                .shake(hz: 4, curve: Curves.easeOut, duration: 400.ms),
            const SizedBox(height: 16),
            if (_verifying)
              SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: context.colors.secondary)),
            if (_shakeError && !_verifying)
              Text('That code didn\'t match — try again.', style: TextStyle(color: context.colors.error, fontWeight: FontWeight.w600))
                  .animate()
                  .fadeIn(duration: 200.ms),
            const Spacer(),
            if (_demoCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.colors.secondary.withValues(alpha: context.isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(AgriShieldRadii.control),
                ),
                child: Text(
                  'Demo mode — no SMS account is configured yet (see backend/.env.example),\n'
                  'so the code is shown here instead of texted: $_demoCode',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.75)),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

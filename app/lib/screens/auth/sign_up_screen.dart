import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/farmer.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import 'otp_screen.dart';

/// Collects the same Foundation farmer record fields
/// (docs/roadmap/README.md) that Profile lets you edit later — name, rough
/// location, crop, storage hub — plus the phone number the OTP goes to.
class SignUpScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onAuthenticated;

  const SignUpScreen({super.key, required this.authService, required this.onAuthenticated});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _crop = TextEditingController();
  final _storageHub = TextEditingController();

  @override
  void dispose() {
    for (final c in [_phone, _name, _location, _crop, _storageHub]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canContinue =>
      _phone.text.trim().length >= 9 &&
      _name.text.trim().isNotEmpty &&
      _location.text.trim().isNotEmpty &&
      _crop.text.trim().isNotEmpty &&
      _storageHub.text.trim().isNotEmpty;

  void _continue() {
    final draft = Farmer(
      name: _name.text.trim(),
      location: _location.text.trim(),
      crop: _crop.text.trim(),
      storageHub: _storageHub.text.trim(),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          authService: widget.authService,
          phone: _phone.text.trim(),
          farmerDraft: draft,
          onAuthenticated: widget.onAuthenticated,
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? type, List<TextInputFormatter>? formatters}) {
    return TextField(
      controller: c,
      keyboardType: type,
      inputFormatters: formatters,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: context.colors.onSurface, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Text('Create your account', style: context.text.headlineSmall)
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 6),
          Text(
            'One shared record — used across storage alerts, disease scans and the satellite view.',
            style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.6)),
          ).animate().fadeIn(delay: 60.ms, duration: 350.ms),
          const SizedBox(height: 24),
          for (final (i, w) in [
            _field(_phone, 'Phone number', Icons.phone_outlined,
                type: TextInputType.phone, formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))]),
            _field(_name, 'Name', Icons.person_outline),
            _field(_location, 'Location', Icons.location_on_outlined),
            _field(_crop, 'Crop', Icons.grass_outlined),
            _field(_storageHub, 'Storage hub', Icons.warehouse_outlined),
          ].indexed) ...[
            w.animate().fadeIn(delay: (100 + i * 60).ms, duration: 300.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canContinue ? _continue : null,
              child: const Text('Send code'),
            ),
          ).animate().fadeIn(delay: 480.ms, duration: 350.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

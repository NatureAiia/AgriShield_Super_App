import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/farmer.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import 'farmer_story_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Farmer farmer;
  final FarmerRepository repository;
  final ValueChanged<Farmer> onSaved;
  final VoidCallback onSignOut;

  const ProfileScreen({
    super.key,
    required this.farmer,
    required this.repository,
    required this.onSaved,
    required this.onSignOut,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Farmer _farmer = widget.farmer;
  String? _editingField;
  late final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(text: _farmer.name),
    'location': TextEditingController(text: _farmer.location),
    'crop': TextEditingController(text: _farmer.crop),
    'storageHub': TextEditingController(text: _farmer.storageHub),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _commit(String key) async {
    final value = _controllers[key]!.text;
    setState(() {
      _farmer = switch (key) {
        'name' => _farmer.copyWith(name: value),
        'location' => _farmer.copyWith(location: value),
        'crop' => _farmer.copyWith(crop: value),
        _ => _farmer.copyWith(storageHub: value),
      };
      _editingField = null;
    });
    await widget.repository.save(_farmer);
    widget.onSaved(_farmer);
  }

  Widget _field(BuildContext context, String key, String label, String value) {
    final editing = _editingField == key;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: context.text.labelSmall),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: editing
                      ? TextField(
                          key: const ValueKey('editing'),
                          controller: _controllers[key],
                          autofocus: true,
                          onSubmitted: (_) => _commit(key),
                          style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface),
                        )
                      : Text(
                          value,
                          key: const ValueKey('display'),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.colors.onSurface),
                        ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(editing ? Icons.check : Icons.edit, color: editing ? context.colors.secondary : context.colors.onSurface),
            onPressed: () {
              if (editing) {
                _commit(key);
              } else {
                setState(() => _editingField = key);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('name', 'Name', _farmer.name),
      ('location', 'Location', _farmer.location),
      ('crop', 'Crop', _farmer.crop),
      ('storageHub', 'Storage hub', _farmer.storageHub),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          _field(context, fields[i].$1, fields[i].$2, fields[i].$3)
              .animate()
              .fadeIn(delay: (i * 60).ms, duration: 350.ms)
              .slideX(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Tap the icon, edit, tap the check — two taps to update.',
            style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.6)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FarmerStoryScreen())),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('How AgriShield helps you'),
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(foregroundColor: context.colors.error, side: BorderSide(color: context.colors.error)),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You\'ll need the code sent to your phone to sign back in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed == true) widget.onSignOut();
  }
}

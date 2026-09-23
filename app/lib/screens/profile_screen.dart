import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/farmer.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

class ProfileScreen extends StatefulWidget {
  final Farmer farmer;
  final FarmerRepository repository;
  final ValueChanged<Farmer> onSaved;

  const ProfileScreen({super.key, required this.farmer, required this.repository, required this.onSaved});

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
      ],
    );
  }
}

import 'package:flutter/material.dart';
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

  Widget _field(String key, String label, String value) {
    final editing = _editingField == key;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                editing
                    ? TextField(
                        controller: _controllers[key],
                        autofocus: true,
                        onSubmitted: (_) => _commit(key),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AgriShieldColors.primary),
                      )
                    : Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AgriShieldColors.primary)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(editing ? Icons.check : Icons.edit, color: editing ? AgriShieldColors.accent : AgriShieldColors.primary),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _field('name', 'Name', _farmer.name),
        const SizedBox(height: 10),
        _field('location', 'Location', _farmer.location),
        const SizedBox(height: 10),
        _field('crop', 'Crop', _farmer.crop),
        const SizedBox(height: 10),
        _field('storageHub', 'Storage hub', _farmer.storageHub),
        const SizedBox(height: 16),
        const Center(
          child: Text('Tap the icon, edit, tap the check — two taps to update.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      ],
    );
  }
}

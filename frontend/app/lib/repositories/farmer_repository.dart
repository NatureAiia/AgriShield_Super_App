import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer.dart';

/// The Foundation's "works with no signal, syncs when a connection
/// returns" farmer record (docs/roadmap/README.md). Stored locally first;
/// syncing it to the backend is a later step this repository leaves a
/// clear seam for (see the TODO), not yet built.
class FarmerRepository {
  static const _storageKey = 'agrishield_farmer_v1';

  Future<Farmer> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return Farmer.demo();
    return Farmer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(Farmer farmer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(farmer.toJson()));
    // TODO(V1->V2): queue a sync to POST /farmers on the backend once
    // connectivity returns, instead of local-only storage.
  }
}

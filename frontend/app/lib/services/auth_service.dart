import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer.dart';
import 'api_config.dart';

/// Foundation — phone-number sign-in with no password or code, matching the
/// backend (`POST /farmers`, `GET /farmers/by-phone/{phone}`).
/// A deliberate demo-scope tradeoff for a one-step, low-friction flow on
/// shared/low-literacy devices — not a production auth story (see Farmer's
/// docstring in backend/app/models.py). The previous OTP-over-SMS step was
/// removed in V1 finalization: no Africa's Talking SMS account exists, so
/// the "demo code on screen" proved nothing and added a full screen of
/// friction before a judge ever saw the storage cooler working.
abstract class AuthService {
  Future<bool> isSignedIn();
  Future<Farmer> signUp({required Farmer draft});
  Future<Farmer> signIn({required String phone});
  Future<void> signOut();
}

/// Thrown by [AuthService.signIn] when no account exists for the number —
/// the caller should point the farmer at sign-up instead.
class NoAccountFound implements Exception {
  final String phone;
  const NoAccountFound(this.phone);
  @override
  String toString() => 'No account found for $phone';
}

/// Thrown by [AuthService.signUp] when the number already has an account —
/// the caller should point the farmer at sign-in instead.
class PhoneAlreadyRegistered implements Exception {
  final String phone;
  const PhoneAlreadyRegistered(this.phone);
  @override
  String toString() => 'An account already exists for $phone';
}

const _signedInKey = 'agrishield_signed_in_phone_v1';

/// Calls the real backend so sign-up/sign-in persist server-side in
/// Postgres and sync across devices/reinstalls, instead of
/// MockAuthService's local-only, single-device version.
class HttpAuthService implements AuthService {
  @override
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_signedInKey) != null;
  }

  @override
  Future<Farmer> signUp({required Farmer draft}) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/farmers'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(draft.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 409) {
      throw PhoneAlreadyRegistered(draft.phone);
    }
    if (response.statusCode != 200) {
      throw Exception('Could not create the account (${response.statusCode})');
    }
    final farmer = Farmer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    await _markSignedIn(farmer.phone);
    return farmer;
  }

  @override
  Future<Farmer> signIn({required String phone}) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/farmers/by-phone/$phone'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 404) throw NoAccountFound(phone);
    if (response.statusCode != 200) {
      throw Exception('Could not sign in (${response.statusCode})');
    }
    final farmer = Farmer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    await _markSignedIn(farmer.phone);
    return farmer;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signedInKey);
  }

  Future<void> _markSignedIn(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signedInKey, phone);
  }
}

/// Local-only reference implementation — no backend round trip at all.
/// Kept for offline development; not wired into main.dart by default.
class MockAuthService implements AuthService {
  final Map<String, Farmer> _accounts = {};

  @override
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_signedInKey) != null;
  }

  @override
  Future<Farmer> signUp({required Farmer draft}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_accounts.containsKey(draft.phone)) {
      throw PhoneAlreadyRegistered(draft.phone);
    }
    _accounts[draft.phone] = draft;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signedInKey, draft.phone);
    return draft;
  }

  @override
  Future<Farmer> signIn({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final farmer = _accounts[phone];
    if (farmer == null) throw NoAccountFound(phone);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signedInKey, phone);
    return farmer;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signedInKey);
  }
}

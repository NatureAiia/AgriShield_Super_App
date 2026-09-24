import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer.dart';
import 'api_config.dart';

/// Foundation — phone-number + OTP sign-in, the standard pattern for this
/// demographic and one that reuses the Africa's Talking SMS channel the
/// roadmap already commits to for alerts, rather than introducing a new
/// one. No SMS credentials exist yet (same gap as MessagingService), so
/// neither implementation here can actually send a text — both return the
/// generated code directly so the UI can show it on-screen as a labeled
/// demo code instead of pretending to send it.
abstract class AuthService {
  Future<bool> isSignedIn();
  Future<String> requestOtp(String phone);
  Future<OtpVerifyResult> verifyOtp(String phone, String code);
  Future<Farmer> completeSignUp({required String phone, required Farmer draft});
  Future<void> signOut();
}

/// Result of a code check: [codeValid] is whether the code matched;
/// [farmer] is the existing account for that phone, if any — present on a
/// returning sign-in, absent for a number that hasn't signed up yet
/// (the caller then completes sign-up via [AuthService.completeSignUp]).
class OtpVerifyResult {
  final bool codeValid;
  final Farmer? farmer;
  const OtpVerifyResult({required this.codeValid, this.farmer});
}

const _signedInKey = 'agrishield_signed_in_phone_v1';

/// Calls the real backend (backend/app/routers/auth.py) so sign-up/sign-in
/// persist server-side in Postgres and sync across devices/reinstalls,
/// instead of MockAuthService's local-only, single-device version.
class HttpAuthService implements AuthService {
  @override
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_signedInKey) != null;
  }

  @override
  Future<String> requestOtp(String phone) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/auth/request-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not request a code (${response.statusCode})');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['code'] as String;
  }

  @override
  Future<OtpVerifyResult> verifyOtp(String phone, String code) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone, 'code': code}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 400) return const OtpVerifyResult(codeValid: false);
    if (response.statusCode != 200) {
      throw Exception('Could not verify the code (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final farmerJson = data['farmer'] as Map<String, dynamic>?;
    final result = OtpVerifyResult(codeValid: true, farmer: farmerJson == null ? null : Farmer.fromJson(farmerJson));
    if (result.farmer != null) await _markSignedIn(phone);
    return result;
  }

  @override
  Future<Farmer> completeSignUp({required String phone, required Farmer draft}) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/farmers'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(draft.copyWith(phone: phone).toJson()),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not create the account (${response.statusCode})');
    }
    await _markSignedIn(phone);
    return Farmer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
  final Random _random = Random();
  String? _pendingCode;
  final Map<String, Farmer> _accounts = {};

  @override
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_signedInKey) != null;
  }

  @override
  Future<String> requestOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _pendingCode = (1000 + _random.nextInt(9000)).toString();
    return _pendingCode!;
  }

  @override
  Future<OtpVerifyResult> verifyOtp(String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (code != _pendingCode) return const OtpVerifyResult(codeValid: false);
    _pendingCode = null;
    final farmer = _accounts[phone];
    if (farmer != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_signedInKey, phone);
    }
    return OtpVerifyResult(codeValid: true, farmer: farmer);
  }

  @override
  Future<Farmer> completeSignUp({required String phone, required Farmer draft}) async {
    final farmer = draft.copyWith(phone: phone);
    _accounts[phone] = farmer;
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

import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Foundation — phone-number + OTP sign-in, the standard pattern for this
/// demographic (no email assumed, reuses the Africa's Talking SMS channel
/// the roadmap already commits to for alerts — see
/// backend/app/services/messaging_service.py).
///
/// No SMS credentials exist yet (same gap as MessagingService), so
/// [MockAuthService] can't actually send a text. Instead of pretending to,
/// [requestOtp] returns the generated code directly so the UI can show it
/// on-screen as a labeled demo code — same "mock, plainly flagged" honesty
/// principle as every other V1 integration, not a silent fake.
abstract class AuthService {
  Future<bool> isSignedIn();
  Future<String> requestOtp(String phone);
  Future<bool> verifyOtp(String phone, String code);
  Future<void> signOut();
}

class MockAuthService implements AuthService {
  static const _signedInKey = 'agrishield_signed_in_phone_v1';
  final Random _random = Random();
  String? _pendingCode;

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
  Future<bool> verifyOtp(String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (code != _pendingCode) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signedInKey, phone);
    _pendingCode = null;
    return true;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signedInKey);
  }
}

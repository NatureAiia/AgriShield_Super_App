/// Backend base URL. 10.0.2.2 is the Android emulator's alias for the host
/// machine's localhost — point this at a real deployment once one exists.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'AGRISHIELD_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}

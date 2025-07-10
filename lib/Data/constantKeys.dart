import 'package:shared_preferences/shared_preferences.dart';

class ConstantKeys {
  static const apiKeys = [
    "cm4pq3ji8000bkw03swp8lr20",
    "cm4pq73z70003l5032ofb9nts",
  ];
}

class ApiKeyManager {
  static SharedPreferences? _prefs;
  static int _currentKeyIndex = 0;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentKeyIndex = _prefs?.getInt('api_key_index') ?? 0;
    print(" init api_key_index: $_currentKeyIndex");
  }

  static String get currentApiKey => ConstantKeys.apiKeys[_currentKeyIndex];

  static Future<void> moveToNextKey() async {
    _currentKeyIndex = (_currentKeyIndex + 1) % ConstantKeys.apiKeys.length;
    await _prefs?.setInt('api_key_index', _currentKeyIndex);
    print(" init api_key_index: $_currentKeyIndex");
  }
}

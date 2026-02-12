// Core Configuration
class Config {
  static late String _baseUrl;
  static late String _apiBaseUrl;
  static late bool _isDebug;
  
  static String get baseUrl => _baseUrl;
  static String get apiBaseUrl => _apiBaseUrl;
  static bool get isDebug => _isDebug;
  
  static Future<void> init() async {
    // 從環境變數或配置讀取
    _baseUrl = 'https://api.nicespeak.app';
    _apiBaseUrl = '$_baseUrl/api';
    _isDebug = true; // 生產環境改為 false
  }
  
  // API 端點
  static const String kAuthLogin = '/auth/login';
  static const String kAuthLogout = '/auth/logout';
  static const String kAuthMe = '/auth/me';
  static const String kScenarios = '/scenarios';
  static const String kPracticeStart = '/practice/start';
  static const String kPracticeSubmit = '/practice/submit';
  static const String kUserProfile = '/users/me';
  static const String kUserSubscription = '/users/me/subscription';
}

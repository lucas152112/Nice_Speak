import 'package:flutter/foundation.dart';
import 'services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  
  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  
  // 等級資訊
  int get level => _user?.level ?? 1;
  int get xp => _user?.xp ?? 0;
  int get xpToNextLevel => _user?.xpToNextLevel ?? 1000;
  double get levelProgress => xpToNextLevel > 0 ? xp / xpToNextLevel : 0;
  
  // 訂閱狀態
  bool get isPremium => _user?.subscriptionActive ?? false;
  String get subscriptionPlan => _user?.subscriptionPlan ?? 'free';
  
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 檢查本地 Token
      // TODO: 從 Secure Storage 讀取 Token
      _token = null;
      
      if (_token != null) {
        _isAuthenticated = true;
        await fetchCurrentUser();
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService().login(email, password);
      _token = response.accessToken;
      _user = response.user;
      _isAuthenticated = true;
      
      // 保存 Token
      // TODO: 保存到 Secure Storage
      
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    try {
      await ApiService().logout();
    } catch (e) {
      // 即使 API 失敗也清除本地狀態
    }
    
    _user = null;
    _token = null;
    _isAuthenticated = false;
    
    // 清除本地存儲
    // TODO: 清除 Secure Storage
    
    notifyListeners();
  }
  
  Future<void> fetchCurrentUser() async {
    if (!_isAuthenticated) return;
    
    try {
      _user = await ApiService().getCurrentUser();
      notifyListeners();
    } catch (e) {
      if (e is ApiException && e.code == 401) {
        await logout();
      }
    }
  }
  
  void updateUserLevel(int level, int xp, int xpToNextLevel) {
    if (_user != null) {
      _user = _user!.copyWith(level: level, xp: xp, xpToNextLevel: xpToNextLevel);
      notifyListeners();
    }
  }
}

extension on UserModel {
  UserModel copyWith({
    int? level,
    int? xp,
    int? xpToNextLevel,
    String? subscriptionPlan,
    bool? subscriptionActive,
  }) {
    return UserModel(
      id: this.id,
      email: this.email,
      name: this.name,
      avatar: this.avatar,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
    );
  }
}

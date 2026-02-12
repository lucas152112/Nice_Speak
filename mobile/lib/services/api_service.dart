import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'core/config.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();
  
  late Dio _dio;
  
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: Config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));
    
    // 添加攔截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加 Token
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token 過期，導向登入頁
          // TODO: 導向登入頁
        }
        handler.next(error);
      },
    ));
    
    // Debug 模式打印日誌
    if (Config.isDebug) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }
  
  // Token 管理
  Future<String?> _getToken() async {
    // TODO: 從 Secure Storage 讀取
    return null;
  }
  
  // ========== Auth APIs ==========
  
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(Config.kAuthLogin, data: {
        'email': email,
        'password': password,
      });
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> logout() async {
    try {
      await _dio.post(Config.kAuthLogout);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(Config.kAuthMe);
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ========== Scenario APIs ==========
  
  Future<List<ScenarioModel>> getScenarios({
    String? category,
    String? level,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (level != null) 'level': level,
      };
      final response = await _dio.get(Config.kScenarios, queryParameters: query);
      final List<dynamic> data = response.data['scenarios'] ?? [];
      return data.map((e) => ScenarioModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<ScenarioModel> getScenarioDetail(String id) async {
    try {
      final response = await _dio.get('${Config.kScenarios}/$id');
      return ScenarioModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ========== Practice APIs ==========
  
  Future<PracticeSession> startPractice(String scenarioId) async {
    try {
      final response = await _dio.post(Config.kPracticeStart, data: {
        'scenario_id': scenarioId,
      });
      return PracticeSession.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<PracticeResult> submitPractice({
    required String sessionId,
    required List<String> audioUrls,
  }) async {
    try {
      final response = await _dio.post(Config.kPracticeSubmit, data: {
        'session_id': sessionId,
        'audio_urls': audioUrls,
      });
      return PracticeResult.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ========== Subscription APIs ==========
  
  Future<SubscriptionModel> getSubscription() async {
    try {
      final response = await _dio.get(Config.kUserSubscription);
      return SubscriptionModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ========== Error Handling ==========
  
  dynamic _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      final message = response?.data?['error'] ?? error.message ?? '未知錯誤';
      throw ApiException(
        code: response?.statusCode ?? 0,
        message: message,
      );
    }
    throw ApiException(message: error.toString());
  }
}

// ========== Response Models ==========

class LoginResponse {
  final String accessToken;
  final UserModel user;
  
  LoginResponse({required this.accessToken, required this.user});
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class ApiException implements Exception {
  final int code;
  final String message;
  
  ApiException({required this.code, required this.message});
  
  @override
  String toString() => 'ApiException($code): $message';
}

// ========== Data Models ==========

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final String subscriptionPlan;
  final bool subscriptionActive;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.subscriptionPlan,
    required this.subscriptionActive,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xp_to_next_level'] ?? 1000,
      subscriptionPlan: json['subscription_plan'] ?? 'free',
      subscriptionActive: json['subscription_active'] ?? false,
    );
  }
}

class ScenarioModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final String imageUrl;
  final int dialogueCount;
  final int practiceCount;
  final bool isPublished;
  
  ScenarioModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.imageUrl,
    required this.dialogueCount,
    required this.practiceCount,
    required this.isPublished,
  });
  
  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    return ScenarioModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'] ?? 'daily',
      level: json['level'] ?? 'beginner',
      imageUrl: json['image_url'] ?? '',
      dialogueCount: json['dialogue_count'] ?? 0,
      practiceCount: json['practice_count'] ?? 0,
      isPublished: json['status'] == 'published',
    );
  }
}

class PracticeSession {
  final String id;
  final String scenarioId;
  final List<DialogueLine> dialogues;
  final DateTime expiresAt;
  
  PracticeSession({
    required this.id,
    required this.scenarioId,
    required this.dialogues,
    required this.expiresAt,
  });
  
  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    final dialogues = (json['dialogues'] as List<dynamic>?)
        ?.map((e) => DialogueLine.fromJson(e))
        .toList() ?? [];
    
    return PracticeSession(
      id: json['id'],
      scenarioId: json['scenario_id'],
      dialogues: dialogues,
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now().add(const Duration(hours: 1)),
    );
  }
}

class DialogueLine {
  final String id;
  final String speaker;
  final String text;
  final String? audioUrl;
  
  DialogueLine({
    required this.id,
    required this.speaker,
    required this.text,
    this.audioUrl,
  });
  
  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      id: json['id'],
      speaker: json['speaker'],
      text: json['text'],
      audioUrl: json['audio_url'],
    );
  }
}

class PracticeResult {
  final int pronunciationScore;
  final int grammarScore;
  final int vocabularyScore;
  final int fluencyScore;
  final int totalScore;
  final String feedback;
  final List<String> suggestions;
  
  PracticeResult({
    required this.pronunciationScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.fluencyScore,
    required this.totalScore,
    required this.feedback,
    required this.suggestions,
  });
  
  factory PracticeResult.fromJson(Map<String, dynamic> json) {
    final suggestions = (json['suggestions'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    
    return PracticeResult(
      pronunciationScore: json['pronunciation_score'] ?? 0,
      grammarScore: json['grammar_score'] ?? 0,
      vocabularyScore: json['vocabulary_score'] ?? 0,
      fluencyScore: json['fluency_score'] ?? 0,
      totalScore: json['total_score'] ?? 0,
      feedback: json['feedback'] ?? '',
      suggestions: suggestions,
    );
  }
}

class SubscriptionModel {
  final String plan;
  final bool isActive;
  final DateTime? startAt;
  final DateTime? endAt;
  
  SubscriptionModel({
    required this.plan,
    required this.isActive,
    this.startAt,
    this.endAt,
  });
  
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'] ?? 'free',
      isActive: json['active'] ?? false,
      startAt: json['start_at'] != null ? DateTime.tryParse(json['start_at']) : null,
      endAt: json['end_at'] != null ? DateTime.tryParse(json['end_at']) : null,
    );
  }
}

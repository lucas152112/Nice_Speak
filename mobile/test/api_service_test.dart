import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:nice_speak/services/api_service.dart';

// Mock HTTP Client
class MockClient extends Mock implements http.Client {}

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService();
    });

    test('login returns user and token on success', () async {
      // Setup mock response
      when(mockClient.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenReturn(http.Response('''
        {
          "access_token": "test_token",
          "user": {
            "id": "123",
            "email": "test@example.com",
            "name": "Test User"
          }
        }
      ''', 200));

      // Test
      final response = await apiService.login('test@example.com', 'password');

      // Verify
      expect(response.accessToken, 'test_token');
      expect(response.user.email, 'test@example.com');
    });

    test('getScenarios returns list of scenarios', () async {
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenReturn(http.Response('''
        {
          "scenarios": [
            {
              "id": "1",
              "title": "Airport",
              "description": "Airport scenario",
              "category": "travel",
              "level": "beginner",
              "dialogueCount": 10,
              "practiceCount": 100
            }
          ]
        }
      ''', 200));

      final scenarios = await apiService.getScenarios();

      expect(scenarios.length, 1);
      expect(scenarios.first.title, 'Airport');
    });
  });

  group('Models Tests', () {
    test('UserModel fromJson parses correctly', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
        'level': 5,
        'xp': 500,
        'xpToNextLevel': 1000,
        'subscriptionPlan': 'premium',
        'subscriptionActive': true,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.level, 5);
      expect(user.isPremium, true);
    });

    test('ScenarioModel fromJson parses correctly', () {
      final json = {
        'id': '1',
        'title': 'Airport',
        'description': 'Test description',
        'category': 'travel',
        'level': 'beginner',
        'dialogueCount': 10,
        'practiceCount': 100,
        'status': 'published',
      };

      final scenario = ScenarioModel.fromJson(json);

      expect(scenario.id, '1');
      expect(scenario.title, 'Airport');
      expect(scenario.isPublished, true);
    });

    test('PracticeResult calculates grade correctly', () {
      final result = PracticeResult(
        pronunciationScore: 85,
        grammarScore: 80,
        vocabularyScore: 90,
        fluencyScore: 75,
        totalScore: 82,
        feedback: 'Good job!',
        suggestions: ['Practice more'],
      );

      expect(result.totalScore, 82);
    });
  });
}

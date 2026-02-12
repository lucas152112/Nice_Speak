import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:nice_speak/providers/auth_provider.dart';
import 'package:nice_speak/providers/scenarios_provider.dart';
import 'package:nice_speak/providers/practice_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('initial state is unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.user, null);
    });

    test('level progression calculations', () {
      expect(authProvider.level, 1);
      expect(authProvider.xp, 0);
      expect(authProvider.levelProgress, 0.0);
    });
  });

  group('ScenariosProvider Tests', () {
    late ScenariosProvider provider;

    setUp(() {
      provider = ScenariosProvider();
    });

    test('initial state', () {
      expect(provider.scenarios, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.hasMore, true);
    });

    test('category names are translated', () {
      expect(provider.getCategoryName('daily'), '日常生活');
      expect(provider.getCategoryName('travel'), '旅遊');
      expect(provider.getCategoryName('business'), '商務');
      expect(provider.getCategoryName('education'), '教育');
    });

    test('level names are translated', () {
      expect(provider.getLevelName('beginner'), '入門');
      expect(provider.getLevelName('intermediate'), '中級');
      expect(provider.getLevelName('advanced'), '進階');
    });

    test('clearFilters resets all filters', () {
      provider.setCategory('travel');
      provider.setLevel('advanced');
      provider.setSearchKeyword('test');

      provider.clearFilters();

      expect(provider.scenarios, isEmpty);
    });
  });

  group('PracticeProvider Tests', () {
    late PracticeProvider provider;

    setUp(() {
      provider = PracticeProvider();
    });

    test('initial state', () {
      expect(provider.session, null);
      expect(provider.result, null);
      expect(provider.isRecording, false);
      expect(provider.isProcessing, false);
      expect(provider.currentDialogueIndex, 0);
    });

    test('progress calculation', () {
      expect(provider.progress, 0.0);
    });

    test('canNext returns false when no audio recorded', () {
      expect(provider.canNext, false);
    });

    test('isLastDialogue returns false when no session', () {
      expect(provider.isLastDialogue, false);
    });

    test('score grading', () {
      expect(provider.getScoreGrade(95), 'S');
      expect(provider.getScoreGrade(85), 'A');
      expect(provider.getScoreGrade(75), 'B');
      expect(provider.getScoreGrade(65), 'C');
      expect(provider.getScoreGrade(55), 'D');
    });

    test('reset clears all state', () {
      provider.reset();
      
      expect(provider.session, null);
      expect(provider.result, null);
      expect(provider.isRecording, false);
      expect(provider.isProcessing, false);
      expect(provider.currentDialogueIndex, 0);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'services/api_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/scenarios/scenarios_screen.dart';
import 'screens/scenarios/scenario_detail_screen.dart';
import 'screens/practice/practice_screen.dart';
import 'screens/practice/practice_result_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/subscription/subscription_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化配置
  await Config.init();
  
  // 設定系統 UI 樣式
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  // 設定螢幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const NiceSpeakApp());
}

class NiceSpeakApp extends StatelessWidget {
  const NiceSpeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..init(),
        ),
        // Scenarios Provider
        ChangeNotifierProvider(
          create: (_) => ScenariosProvider(),
        ),
        // Practice Provider
        ChangeNotifierProvider(
          create: (_) => PracticeProvider(),
        ),
        // Subscription Provider
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Nice Speak',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        
        // 國際化
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'TW'),
          Locale('en', 'US'),
        ],
        locale: const Locale('zh', 'TW'),
        
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            // Splash
            GoRoute(
              path: '/',
              builder: (_, __) => const SplashScreen(),
            ),
            // Login
            GoRoute(
              path: '/login',
              builder: (_, __) => const LoginScreen(),
            ),
            // Home
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
            // Scenarios List
            GoRoute(
              path: '/scenarios',
              builder: (_, __) => const ScenariosScreen(),
            ),
            // Scenario Detail
            GoRoute(
              path: '/scenarios/:id',
              builder: (_, state) => ScenarioDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
            // Practice
            GoRoute(
              path: '/practice/:id',
              builder: (_, state) => PracticeScreen(
                scenarioId: state.pathParameters['id']!,
              ),
            ),
            // Practice Result
            GoRoute(
              path: '/practice/:id/result',
              builder: (_, state) => PracticeResultScreen(
                scenarioId: state.pathParameters['id']!,
              ),
            ),
            // Profile
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
            // Subscription
            GoRoute(
              path: '/subscription',
              builder: (_, __) => const SubscriptionScreen(),
            ),
          ],
          
          // 全局錯誤處理
          errorPageBuilder: (context, state) => MaterialPage(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('頁面錯誤', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(state.error?.toString() ?? '未知錯誤'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('返回首頁'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

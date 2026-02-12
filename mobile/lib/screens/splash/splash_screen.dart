import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 初始化 Auth
    await context.read<AuthProvider>().init();
    
    final auth = context.read<AuthProvider>();
    
    // 延遲顯示 Logo 動畫
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // 根據登入狀態跳轉
    if (mounted) {
      if (auth.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF03A9F4),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.record_voice_over,
                  size: 64,
                  color: Color(0xFF4CAF50),
                ),
              ).animate()
                  .scale(duration: const Duration(milliseconds: 500))
                  .then()
                  .shimmer(duration: const Duration(milliseconds: 1000)),
              
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'Nice Speak',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 300))
                  .slideY(begin: 0.3),
              
              const SizedBox(height: 8),
              
              // Tagline
              const Text(
                'AI 英語會話練習',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 500))
                  .slideY(begin: 0.3),
              
              const SizedBox(height: 60),
              
              // Loading Indicator
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 800))
                  .then()
                  .loop(),
            ],
          ),
        ),
      ),
    );
  }
}

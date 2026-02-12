import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, auth),
              
              const SizedBox(height: 24),
              
              // Level Card
              _buildLevelCard(auth),
              
              const SizedBox(height: 16),
              
              // Subscription Card
              _buildSubscriptionCard(context, auth),
              
              const SizedBox(height: 16),
              
              // Statistics
              _buildStatisticsCard(),
              
              const SizedBox(height: 16),
              
              // Menu Items
              _buildMenuItems(context),
              
              const SizedBox(height: 24),
              
              // Logout Button
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider auth) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF03A9F4)],
            ),
          ),
          child: Center(
            child: Text(
              (auth.user?.name ?? 'U').substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Name
        Text(
          auth.user?.name ?? '用戶',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Email
        Text(
          auth.user?.email ?? '',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        
        const SizedBox(height: 8),
        
        // Edit Profile Button
        TextButton(
          onPressed: () {},
          child: const Text('編輯個人資料'),
        ),
      ],
    );
  }

  Widget _buildLevelCard(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.stars, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    '等級',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Text(
                'Lv.${auth.level}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: auth.levelProgress,
              minHeight: 10,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${auth.xp} XP',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                '${auth.xpToNextLevel} XP 升級',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: auth.isPremium ? Colors.purple[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: auth.isPremium ? Colors.purple[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: auth.isPremium ? Colors.purple : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              auth.isPremium ? Icons.workspace_premium : Icons.lock_open,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.isPremium ? '進階版會員' : '免費版',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.isPremium 
                      ? '可使用全部功能' 
                      : '升級解鎖更多情境',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (!auth.isPremium)
            ElevatedButton(
              onPressed: () => context.go('/subscription'),
              child: const Text('升級'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '練習統計',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('45', '總練習'),
              _buildStatItem('7', '連續天數'),
              _buildStatItem('82', '平均分數'),
              _buildStatItem('12', '本月'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      ('我的收藏', Icons.favorite_outline, '/favorites'),
      ('練習歷史', Icons.history, '/history'),
      ('學習記錄', Icons.auto_graph, '/stats'),
      ('設定', Icons.settings, '/settings'),
      ('幫助中心', Icons.help_outline, '/help'),
      ('關於我們', Icons.info_outline, '/about'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.$2, color: Colors.grey[600]),
                title: Text(item.$1),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => context.go(item.$3),
              ),
              if (index < menuItems.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Text(
          '登出',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('登出'),
          ),
        ],
      ),
    );

    if (result == true) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }
}

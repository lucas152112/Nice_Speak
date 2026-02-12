import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final plans = [
      {
        'id': 'free',
        'name': '免費版',
        'price': '免費',
        'color': Colors.grey,
        'features': [
          '每日 3 次練習',
          '5 個情境模板',
          '基礎發音評估',
          'Email 支援',
        ],
        'highlight': false,
      },
      {
        'id': 'premium',
        'name': '進階版',
        'price': 'NT\$599/月',
        'color': Colors.purple,
        'features': [
          '無限練習次數',
          '全部情境模板',
          'AI 對話練習',
          '專屬客服',
          '優先新功能',
        ],
        'highlight': true,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          '升級方案',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '解鎖全部功能',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '選擇適合您的方案',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Plans
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isCurrentPlan = auth.subscriptionPlan == plan['id'];
                  
                  return _buildPlanCard(
                    context,
                    plan: plan,
                    isCurrentPlan: isCurrentPlan,
                    auth: auth,
                  );
                },
              ),
            ),

            // Trial Info
            if (auth.subscriptionPlan == 'free')
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          '新用戶首月 5 折優惠',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text(
                          '7 天免費試用',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required Map plan,
    required bool isCurrentPlan,
    required AuthProvider auth,
  }) {
    final isHighlight = plan['highlight'] as bool;
    final color = plan['color'] as Color;
    final features = plan['features'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isHighlight
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              )
            : null,
        color: isHighlight ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isHighlight
            ? null
            : Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: (isHighlight ? color : Colors.black).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Highlight Badge
          if (isHighlight)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                '最受歡迎',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Name
                Text(
                  plan['name'] as String,
                  style: TextStyle(
                    fontSize: isHighlight ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? Colors.white : Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Text(
                  plan['price'] as String,
                  style: TextStyle(
                    fontSize: isHighlight ? 36 : 28,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? Colors.white : color,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '/月',
                  style: TextStyle(
                    fontSize: 14,
                    color: isHighlight ? Colors.white70 : Colors.grey[500]),
                ),
                
                const SizedBox(height: 24),
                
                // Features
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isHighlight
                                  ? Colors.white.withOpacity(0.2)
                                  : color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: isHighlight ? Colors.white : color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 16,
                                color: isHighlight ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: isCurrentPlan
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '目前方案',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isHighlight
                                ? Colors.white
                                : color,
                            foregroundColor: isHighlight
                                ? color
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            auth.subscriptionPlan == 'free' ? '立即升級' : '選擇方案',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

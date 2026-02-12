import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/scenarios_provider.dart';

class ScenarioDetailScreen extends StatelessWidget {
  final String id;
  
  const ScenarioDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ScenarioModel>(
        future: context.read<ScenariosProvider>().fetchScenarioDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('載入失敗: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/scenarios'),
                      child: const Text('返回'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final scenario = snapshot.data!;
          final provider = context.read<ScenariosProvider>();
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor(scenario.category),
                          _getCategoryColor(scenario.category).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(scenario.category),
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {}, // TODO: Share
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Level
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              scenario.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildLevelBadge(scenario.level),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stats
                      Row(
                        children: [
                          _buildStatItem(
                            Icons.translate,
                            '${scenario.dialogueCount}',
                            '對話數',
                          ),
                          const SizedBox(width: 24),
                          _buildStatItem(
                            Icons.play_circle,
                            '${scenario.practiceCount}',
                            '練習次數',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      const Text(
                        '情境介紹',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scenario.description.isEmpty 
                            ? '這個情境可以幫助您練習日常對話。'
                            : scenario.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Start Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.go('/practice/$id'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: const Text(
                            '開始練習',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Practice Tips
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                                const SizedBox(width: 8),
                                Text(
                                  '練習提示',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('• 建議選擇安靜的環境進行錄音'),
                            const Text('• 發音時請靠近麥克風'),
                            const Text('• 可以重複練習直到滿意為止'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(String level) {
    final colors = {
      'beginner': Colors.green,
      'intermediate': Colors.orange,
      'advanced': Colors.red,
    };
    final labels = {
      'beginner': '入門',
      'intermediate': '中級',
      'advanced': '進階',
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors[level]?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[level] ?? level,
        style: TextStyle(
          fontSize: 14,
          color: colors[level] ?? Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'daily': Icons.home,
      'travel': Icons.flight,
      'business': Icons.work,
      'education': Icons.school,
    };
    return icons[category] ?? Icons.category;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'daily': Colors.green,
      'travel': Colors.blue,
      'business': Colors.purple,
      'education': Colors.orange,
    };
    return colors[category] ?? Colors.grey;
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScenarioCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final String imageUrl;
  final int dialogueCount;
  final int practiceCount;
  final VoidCallback onTap;

  const ScenarioCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.imageUrl,
    required this.dialogueCount,
    required this.practiceCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(category);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (c, url) => Center(
                            child: CircularProgressIndicator(
                              color: categoryColor,
                            ),
                          ),
                          errorWidget: (c, url, error) => _buildCategoryIcon(categoryColor),
                        ),
                      )
                    : _buildCategoryIcon(categoryColor),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildLevelBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.translate,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$dialogueCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.play_circle_outline,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$practiceCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(Color color) {
    return Center(
      child: Icon(
        _getCategoryIcon(category),
        size: 40,
        color: color.withOpacity(0.5),
      ),
    );
  }

  Widget _buildLevelBadge() {
    final levelData = _getLevelData(level);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: levelData['color']?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        levelData['label'] as String,
        style: TextStyle(
          fontSize: 10,
          color: levelData['color'] ?? Colors.grey,
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
      'food': Icons.restaurant,
      'health': Icons.favorite,
      'shopping': Icons.shopping_bag,
      'social': Icons.people,
    };
    return icons[category] ?? Icons.category;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'daily': Colors.green,
      'travel': Colors.blue,
      'business': Colors.purple,
      'education': Colors.orange,
      'food': Colors.red,
      'health': Colors.pink,
      'shopping': Colors.teal,
      'social': Colors.indigo,
    };
    return colors[category] ?? Colors.grey;
  }

  Map<String, dynamic> _getLevelData(String level) {
    final levels = {
      'beginner': {'label': '入門', 'color': Colors.green},
      'intermediate': {'label': '中級', 'color': Colors.orange},
      'advanced': {'label': '進階', 'color': Colors.red},
    };
    return levels[level] ?? {'label': level, 'color': Colors.grey};
  }
}

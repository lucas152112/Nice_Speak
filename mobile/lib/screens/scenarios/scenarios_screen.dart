import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/scenarios_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScenariosScreen extends StatefulWidget {
  const ScenariosScreen({super.key});

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScenariosProvider>().fetchScenarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScenariosProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            
            // Filters
            _buildFilters(provider),
            
            // Content
            Expanded(
              child: provider.isLoading && provider.scenarios.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.scenarios.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('沒有找到情境'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.clearFilters();
                                },
                                child: const Text('清除篩選'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => provider.fetchScenarios(refresh: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.scenarios.length,
                            itemBuilder: (context, index) {
                              final scenario = provider.scenarios[index];
                              return _buildScenarioCard(context, scenario);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final provider = context.read<ScenariosProvider>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜尋情境...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchKeyword('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: provider.setSearchKeyword,
        onSubmitted: (_) => provider.fetchScenarios(refresh: true),
      ),
    );
  }

  Widget _buildFilters(ScenariosProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category Filter
          PopupMenuButton<String>(
            initialValue: provider._selectedCategory,
            onSelected: provider.setCategory,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('全部分類')),
              ...provider.categories.map((c) => PopupMenuItem(
                value: c,
                child: Text(provider.getCategoryName(c)),
              )),
            ],
            child: _buildFilterChip(
              provider._selectedCategory == null
                  ? '全部分類'
                  : provider.getCategoryName(provider._selectedCategory!),
              provider._selectedCategory != null,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Level Filter
          PopupMenuButton<String>(
            initialValue: provider._selectedLevel,
            onSelected: provider.setLevel,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('全部難度')),
              ...provider.levels.map((l) => PopupMenuItem(
                value: l,
                child: Text(provider.getLevelName(l)),
              )),
            ],
            child: _buildFilterChip(
              provider._selectedLevel == null
                  ? '全部難度'
                  : provider.getLevelName(provider._selectedLevel!),
              provider._selectedLevel != null,
            ),
          ),
          
          if (provider._selectedCategory != null || provider._selectedLevel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                provider.clearFilters();
                _searchController.clear();
              },
              child: const Text('清除'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, ScenarioModel scenario) {
    final provider = context.read<ScenariosProvider>();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/scenarios/${scenario.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or Placeholder
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: provider._selectedCategory != null
                    ? _getCategoryColor(provider._selectedCategory!).withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: scenario.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: scenario.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (c, url, error) => _buildCategoryIcon(provider._selectedCategory ?? scenario.category),
                    )
                  : _buildCategoryIcon(scenario.category),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          scenario.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildLevelBadge(scenario.level),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scenario.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.translate, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${scenario.dialogueCount} 段對話',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.play_circle_outline, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${scenario.practiceCount} 人練習',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    return Center(
      child: Icon(
        _getCategoryIcon(category),
        size: 64,
        color: _getCategoryColor(category).withOpacity(0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[level]?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[level] ?? level,
        style: TextStyle(
          fontSize: 12,
          color: colors[level] ?? Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

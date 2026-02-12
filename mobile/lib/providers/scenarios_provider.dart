import 'package:flutter/foundation.dart';
import 'services/api_service.dart';

class ScenariosProvider with ChangeNotifier {
  List<ScenarioModel> _scenarios = [];
  List<ScenarioModel> _filteredScenarios = [];
  ScenarioModel? _selectedScenario;
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  
  // 篩選條件
  String? _selectedCategory;
  String? _selectedLevel;
  String _searchKeyword = '';
  
  List<ScenarioModel> get scenarios => _filteredScenarios.isEmpty && _searchKeyword.isEmpty 
      ? _scenarios 
      : _filteredScenarios;
  
  ScenarioModel? get selectedScenario => _selectedScenario;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  
  // 可用的篩選選項
  List<String> get categories => ['daily', 'travel', 'business', 'education'];
  List<String> get levels => ['beginner', 'intermediate', 'advanced'];
  
  String getCategoryName(String category) {
    final names = {
      'daily': '日常生活',
      'travel': '旅遊',
      'business': '商務',
      'education': '教育',
    };
    return names[category] ?? category;
  }
  
  String getLevelName(String level) {
    final names = {
      'beginner': '入門',
      'intermediate': '中級',
      'advanced': '進階',
    };
    return names[level] ?? level;
  }
  
  Future<void> fetchScenarios({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _scenarios = [];
      _filteredScenarios = [];
      _hasMore = true;
    }
    
    if (!_hasMore || _isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final list = await ApiService().getScenarios(
        page: _page,
        limit: 20,
        category: _selectedCategory,
        level: _selectedLevel,
      );
      
      if (list.isEmpty) {
        _hasMore = false;
      } else {
        _scenarios.addAll(list);
        _applyFilters();
        _page++;
      }
    } catch (e) {
      // 錯誤處理
      debugPrint('fetchScenarios error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<ScenarioModel> fetchScenarioDetail(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _selectedScenario = await ApiService().getScenarioDetail(id);
      return _selectedScenario!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void setCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }
  
  void setLevel(String? level) {
    _selectedLevel = level;
    _applyFilters();
    notifyListeners();
  }
  
  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    _applyFilters();
    notifyListeners();
  }
  
  void clearFilters() {
    _selectedCategory = null;
    _selectedLevel = null;
    _searchKeyword = '';
    _filteredScenarios = [];
    notifyListeners();
  }
  
  void _applyFilters() {
    List<ScenarioModel> result = List.from(_scenarios);
    
    // 搜尋關鍵字
    if (_searchKeyword.isNotEmpty) {
      final keyword = _searchKeyword.toLowerCase();
      result = result.where((s) => 
        s.title.toLowerCase().contains(keyword) ||
        s.description.toLowerCase().contains(keyword)
      ).toList();
    }
    
    // 分類篩選
    if (_selectedCategory != null) {
      result = result.where((s) => s.category == _selectedCategory).toList();
    }
    
    // 等級篩選
    if (_selectedLevel != null) {
      result = result.where((s) => s.level == _selectedLevel).toList();
    }
    
    _filteredScenarios = result;
  }
}

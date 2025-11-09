import 'package:flutter/foundation.dart';
import '../models/password_entry.dart';
import '../services/database_service.dart';
import '../services/secure_storage_service.dart';

class PasswordController with ChangeNotifier {
  List<PasswordEntry> _passwordEntries = [];
  List<PasswordEntry> _filteredEntries = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<PasswordEntry> get passwordEntries => _passwordEntries;
  List<PasswordEntry> get filteredEntries => _filteredEntries;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // 初始化
  Future<void> loadPasswordEntries() async {
    _setLoading(true);
    try {
      _passwordEntries = await DatabaseService.getAllPasswordEntries();
      _filteredEntries = List.from(_passwordEntries);
      notifyListeners();
    } catch (e) {
      debugPrint('加载密码条目失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 搜索
  Future<void> searchEntries(String query) async {
    _searchQuery = query;
    _setLoading(true);

    try {
      if (query.isEmpty) {
        _filteredEntries = List.from(_passwordEntries);
      } else {
        _filteredEntries = await DatabaseService.searchPasswordEntries(query);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('搜索失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 添加密码条目
  Future<void> addPasswordEntry(PasswordEntry entry) async {
    try {
      await DatabaseService.insertPasswordEntry(entry);
      await loadPasswordEntries(); // 重新加载所有数据
      notifyListeners();
    } catch (e) {
      debugPrint('添加密码条目失败: $e');
      rethrow;
    }
  }

  // 更新密码条目
  Future<void> updatePasswordEntry(PasswordEntry entry) async {
    try {
      await DatabaseService.updatePasswordEntry(entry);
      await loadPasswordEntries(); // 重新加载所有数据
      notifyListeners();
    } catch (e) {
      debugPrint('更新密码条目失败: $e');
      rethrow;
    }
  }

  // 删除密码条目
  Future<void> deletePasswordEntry(String id) async {
    try {
      await DatabaseService.deletePasswordEntry(id);
      await loadPasswordEntries(); // 重新加载所有数据
      notifyListeners();
    } catch (e) {
      debugPrint('删除密码条目失败: $e');
      rethrow;
    }
  }

  // 批量导入
  Future<void> importEntries(List<PasswordEntry> entries) async {
    _setLoading(true);
    try {
      await DatabaseService.importPasswordEntries(entries);
      await loadPasswordEntries(); // 重新加载所有数据
      notifyListeners();
    } catch (e) {
      debugPrint('导入密码条目失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 导出所有数据
  Future<Map<String, dynamic>> exportAllEntries() async {
    try {
      final entries = await DatabaseService.getAllPasswordEntries();
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'entries': entries.map((e) => e.toJson()).toList(),
      };
      return exportData;
    } catch (e) {
      debugPrint('导出数据失败: $e');
      rethrow;
    }
  }

  // 获取条目数量
  int get totalEntries => _passwordEntries.length;
  int get filteredEntriesCount => _filteredEntries.length;

  // 清除搜索
  void clearSearch() {
    _searchQuery = '';
    _filteredEntries = List.from(_passwordEntries);
    notifyListeners();
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 根据ID获取条目
  PasswordEntry? getEntryById(String id) {
    try {
      return _passwordEntries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  // 获取所有标签
  List<String> getAllTags() {
    final tags = <String>{};
    for (final entry in _passwordEntries) {
      tags.addAll(entry.tags);
    }
    return tags.toList()..sort();
  }

  // 按标签过滤
  void filterByTag(String tag) {
    if (tag.isEmpty) {
      _filteredEntries = List.from(_passwordEntries);
    } else {
      _filteredEntries = _passwordEntries.where((entry) => entry.tags.contains(tag)).toList();
    }
    notifyListeners();
  }

  // 获取最近使用的条目
  List<PasswordEntry> getRecentEntries({int limit = 5}) {
    final sortedEntries = List<PasswordEntry>.from(_passwordEntries)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedEntries.take(limit).toList();
  }

  // 检查是否有重复的标题
  bool hasDuplicateTitle(String title, {String? excludeId}) {
    return _passwordEntries.any((entry) =>
      entry.title.toLowerCase() == title.toLowerCase() &&
      (excludeId == null || entry.id != excludeId)
    );
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadPasswordEntries();
  }
}
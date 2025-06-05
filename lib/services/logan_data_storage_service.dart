import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/logan_log_item.dart';

/// Logan日志数据持久化存储服务
class LoganDataStorageService {
  static const String _originalLogDataKey = 'original_log_data';
  static const String _searchKeywordKey = 'search_keyword';
  static const String _filterTypeKey = 'filter_type';
  static const String _selectedMenuItemKey = 'selected_menu_item';
  static const String _lastParseFilePathKey = 'last_parse_file_path';

  /// 保存原始日志数据
  Future<void> saveOriginalLogData(List<LoganLogItem> logData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = logData.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_originalLogDataKey, jsonString);
      print('成功保存 ${logData.length} 条日志数据');
    } catch (e) {
      print('保存日志数据失败: $e');
    }
  }

  /// 读取原始日志数据
  Future<List<LoganLogItem>> loadOriginalLogData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_originalLogDataKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      final logData =
          jsonList
              .map(
                (json) => LoganLogItem.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      print('成功加载 ${logData.length} 条日志数据');
      return logData;
    } catch (e) {
      print('加载日志数据失败: $e');
      return [];
    }
  }

  /// 保存搜索关键词
  Future<void> saveSearchKeyword(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_searchKeywordKey, keyword);
    } catch (e) {
      print('保存搜索关键词失败: $e');
    }
  }

  /// 读取搜索关键词
  Future<String> loadSearchKeyword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_searchKeywordKey) ?? '';
    } catch (e) {
      print('读取搜索关键词失败: $e');
      return '';
    }
  }

  /// 保存筛选类型
  Future<void> saveFilterType(String filterType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_filterTypeKey, filterType);
    } catch (e) {
      print('保存筛选类型失败: $e');
    }
  }

  /// 读取筛选类型
  Future<String> loadFilterType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_filterTypeKey) ?? '';
    } catch (e) {
      print('读取筛选类型失败: $e');
      return '';
    }
  }

  /// 保存选中的菜单项
  Future<void> saveSelectedMenuItem(String menuItem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedMenuItemKey, menuItem);
    } catch (e) {
      print('保存选中菜单项失败: $e');
    }
  }

  /// 读取选中的菜单项
  Future<String> loadSelectedMenuItem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedMenuItemKey) ?? '0';
    } catch (e) {
      print('读取选中菜单项失败: $e');
      return '0';
    }
  }

  /// 保存最后解析的文件路径
  Future<void> saveLastParseFilePath(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastParseFilePathKey, filePath);
    } catch (e) {
      print('保存文件路径失败: $e');
    }
  }

  /// 读取最后解析的文件路径
  Future<String?> loadLastParseFilePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastParseFilePathKey);
    } catch (e) {
      print('读取文件路径失败: $e');
      return null;
    }
  }

  /// 清除所有保存的数据
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_originalLogDataKey);
      await prefs.remove(_searchKeywordKey);
      await prefs.remove(_filterTypeKey);
      await prefs.remove(_selectedMenuItemKey);
      await prefs.remove(_lastParseFilePathKey);
      print('已清除所有保存的数据');
    } catch (e) {
      print('清除数据失败: $e');
    }
  }

  /// 检查是否有保存的数据
  Future<bool> hasStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_originalLogDataKey);
      return jsonString != null && jsonString.isNotEmpty;
    } catch (e) {
      print('检查存储数据失败: $e');
      return false;
    }
  }
}

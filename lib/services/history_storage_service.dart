import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parse_history.dart';

/// 历史记录存储服务
class HistoryStorageService {
  static const String _historyKey = 'parse_history_records';
  static const int _maxHistoryCount = 100; // 最多保存100条历史记录

  /// 获取所有解析历史记录
  Future<List<ParseHistory>> getParseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      return historyJson
          .map((jsonStr) => ParseHistory.fromJson(json.decode(jsonStr)))
          .toList()
        ..sort((a, b) => b.parseTime.compareTo(a.parseTime)); // 按时间倒序排列
    } catch (e) {
      print('读取解析历史记录失败: $e');
      return [];
    }
  }

  /// 添加解析记录
  Future<void> addParseRecord(ParseHistory record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<ParseHistory> history = await getParseHistory();

      // 检查是否已存在相同文件路径的记录，如果存在则更新
      final existingIndex = history.indexWhere(
        (h) => h.filePath == record.filePath,
      );
      if (existingIndex != -1) {
        history[existingIndex] = record;
      } else {
        history.insert(0, record); // 插入到最前面
      }

      // 限制历史记录数量
      if (history.length > _maxHistoryCount) {
        history = history.take(_maxHistoryCount).toList();
      }

      // 转换为JSON字符串列表并保存
      final historyJson =
          history.map((record) => json.encode(record.toJson())).toList();

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      print('保存解析历史记录失败: $e');
    }
  }

  /// 删除指定的解析记录
  Future<void> removeParseRecord(String filePath) async {
    try {
      List<ParseHistory> history = await getParseHistory();
      history.removeWhere((record) => record.filePath == filePath);

      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          history.map((record) => json.encode(record.toJson())).toList();

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      print('删除解析历史记录失败: $e');
    }
  }

  /// 清空所有历史记录
  Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('清空历史记录失败: $e');
    }
  }

  /// 检查文件是否存在
  Future<bool> isFileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// 根据文件路径创建解析记录
  static Future<ParseHistory> createParseRecord({
    required String filePath,
    required int logCount,
    required bool isSuccess,
    String? errorMessage,
  }) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;
    final fileSize = await file.exists() ? await file.length() : 0;

    return ParseHistory(
      filePath: filePath,
      fileName: fileName,
      parseTime: DateTime.now(),
      fileSize: fileSize,
      logCount: logCount,
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }
}

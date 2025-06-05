import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parse_history.dart';
import '../services/history_storage_service.dart';

/// 历史记录存储服务 Provider
final historyStorageServiceProvider = Provider<HistoryStorageService>((ref) {
  return HistoryStorageService();
});

/// 解析历史记录列表 Provider
final parseHistoryListProvider =
    StateNotifierProvider<ParseHistoryNotifier, List<ParseHistory>>((ref) {
      final storageService = ref.watch(historyStorageServiceProvider);
      return ParseHistoryNotifier(storageService);
    });

/// 解析历史记录状态管理器
class ParseHistoryNotifier extends StateNotifier<List<ParseHistory>> {
  final HistoryStorageService _storageService;

  ParseHistoryNotifier(this._storageService) : super([]) {
    // 初始化时加载历史记录
    _loadHistory();
  }

  /// 加载历史记录
  Future<void> _loadHistory() async {
    try {
      final history = await _storageService.getParseHistory();
      state = history;
    } catch (e) {
      print('加载解析历史记录失败: $e');
      state = [];
    }
  }

  /// 重新加载历史记录
  Future<void> refreshHistory() async {
    await _loadHistory();
  }

  /// 添加解析记录
  Future<void> addRecord(ParseHistory record) async {
    try {
      await _storageService.addParseRecord(record);
      await _loadHistory(); // 重新加载以获取最新状态
    } catch (e) {
      print('添加解析记录失败: $e');
    }
  }

  /// 删除指定记录
  Future<void> removeRecord(String filePath) async {
    try {
      await _storageService.removeParseRecord(filePath);
      await _loadHistory(); // 重新加载以获取最新状态
    } catch (e) {
      print('删除解析记录失败: $e');
    }
  }

  /// 清空所有历史记录
  Future<void> clearAllHistory() async {
    try {
      await _storageService.clearAllHistory();
      state = [];
    } catch (e) {
      print('清空历史记录失败: $e');
    }
  }

  /// 检查文件是否存在
  Future<bool> isFileExists(String filePath) async {
    return await _storageService.isFileExists(filePath);
  }
}

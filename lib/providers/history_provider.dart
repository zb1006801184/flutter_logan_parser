import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parse_history.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


/// 解析历史记录列表 Provider
final parseHistoryListProvider =
    StateNotifierProvider<ParseHistoryNotifier, List<ParseHistory>>((ref) {
      return ParseHistoryNotifier();
    });

/// 解析历史记录状态管理器
class ParseHistoryNotifier extends StateNotifier<List<ParseHistory>> {
  ParseHistoryNotifier() : super([]) {
    // 初始化时加载历史记录
    _loadHistory();
  }

  /// 从本地 log 目录扫描文件加载历史记录
  Future<void> _loadHistory() async {
    try {
      // 获取应用文档目录
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${documentsDirectory.path}/log');

      // 检查 log 目录是否存在
      if (!await logDirectory.exists()) {
        print('log 目录不存在，创建空的历史记录列表');
        state = [];
        return;
      }

      // 扫描 log 目录下的所有文件
      final logFiles =
          await logDirectory
              .list()
              .where((entity) => entity is File)
              .cast<File>()
              .toList();

      // 为每个日志文件创建 ParseHistory 对象
      final List<ParseHistory> historyList = [];

      for (final file in logFiles) {
        try {
          // 获取文件信息
          final fileStat = await file.stat();
          final fileName = file.path.split('/').last;

          // 尝试从文件名解析原始文件名（去掉 _parsed_时间戳.json 后缀）
          String originalFileName = fileName;
          if (fileName.contains('_parsed_') && fileName.endsWith('.json')) {
            final parts = fileName.split('_parsed_');
            if (parts.length >= 2) {
              originalFileName = parts[0];
            }
          }

          // 创建历史记录对象
          final parseHistory = ParseHistory(
            filePath: file.path,
            fileName: originalFileName,
            parseTime: fileStat.modified, // 使用文件修改时间作为解析时间
            fileSize: fileStat.size,
            logCount: await _estimateLogCount(file), // 估算日志条数
            isSuccess: true, // 已存在的文件认为是解析成功的
            errorMessage: null,
          );

          historyList.add(parseHistory);
        } catch (e) {
          print('处理文件 ${file.path} 时出错: $e');
          // 继续处理其他文件
        }
      }

      // 按解析时间倒序排列
      historyList.sort((a, b) => b.parseTime.compareTo(a.parseTime));

      // 更新状态
      state = historyList;
      print('成功加载 ${historyList.length} 条历史记录');
    } catch (e) {
      print('加载历史记录失败: $e');
      // 加载失败时设置为空列表
      state = [];
    }
  }

  /// 估算 JSON 文件中的日志条数
  Future<int> _estimateLogCount(File file) async {
    try {
      // 如果是 JSON 文件，尝试解析并计算条数
      if (file.path.endsWith('.json')) {
        final content = await file.readAsString();
        // 简单估算：通过统计 "c": 字段的出现次数来估算日志条数
        final matches = RegExp(r'"c":\s*"').allMatches(content);
        return matches.length;
      }
      return 0;
    } catch (e) {
      print('估算日志条数失败: $e');
      return 0;
    }
  }

  /// 重新加载历史记录
  Future<void> refreshHistory() async {
    await _loadHistory();
  }

  /// 删除指定记录（删除对应的日志文件）
  Future<void> removeRecord(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('已删除日志文件: $filePath');
      }
      // 重新加载历史记录
      await _loadHistory();
    } catch (e) {
      print('删除日志文件失败: $e');
    }
  }

  /// 清空所有历史记录（删除整个 log 目录）
  Future<void> clearAllHistory() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${documentsDirectory.path}/log');

      if (await logDirectory.exists()) {
        await logDirectory.delete(recursive: true);
        print('已清空所有历史记录');
      }

      // 更新状态为空列表
      state = [];
    } catch (e) {
      print('清空历史记录失败: $e');
    }
  }

  /// 检查文件是否存在
  Future<bool> isFileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      print('检查文件是否存在失败: $e');
      return false;
    }
  }

  /// 添加解析记录
  Future<void> addRecord(ParseHistory record) async {
    state = [record, ...state];
    refreshHistory();
  }
}

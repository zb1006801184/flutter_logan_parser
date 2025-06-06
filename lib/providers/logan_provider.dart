import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_logan_parser/models/parse_history.dart';
import 'package:flutter_logan_parser/providers/history_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/logan_log_item.dart';
import '../models/app_state.dart';
import '../services/logan_parser_service.dart';

/// Logan 解析服务 Provider
final loganParserServiceProvider = Provider.autoDispose<LoganParserService>((
  ref,
) {
  return LoganParserService();
});


/// 应用 UI 状态 Provider
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppUIState>((
  ref,
) {
  final parserService = ref.watch(loganParserServiceProvider);
  return AppStateNotifier(parserService);
});

/// 原始日志数据 Provider
final originalLogDataProvider = StateProvider<List<LoganLogItem>>(
  (ref) => [],
);

/// 筛选后的日志数据 Provider
final filteredLogDataProvider = StateProvider<List<LoganLogItem>>(
  (ref) => [],
);

/// 选中的日志项 Provider
final selectedLogItemProvider = StateProvider<LoganLogItem?>(
  (ref) => null,
);

/// 搜索关键词 Provider
final searchKeywordProvider = StateProvider<String>((ref) => '');

/// 筛选类型 Provider
final filterTypeProvider = StateProvider<String>((ref) => '');

/// 侧边菜单选中项 Provider
final selectedMenuItemProvider = StateProvider<String>(
  (ref) => '0',
);

/// 应用状态管理器
class AppStateNotifier extends StateNotifier<AppUIState> {
  final LoganParserService _parserService;

  AppStateNotifier(this._parserService)
    : super(IdleState());

  /// 初始化应用数据（应用启动时调用）
  Future<void> initializeAppData(WidgetRef ref) async {
    state = IdleState();
  }


  /// 选择并解析日志文件
  Future<void> pickAndParseLogFile(
    WidgetRef ref, [
    BuildContext? context,
  ]) async {
    try {
      // 打开文件选择器
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        dialogTitle: '选择日志文件',
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          await _parseLogFile(File(filePath), ref, context);
        }
      }
    } catch (e) {
      print('选择文件失败: $e');
      state = LogDecodeFailState('选择文件失败: $e');
    }
  }

  /// 解析日志文件
  Future<void> _parseLogFile(
    File file,
    WidgetRef ref, [
    BuildContext? context,
  ]) async {
    try {
      state = LogDecodeLoadingState();

      // 解析日志文件
      List<LoganLogItem>? logItems;
      String? errorMessage;
      bool isSuccess = true;
      
      try {
        logItems = await _parserService.parseLogFile(file);
      } catch (e) {
        //解析失败
        state = LogDecodeFailState('解析失败: $e');
        isSuccess = false;
        errorMessage = e.toString();
        logItems = [];
      }

      if (logItems.isEmpty && isSuccess) {
        state = LogDecodeFailState('解析结果为空');
        return;
      }

      if (!isSuccess) {
        state = LogDecodeFailState('解析失败: $errorMessage');
        return;
      }

      // 更新原始数据
      ref.read(originalLogDataProvider.notifier).state = logItems;
      ref.read(filteredLogDataProvider.notifier).state = logItems;

      // 清空搜索和筛选条件
      ref.read(searchKeywordProvider.notifier).state = '';
      ref.read(filterTypeProvider.notifier).state = '';
      ref.read(selectedLogItemProvider.notifier).state = null;

      state = LogDecodeSuccessState(logItems);

      // 尝试生成 JSON 文件到应用文档目录
      try {
        // 获取应用文档目录，避免权限问题
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final outputDir = documentsDirectory.path;

        // 获取原文件名用于生成更有意义的JSON文件名
        final originalFileName = path.basename(file.path);

        final jsonFile = await _parserService.generateJsonFile(
          logItems,
          outputDir,
          originalFileName: originalFileName,
        );
        print('JSON 文件已生成到: ${jsonFile.path}');

        //更新解析历史列表
        ref
            .read(parseHistoryListProvider.notifier)
            .addRecord(
              ParseHistory(
                filePath: jsonFile.path,
                fileName: originalFileName,
                parseTime: DateTime.now(),
                fileSize: jsonFile.lengthSync(),
                logCount: logItems.length,
                isSuccess: true,
              ),
            );

      } catch (e) {
        print('生成 JSON 文件失败: $e');
        // 显示错误消息给用户
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('生成JSON文件失败: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      state = LogDecodeFailState('解析失败: $e');
    }
  }


  /// 搜索和筛选日志
  void searchAndFilter(WidgetRef ref, String searchKeyword, String filterType) {
    final originalData = ref.read(originalLogDataProvider);

    if (originalData.isEmpty) {
      return;
    }

    // 应用搜索和筛选条件
    final filteredData =
        originalData.where((item) {
          final matchesSearch = item.containsKeyword(searchKeyword);
          final matchesFilter = item.matchesFilter(filterType);
          return matchesSearch && matchesFilter;
        }).toList();

    // 更新筛选后的数据
    ref.read(filteredLogDataProvider.notifier).state = filteredData;
    ref.read(searchKeywordProvider.notifier).state = searchKeyword;
    ref.read(filterTypeProvider.notifier).state = filterType;


    // 更新状态
    if (filteredData.isEmpty &&
        (searchKeyword.isNotEmpty || filterType.isNotEmpty)) {
      state = LogSearchEmptyState('未找到匹配的日志');
    } else {
      state = LogDecodeSuccessState(filteredData);
    }
  }

  /// 选择日志项
  void selectLogItem(WidgetRef ref, LoganLogItem? item) {
    ref.read(selectedLogItemProvider.notifier).state = item;
  }

  /// 更新选中的菜单项
  void updateSelectedMenuItem(WidgetRef ref, String menuItem) {
    ref.read(selectedMenuItemProvider.notifier).state = menuItem;
  }

  /// 重置状态
  void reset(WidgetRef ref) {
    ref.read(originalLogDataProvider.notifier).state = [];
    ref.read(filteredLogDataProvider.notifier).state = [];
    ref.read(selectedLogItemProvider.notifier).state = null;
    ref.read(searchKeywordProvider.notifier).state = '';
    ref.read(filterTypeProvider.notifier).state = '';
    
    
    state = IdleState();
  }

  /// 解析指定的日志文件（公共方法，供历史记录页面使用）
  Future<void> parseSpecificFile(
    File file,
    WidgetRef ref, [
    BuildContext? context,
  ]) async {
    await _parseLogFile(file, ref, context);
  }

  //加载本地保存的 json 文件
  Future<void> loadLocalJsonFile(WidgetRef ref, String filePath) async {
    try {
      state = LogDecodeLoadingState();

      final jsonFile = File(filePath);

      // 检查文件是否存在
      if (!await jsonFile.exists()) {
        state = LogDecodeFailState('文件不存在: $filePath');
        return;
      }

      // 读取JSON文件内容
      final jsonString = await jsonFile.readAsString();

      if (jsonString.isEmpty) {
        state = LogDecodeFailState('文件内容为空');
        return;
      }

      // 解析JSON数据
      List<LoganLogItem> logItems;
      try {
        final jsonData = json.decode(jsonString);

        if (jsonData is List) {
          // 将JSON数组转换为LoganLogItem列表
          logItems =
              jsonData.map((item) {
                if (item is Map<String, dynamic>) {
                  return LoganLogItem.fromJson(item);
                } else {
                  throw FormatException('无效的日志项格式');
                }
              }).toList();
        } else {
          throw FormatException('JSON文件格式不正确，期望数组格式');
        }
      } catch (e) {
        state = LogDecodeFailState('解析JSON文件失败: $e');
        return;
      }

      if (logItems.isEmpty) {
        state = LogDecodeFailState('JSON文件中没有日志数据');
        return;
      }

      // 更新原始数据和筛选数据
      ref.read(originalLogDataProvider.notifier).state = logItems;
      ref.read(filteredLogDataProvider.notifier).state = logItems;

      // 清空搜索和筛选条件
      ref.read(searchKeywordProvider.notifier).state = '';
      ref.read(filterTypeProvider.notifier).state = '';
      ref.read(selectedLogItemProvider.notifier).state = null;

      // 更新状态为成功
      state = LogDecodeSuccessState(logItems);

      print('成功加载JSON文件: $filePath，共 ${logItems.length} 条日志');
    } catch (e) {
      print('加载JSON文件失败: $e');
      state = LogDecodeFailState('加载JSON文件失败: $e');
    }
  }
}

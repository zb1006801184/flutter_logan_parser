import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../providers/history_provider.dart';
import '../providers/logan_provider.dart';
import '../models/parse_history.dart';
import '../theme/app_theme.dart';
import 'widgets/parse_history_item.dart';

/// 解析历史记录页面
class ParseHistoryPage extends ConsumerWidget {
  const ParseHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyList = ref.watch(parseHistoryListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // 页面标题栏
          _buildTitleBar(context, ref, historyList),

          // 历史记录列表
          Expanded(
            child:
                historyList.isEmpty
                    ? _buildEmptyState(context)
                    : _buildHistoryList(context, ref, historyList),
          ),
        ],
      ),
    );
  }

  //页面标题栏
  Widget _buildTitleBar(
    BuildContext context,
    WidgetRef ref,
    List<ParseHistory> historyList,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 24, color: AppTheme.primaryColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '解析历史记录',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (historyList.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showClearConfirmDialog(context, ref),
              icon: const Icon(Icons.clear_all),
              label: const Text('清空历史'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: AppTheme.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            '暂无解析历史记录',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textHint),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '开始解析日志文件后，历史记录将显示在这里',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建历史记录列表
  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<ParseHistory> historyList,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final record = historyList[index];
        return ParseHistoryItem(
          record: record,
          onTap: () => _reopenFile(context, ref, record),
          onDelete: () => _deleteRecord(context, ref, record),
        );
      },
    );
  }

  

  

  /// 重新打开文件
  Future<void> _reopenFile(
    BuildContext context,
    WidgetRef ref,
    ParseHistory record,
  ) async {
    // 检查文件是否存在
    final file = File(record.filePath);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('文件不存在，无法重新解析')));
      }
      return;
    }

    // 切换到Logan解析页面
    ref.read(selectedMenuItemProvider.notifier).state = '0';

    // 开始解析文件
    await ref.read(appStateProvider.notifier).loadLocalJsonFile(ref, file.path);
  }

  /// 删除记录
  Future<void> _deleteRecord(
    BuildContext context,
    WidgetRef ref,
    ParseHistory record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除"${record.fileName}"的解析记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref
          .read(parseHistoryListProvider.notifier)
          .removeRecord(record.filePath);
    }
  }

  /// 显示清空确认对话框
  Future<void> _showClearConfirmDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认清空'),
            content: const Text('确定要清空所有解析历史记录吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('清空'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(parseHistoryListProvider.notifier).clearAllHistory();
    }
  }
}

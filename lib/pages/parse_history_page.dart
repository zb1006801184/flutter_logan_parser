import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../providers/history_provider.dart';
import '../providers/logan_provider.dart';
import '../models/parse_history.dart';
import '../theme/app_theme.dart';

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
          Container(
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
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
              ],
            ),
          ),

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
        return _buildHistoryItem(context, ref, record);
      },
    );
  }

  /// 构建历史记录项
  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    ParseHistory record,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _showRecordDetail(context, ref, record),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件名和状态
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.fileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          record.isSuccess
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color:
                            record.isSuccess
                                ? AppTheme.successColor.withOpacity(0.3)
                                : AppTheme.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      record.isSuccess ? '成功' : '失败',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            record.isSuccess
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // 解析信息
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    Icons.access_time,
                    record.parseTimeFormatted,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _buildInfoItem(
                    context,
                    Icons.storage,
                    record.fileSizeFormatted,
                  ),
                  if (record.isSuccess) ...[
                    const SizedBox(width: AppSpacing.lg),
                    _buildInfoItem(
                      context,
                      Icons.format_list_numbered,
                      '${record.logCount}条',
                    ),
                  ],
                ],
              ),

              // 文件路径
              const SizedBox(height: AppSpacing.sm),
              Text(
                record.filePath,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // 操作按钮
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _reopenFile(context, ref, record),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('重新解析'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () => _deleteRecord(context, ref, record),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('删除'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  /// 显示记录详情
  void _showRecordDetail(
    BuildContext context,
    WidgetRef ref,
    ParseHistory record,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('解析记录详情'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('文件名', record.fileName),
                _buildDetailRow('文件路径', record.filePath),
                _buildDetailRow('解析时间', record.parseTimeFormatted),
                _buildDetailRow('文件大小', record.fileSizeFormatted),
                _buildDetailRow('解析状态', record.isSuccess ? '成功' : '失败'),
                if (record.isSuccess)
                  _buildDetailRow('日志条数', '${record.logCount}条'),
                if (!record.isSuccess && record.errorMessage != null)
                  _buildDetailRow('错误信息', record.errorMessage!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  /// 重新解析文件
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
    final appStateNotifier = ref.read(appStateProvider.notifier);
    await appStateNotifier.parseSpecificFile(file, ref, context);
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

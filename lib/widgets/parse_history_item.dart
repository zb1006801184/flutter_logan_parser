import 'package:flutter/material.dart';
import 'dart:io';
import '../models/parse_history.dart';
import '../theme/app_theme.dart';

/// 解析历史记录项组件
class ParseHistoryItem extends StatelessWidget {
  final ParseHistory record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ParseHistoryItem({
    super.key,
    required this.record,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件名和状态
              _buildFileNameAndStatus(context),
              const SizedBox(height: AppSpacing.sm),

              // 解析信息
              _buildParseInfo(context),

              // 文件路径
              const SizedBox(height: AppSpacing.sm),
              _buildFilePath(context),

              // 操作按钮
              const SizedBox(height: AppSpacing.sm),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建文件名和状态
  Widget _buildFileNameAndStatus(BuildContext context) {
    return Text(
      '日志文件名：${record.fileName}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建解析信息
  Widget _buildParseInfo(BuildContext context) {
    return Row(
      children: [
        _buildInfoItem(context, Icons.access_time, record.parseTimeFormatted),
        const SizedBox(width: AppSpacing.lg),
        _buildInfoItem(context, Icons.storage, record.fileSizeFormatted),
        if (record.isSuccess) ...[
          const SizedBox(width: AppSpacing.lg),
          _buildInfoItem(
            context,
            Icons.format_list_numbered,
            '${record.logCount}条',
          ),
        ],
      ],
    );
  }

  /// 构建文件路径
  Widget _buildFilePath(BuildContext context) {
    return InkWell(
      onTap: () => _openFilePath(context),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          record.filePath,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.blue),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// 打开文件路径
  Future<void> _openFilePath(BuildContext context) async {
    try {
      final file = File(record.filePath);
      final directory = file.parent;

      // 根据平台使用不同的命令打开文件夹
      if (Platform.isMacOS) {
        await Process.run('open', [directory.path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [directory.path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [directory.path]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法打开文件路径: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('删除'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
        ),
      ],
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
}

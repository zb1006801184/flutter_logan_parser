import 'package:flutter/material.dart';
import '../models/logan_log_item.dart';
import '../theme/app_theme.dart';

/// 日志条目组件
class LogItemWidget extends StatelessWidget {
  final LoganLogItem logItem;
  final bool isSelected;
  final VoidCallback? onTap;

  const LogItemWidget({
    super.key,
    required this.logItem,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border:
                isSelected
                    ? Border.all(color: AppTheme.primaryColor, width: 2)
                    : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日志时间和类型
              Row(
                children: [
                  Expanded(
                    child: Text(
                      logItem.logTime ?? '未知时间',
                      style: Theme.of(context).textTheme.logTime,
                    ),
                  ),
                  _buildLogTypeChip(context),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // 日志内容
              Text(
                logItem.content ?? '无内容',
                style: Theme.of(context).textTheme.logContent,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // 线程信息
              if (logItem.threadName != null || logItem.threadId != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 14,
                      color: AppTheme.textHint,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${logItem.threadName ?? 'unknown'}(${logItem.threadId ?? '0'})',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
                    ),
                    if (logItem.isMainThread == 'true') ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '主线程',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建日志类型标签
  Widget _buildLogTypeChip(BuildContext context) {
    Color chipColor;
    IconData chipIcon;

    switch (logItem.flag) {
      case '2': // 调试
        chipColor = AppTheme.infoColor;
        chipIcon = Icons.bug_report_outlined;
        break;
      case '3': // 提示
        chipColor = AppTheme.successColor;
        chipIcon = Icons.info_outline;
        break;
      case '4': // 错误
        chipColor = AppTheme.errorColor;
        chipIcon = Icons.error_outline;
        break;
      case '5': // 警告
        chipColor = AppTheme.warningColor;
        chipIcon = Icons.warning_outlined;
        break;
      default:
        chipColor = AppTheme.textHint;
        chipIcon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 12, color: chipColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            logItem.logTypeDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 关于页面
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 应用信息
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Icon(
                      Icons.description,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Logan 日志解析工具',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 功能描述
            _buildSection(context, '功能特性', [
              '• 支持 Logan 加密日志文件解析',
              '• 提供日志内容搜索和筛选功能',
              '• 支持多种日志类型标识',
              '• 自动生成 JSON 格式解析结果',
              '• 美观的桌面端界面设计',
            ]),

            // 使用说明
            _buildSection(context, '使用说明', [
              '1. 点击右下角的"+"按钮选择 Logan 日志文件',
              '2. 等待系统自动解析日志内容',
              '3. 使用搜索框快速查找特定日志',
              '4. 通过筛选下拉框按类型过滤日志',
              '5. 点击日志条目查看详细信息',
            ]),

            // 技术栈
            _buildSection(context, '技术栈', [
              '• Flutter 3.x - 跨平台UI框架',
              '• Riverpod - 状态管理',
              '• JSON Annotation - 数据序列化',
              '• PointyCastle - 加密解密',
              '• File Picker - 文件选择',
            ]),

            const SizedBox(height: AppSpacing.xl),

            // 版权信息
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2024 Logan Parser Tool',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Built with Flutter',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  item,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            )
            .toList(),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

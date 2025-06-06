import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/logan_provider.dart';

/// 侧边菜单项数据
class SidebarMenuItem {
  final String id;
  final String title;
  final IconData icon;

  const SidebarMenuItem({
    required this.id,
    required this.title,
    required this.icon,
  });
}

/// 侧边菜单组件
class SidebarMenu extends ConsumerWidget {
  static const List<SidebarMenuItem> _menuItems = [
    SidebarMenuItem(
      id: '0',
      title: 'Logan解析',
      icon: Icons.description_outlined,
    ),
    SidebarMenuItem(id: '1', title: '解析历史', icon: Icons.history_outlined),
  ];

  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
      width: 200,
      decoration: _buildDecoration(),
      child: Column(
        children: [
          // 应用标题
          _buildTitle(context),
          const SizedBox(height: AppSpacing.md),

          // 菜单项列表
          _buildMenuList(context, ref),

          // 底部版本信息
          _buildVersionInfo(context),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: AppTheme.surfaceColor,
      border: Border(right: BorderSide(color: AppTheme.borderColor, width: 1)),
      boxShadow: AppShadows.card,
    );
  }

  // 应用标题
  Widget _buildTitle(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Center(
        child: Text(
          '菜单栏',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 菜单项列表
  Widget _buildMenuList(BuildContext context, WidgetRef ref) {
    final selectedMenuItem = ref.watch(selectedMenuItemProvider);
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          final isSelected = selectedMenuItem == item.id;

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () {
                  ref
                      .read(appStateProvider.notifier)
                      .updateSelectedMenuItem(ref, item.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : null,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border:
                        isSelected
                            ? Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            )
                            : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textPrimary,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 版本信息
  Widget _buildVersionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'v1.0.0',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar_menu.dart';
import '../providers/logan_provider.dart';
import '../theme/app_theme.dart';
import 'log_decode_page.dart';
import 'other_tools_page.dart';
import 'about_page.dart';

/// 主页面
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenuItem = ref.watch(selectedMenuItemProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // 侧边菜单
          const SidebarMenu(),

          // 主要内容区域
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                ),
                boxShadow: AppShadows.card,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                ),
                child: _buildContent(selectedMenuItem),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 根据选中的菜单项构建对应的内容
  Widget _buildContent(String selectedMenuItem) {
    switch (selectedMenuItem) {
      case '0':
        return const LogDecodePage();
      case '1':
        return const OtherToolsPage();
      case '2':
        return const AboutPage();
      default:
        return const LogDecodePage();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar_menu.dart';
import '../providers/logan_provider.dart';
import '../theme/app_theme.dart';
import 'log_decode_page.dart';
import 'parse_history_page.dart';


/// 主页面
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // 预创建所有页面实例，避免重复创建
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    // 初始化所有页面实例
    _pages = [
      const LogDecodePage(), // 索引 0: Logan解析
      const ParseHistoryPage(), // 索引 1: 解析历史
    ];
    
    // 应用启动时初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appStateProvider.notifier).initializeAppData(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenuItem = ref.watch(selectedMenuItemProvider);
    final selectedIndex = _getSelectedIndex(selectedMenuItem);

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
                // 使用 IndexedStack 保持页面状态
                child: IndexedStack(index: selectedIndex, children: _pages),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 根据菜单项ID获取对应的页面索引
  int _getSelectedIndex(String selectedMenuItem) {
    switch (selectedMenuItem) {
      case '0':
        return 0; // LogDecodePage
      case '1':
        return 1; // ParseHistoryPage  
      case '2':
        return 2; // OtherToolsPage
      case '3':
        return 3; // AboutPage
      default:
        return 0; // 默认返回LogDecodePage
    }
  }
}

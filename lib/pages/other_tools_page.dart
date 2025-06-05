import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

/// 其他工具页面
class OtherToolsPage extends StatelessWidget {
  const OtherToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyStateWidget(
        message: '更多工具正在开发中...',
        icon: Icons.build_outlined,
      ),
    );
  }
}

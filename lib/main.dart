import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: LoganParserApp()));
}

/// Logan 日志解析工具应用
class LoganParserApp extends StatelessWidget {
  const LoganParserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logan 日志解析工具',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const HomePage(),
    );
  }
}

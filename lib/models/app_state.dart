import 'logan_log_item.dart';

/// 应用UI状态
abstract class AppUIState {}

/// 空闲状态
class IdleState extends AppUIState {}

/// 日志解析加载中
class LogDecodeLoadingState extends AppUIState {}

/// 日志解析成功
class LogDecodeSuccessState extends AppUIState {
  final List<LoganLogItem> logData;

  LogDecodeSuccessState(this.logData);
}

/// 日志解析失败
class LogDecodeFailState extends AppUIState {
  final String errorMessage;

  LogDecodeFailState(this.errorMessage);
}

/// 搜索结果为空
class LogSearchEmptyState extends AppUIState {
  final String message;

  LogSearchEmptyState(this.message);
}

/// 侧边菜单项
class MenuItemData {
  final String id;
  final String title;
  final String iconPath;

  const MenuItemData({
    required this.id,
    required this.title,
    required this.iconPath,
  });
}

/// 筛选选项
class FilterOption {
  final String key;
  final String displayName;

  const FilterOption({required this.key, required this.displayName});

  static const List<FilterOption> options = [
    FilterOption(key: '', displayName: '全部日志'),
    FilterOption(key: 'printerRepeatProcess', displayName: '打印机补打'),
    FilterOption(key: 'printerAckProcess', displayName: '打印机ACK流程'),
    FilterOption(key: 'printerConvertProcess', displayName: '打印机转换流程'),
    FilterOption(key: 'printerPrintProcess', displayName: '打印机打印流程'),
  ];
}

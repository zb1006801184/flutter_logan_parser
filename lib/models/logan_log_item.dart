import 'package:json_annotation/json_annotation.dart';

part 'logan_log_item.g.dart';

/// Logan 日志条目数据模型
@JsonSerializable()
class LoganLogItem {
  /// 日志内容
  @JsonKey(name: 'c')
  final String? content;

  /// 日志类型标识 (2:调试, 3:信息/埋点, 4:错误, 5:警告 6：严重错误/崩溃  7：网络请求  8: 性能指标)
  @JsonKey(name: 'f')
  final String? flag;

  /// 日志时间
  @JsonKey(name: 'l')
  final String? logTime;

  /// 线程名称
  @JsonKey(name: 'n')
  final String? threadName;

  /// 线程ID
  @JsonKey(name: 'i')
  final String? threadId;

  /// 是否是主线程
  @JsonKey(name: 'm')
  final String? isMainThread;

  /// 日志时间解析
  String lotimeParse() {
    if (logTime == null) return '';
    final dateTime = DateTime.parse(logTime!);
    return dateTime.toString();
  }

  const LoganLogItem({
    this.content,
    this.flag,
    this.logTime,
    this.threadName,
    this.threadId,
    this.isMainThread,
  });

  /// 工厂构造函数 - 从 JSON 创建实例
  factory LoganLogItem.fromJson(Map<String, dynamic> json) =>
      _$LoganLogItemFromJson(json);

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$LoganLogItemToJson(this);

  /// 获取日志类型描述
  String get logTypeDescription {
    switch (flag) {
      case '2':
        return '调试信息';
      case '3':
        return '信息/埋点';
      case '4':
        return '错误信息';
      case '5':
        return '警告信息';
      case '6':
        return '严重错误';
      case '7':
        return '网络请求';
      case '8':
        return '性能指标';
      default:
        return '其他';
    }
  }

  /// 判断是否包含搜索关键词
  bool containsKeyword(String keyword) {
    if (keyword.isEmpty) return true;

    final lowerKeyword = keyword.toLowerCase();
    return (content?.toLowerCase().contains(lowerKeyword) ?? false) ||
        (logTime?.toLowerCase().contains(lowerKeyword) ?? false) ||
        (threadName?.toLowerCase().contains(lowerKeyword) ?? false);
  }

  /// 判断是否匹配筛选条件
  bool matchesFilter(String filterType) {
    // 如果筛选类型为空或者是"全部日志"，则显示所有日志
    if (filterType.isEmpty || filterType == '全部日志') return true;

    // 根据日志类型标识进行筛选
    return flag == filterType;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoganLogItem &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          flag == other.flag &&
          logTime == other.logTime &&
          threadName == other.threadName &&
          threadId == other.threadId &&
          isMainThread == other.isMainThread;

  @override
  int get hashCode =>
      content.hashCode ^
      flag.hashCode ^
      logTime.hashCode ^
      threadName.hashCode ^
      threadId.hashCode ^
      isMainThread.hashCode;
}

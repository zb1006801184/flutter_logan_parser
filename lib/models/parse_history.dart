import 'package:json_annotation/json_annotation.dart';

part 'parse_history.g.dart';

/// 解析历史记录模型
@JsonSerializable()
class ParseHistory {
  /// 文件路径
  final String filePath;

  /// 文件名
  final String fileName;

  /// 解析时间
  final DateTime parseTime;

  /// 文件大小（字节）
  final int fileSize;

  /// 解析出的日志条数
  final int logCount;

  /// 解析是否成功
  final bool isSuccess;

  /// 错误信息（如果解析失败）
  final String? errorMessage;

  const ParseHistory({
    required this.filePath,
    required this.fileName,
    required this.parseTime,
    required this.fileSize,
    required this.logCount,
    required this.isSuccess,
    this.errorMessage,
  });

  /// 从 JSON 创建实例
  factory ParseHistory.fromJson(Map<String, dynamic> json) =>
      _$ParseHistoryFromJson(json);

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$ParseHistoryToJson(this);

  /// 获取文件大小的格式化字符串
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 获取解析时间的格式化字符串
  String get parseTimeFormatted {
    return '${parseTime.year}-${parseTime.month.toString().padLeft(2, '0')}-${parseTime.day.toString().padLeft(2, '0')} ${parseTime.hour.toString().padLeft(2, '0')}:${parseTime.minute.toString().padLeft(2, '0')}';
  }
}

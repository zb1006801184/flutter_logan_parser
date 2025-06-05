// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parse_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParseHistory _$ParseHistoryFromJson(Map<String, dynamic> json) => ParseHistory(
  filePath: json['filePath'] as String,
  fileName: json['fileName'] as String,
  parseTime: DateTime.parse(json['parseTime'] as String),
  fileSize: (json['fileSize'] as num).toInt(),
  logCount: (json['logCount'] as num).toInt(),
  isSuccess: json['isSuccess'] as bool,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$ParseHistoryToJson(ParseHistory instance) =>
    <String, dynamic>{
      'filePath': instance.filePath,
      'fileName': instance.fileName,
      'parseTime': instance.parseTime.toIso8601String(),
      'fileSize': instance.fileSize,
      'logCount': instance.logCount,
      'isSuccess': instance.isSuccess,
      'errorMessage': instance.errorMessage,
    };

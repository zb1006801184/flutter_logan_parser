// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logan_log_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoganLogItem _$LoganLogItemFromJson(Map<String, dynamic> json) => LoganLogItem(
  content: json['c'] as String?,
  flag: json['f'] as String?,
  logTime: json['l'] as String?,
  threadName: json['n'] as String?,
  threadId: json['i'] as String?,
  isMainThread: json['m'] as String?,
);

Map<String, dynamic> _$LoganLogItemToJson(LoganLogItem instance) =>
    <String, dynamic>{
      'c': instance.content,
      'f': instance.flag,
      'l': instance.logTime,
      'n': instance.threadName,
      'i': instance.threadId,
      'm': instance.isMainThread,
    };

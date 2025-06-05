import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import '../models/logan_log_item.dart';

/// Logan 日志解析服务
class LoganParserService {
  // Logan 默认加密密钥（实际项目中这个密钥应该从配置中获取）
  static const String _defaultKey = "0123456789012345";
  static const String _defaultIv = "0123456789012345";

  /// 解析 Logan 日志文件
  Future<List<LoganLogItem>> parseLogFile(File file) async {
    try {
      final fileBytes = await file.readAsBytes();

      // 尝试解密文件内容
      final decryptedContent = await _decryptLogContent(fileBytes);

      // 解析解密后的内容
      final logItems = await _parseLogContent(decryptedContent);

      return logItems;
    } catch (e) {
      print('解析 Logan 日志文件失败: $e');

      // 如果解密失败，尝试直接解析（可能是未加密的日志）
      try {
        final content = await file.readAsString();
        return await _parseLogContent(content);
      } catch (e2) {
        print('直接解析日志文件也失败: $e2');
        rethrow;
      }
    }
  }

  /// 解密日志内容
  Future<String> _decryptLogContent(Uint8List encryptedBytes) async {
    try {
      // 使用 AES 解密
      final key = utf8.encode(_defaultKey);
      final iv = utf8.encode(_defaultIv);

      final cipher = BlockCipher('AES')
        ..init(false, ParametersWithIV(KeyParameter(key), iv));

      // 分块解密
      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i += 16) {
        final blockEnd =
            (i + 16 < encryptedBytes.length) ? i + 16 : encryptedBytes.length;
        final block = encryptedBytes.sublist(i, blockEnd);

        // 如果不足16字节，进行padding
        if (block.length < 16) {
          final paddedBlock = Uint8List(16);
          paddedBlock.setRange(0, block.length, block);
          decryptedBytes.addAll(cipher.process(paddedBlock));
        } else {
          decryptedBytes.addAll(cipher.process(block));
        }
      }

      // 移除 padding
      final unpaddedBytes = _removePadding(Uint8List.fromList(decryptedBytes));

      return utf8.decode(unpaddedBytes);
    } catch (e) {
      print('AES 解密失败: $e');
      rethrow;
    }
  }

  /// 移除 PKCS7 padding
  Uint8List _removePadding(Uint8List data) {
    if (data.isEmpty) return data;

    final paddingLength = data.last;
    if (paddingLength > data.length || paddingLength == 0) {
      return data;
    }

    return data.sublist(0, data.length - paddingLength);
  }

  /// 解析日志内容
  Future<List<LoganLogItem>> _parseLogContent(String content) async {
    final logItems = <LoganLogItem>[];

    try {
      // 按行分割内容
      final lines = content.split('\n');

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;

        try {
          // 尝试解析为 JSON
          final jsonData = jsonDecode(trimmedLine);
          if (jsonData is Map<String, dynamic>) {
            final logItem = LoganLogItem.fromJson(jsonData);
            logItems.add(logItem);
          }
        } catch (e) {
          // 如果不是 JSON 格式，创建一个简单的日志项
          final logItem = LoganLogItem(
            content: trimmedLine,
            logTime: DateTime.now().toIso8601String(),
            flag: '3', // 默认为提示信息
            threadName: 'unknown',
            threadId: '0',
            isMainThread: 'false',
          );
          logItems.add(logItem);
        }
      }
    } catch (e) {
      print('解析日志内容失败: $e');

      // 如果解析失败，将整个内容作为一条日志
      final logItem = LoganLogItem(
        content: content,
        logTime: DateTime.now().toIso8601String(),
        flag: '4', // 错误信息
        threadName: 'parser',
        threadId: '0',
        isMainThread: 'false',
      );
      logItems.add(logItem);
    }

    return logItems;
  }

  /// 生成解析后的 JSON 文件
  Future<File> generateJsonFile(
    List<LoganLogItem> logItems,
    String outputDir,
  ) async {
    final jsonData = logItems.map((item) => item.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputFile = File('$outputDir/logan_parsed_$timestamp.json');

    await outputFile.writeAsString(jsonString);
    return outputFile;
  }

  /// 模拟解析（用于测试，如果无法获取真实的 Logan 解密算法）
  Future<List<LoganLogItem>> mockParseLogFile(File file) async {
    // 返回一些模拟数据
    return [
      LoganLogItem(
        content: '应用启动完成',
        logTime: '2024-01-15 10:30:00',
        flag: '3',
        threadName: 'main',
        threadId: '1',
        isMainThread: 'true',
      ),
      LoganLogItem(
        content: '网络请求开始: https://api.example.com/data',
        logTime: '2024-01-15 10:30:15',
        flag: '2',
        threadName: 'network-thread',
        threadId: '12',
        isMainThread: 'false',
      ),
      LoganLogItem(
        content: '打印机连接成功 printerAckProcess',
        logTime: '2024-01-15 10:31:00',
        flag: '3',
        threadName: 'printer-thread',
        threadId: '15',
        isMainThread: 'false',
      ),
      LoganLogItem(
        content: '打印任务开始执行 printerPrintProcess',
        logTime: '2024-01-15 10:31:30',
        flag: '3',
        threadName: 'printer-thread',
        threadId: '15',
        isMainThread: 'false',
      ),
      LoganLogItem(
        content: '网络请求失败，连接超时',
        logTime: '2024-01-15 10:32:00',
        flag: '4',
        threadName: 'network-thread',
        threadId: '12',
        isMainThread: 'false',
      ),
    ];
  }
}

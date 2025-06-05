import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:archive/archive.dart';
import '../models/logan_log_item.dart';

/// Logan 日志解析服务
class LoganParserService {
  // Logan 默认加密密钥（实际项目中这个密钥应该从配置中获取）
  static const String _defaultKey = "0123456789012345";
  static const String _defaultIv = "0123456789012345";
  
  // Logan 加密内容开始标识符
  static const int encryptContentStart = 0x01;

  /// 解析 Logan 日志文件
  Future<List<LoganLogItem>> parseLogFile(File file) async {
    try {
      final fileBytes = await file.readAsBytes();
      print('开始解析 Logan 文件，文件大小: ${fileBytes.length} 字节');

      // 使用正确的 Logan 解析过程
      final decryptedContent = await _parseLoganFile(fileBytes);
      
      // 解析解密后的内容
      final logItems = await _parseLogContent(decryptedContent);
      
      print('解析完成，共获得 ${logItems.length} 条日志');
      return logItems;
    } catch (e) {
      print('解析 Logan 日志文件失败: $e');
      rethrow;
    }
  }

  /// 按照正确的 Logan 格式解析文件
  Future<String> _parseLoganFile(Uint8List fileBytes) async {
    final buffer = ByteData.sublistView(fileBytes);
    var offset = 0;
    final decryptedContent = StringBuffer();

    while (offset < fileBytes.length) {
      // 查找加密内容开始标识符
      if (offset >= fileBytes.length) break;

      final marker = buffer.getUint8(offset);
      if (marker != encryptContentStart) {
        // 如果不是加密标识符，继续查找
        offset++;
        continue;
      }

      offset++; // 跳过标识符

      // 读取加密内容长度（4字节，大端序）
      if (offset + 4 > fileBytes.length) break;

      final encryptedLength = buffer.getUint32(offset, Endian.big);
      offset += 4;

      print('找到加密块，长度: $encryptedLength');

      // 读取加密内容
      if (offset + encryptedLength > fileBytes.length) {
        print('加密内容长度超出文件范围，跳过');
        break;
      }

      final encryptedData = fileBytes.sublist(offset, offset + encryptedLength);
      offset += encryptedLength;
      
      try {
        // 解密数据
        final decryptedData = await _decryptAES(encryptedData);

        // 解压缩数据
        final decompressedData = await _decompressGzip(decryptedData);

        // 转换为字符串并添加到结果中
        final content = utf8.decode(decompressedData);
        decryptedContent.write(content);

        print('成功解密并解压缩一个数据块，内容长度: ${content.length}');
      } catch (e) {
        print('处理加密块失败: $e');
        // 继续处理下一个块
        continue;  
      }
    }

    return decryptedContent.toString();
  }

  /// AES 解密
  Future<Uint8List> _decryptAES(Uint8List encryptedData) async {
    try {
      final key = utf8.encode(_defaultKey);
      final iv = utf8.encode(_defaultIv);

      // 使用 AES/CBC/NoPadding 模式
      final cipher = CBCBlockCipher(AESEngine());
      final params = ParametersWithIV(KeyParameter(key), iv);
      cipher.init(false, params);

      // 确保数据长度是16的倍数（AES块大小）
      var dataToDecrypt = encryptedData;
      if (dataToDecrypt.length % 16 != 0) {
        // 如果不是16的倍数，需要填充
        final paddedLength = ((dataToDecrypt.length ~/ 16) + 1) * 16;
        final paddedData = Uint8List(paddedLength);
        paddedData.setRange(0, dataToDecrypt.length, dataToDecrypt);
        dataToDecrypt = paddedData;
      }

      final decryptedData = Uint8List(dataToDecrypt.length);
      var offset = 0;

      // 分块解密
      for (var i = 0; i < dataToDecrypt.length; i += 16) {
        final blockEnd =
            (i + 16 < dataToDecrypt.length) ? i + 16 : dataToDecrypt.length;
        final block = dataToDecrypt.sublist(i, blockEnd);
        
        if (block.length == 16) {
          final decryptedBlock = cipher.process(block);
          decryptedData.setRange(
            offset,
            offset + decryptedBlock.length,
            decryptedBlock,
          );
          offset += decryptedBlock.length;
        }
      }

      // 移除可能的填充
      return _removePKCS7Padding(decryptedData.sublist(0, offset));
    } catch (e) {
      print('AES 解密失败: $e');
      rethrow;
    }
  }

  /// 移除 PKCS7 填充
  Uint8List _removePKCS7Padding(Uint8List data) {
    if (data.isEmpty) return data;

    final paddingLength = data.last;
    if (paddingLength > data.length ||
        paddingLength == 0 ||
        paddingLength > 16) {
      return data;
    }

    // 验证填充是否正确
    for (var i = data.length - paddingLength; i < data.length; i++) {
      if (data[i] != paddingLength) {
        return data; // 填充不正确，返回原数据
      }
    }

    return data.sublist(0, data.length - paddingLength);
  }

  /// GZIP 解压缩
  Future<Uint8List> _decompressGzip(Uint8List compressedData) async {
    try {
      final archive = GZipDecoder();
      final decompressed = archive.decodeBytes(compressedData);
      return Uint8List.fromList(decompressed);
    } catch (e) {
      print('GZIP 解压缩失败: $e');
      rethrow;
    }
  }

  /// 解析日志内容
  Future<List<LoganLogItem>> _parseLogContent(String content) async {
    final logItems = <LoganLogItem>[];

    try {
      // 按行分割内容
      final lines = content.split('\n');
      print('开始解析 ${lines.length} 行日志内容');

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;

        try {
          // 尝试解析为 JSON
          final jsonData = jsonDecode(trimmedLine);
          if (jsonData is Map<String, dynamic>) {
            // 使用正确的 Logan JSON 格式
            final logItem = LoganLogItem(
              content: jsonData['c']?.toString() ?? '',
              logTime: _formatLogTime(jsonData['l']),
              flag: jsonData['f']?.toString() ?? '3',
              threadName: jsonData['n']?.toString() ?? 'unknown',
              threadId: jsonData['i']?.toString() ?? '0',
              isMainThread: jsonData['m']?.toString() ?? 'false',
            );
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

  /// 格式化日志时间
  String _formatLogTime(dynamic timeValue) {
    if (timeValue == null) {
      return DateTime.now().toIso8601String();
    }

    try {
      int timestamp;
      if (timeValue is String) {
        timestamp = int.parse(timeValue);
      } else if (timeValue is num) {
        timestamp = timeValue.toInt();
      } else {
        return DateTime.now().toIso8601String();
      }

      // Logan 使用毫秒时间戳
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return dateTime.toIso8601String();
    } catch (e) {
      print('时间格式化失败: $e, 原始值: $timeValue');
      return DateTime.now().toIso8601String();
    }
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

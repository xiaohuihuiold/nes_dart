import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nes_dart/src/bytes_ext.dart';
import 'package:nes_dart/src/logger.dart';

part 'nes_rom.dart';

/// ROM加载器
class NESRomLoader {
  /// NES文件头
  static const fileHeader = 'NES';

  /// 从内存创建
  static NESRom loadFromMemory(Uint8List bytes) {
    final byteData = bytes.buffer.asByteData();
    if (byteData.getString(0) != fileHeader) {
      logger.e('非nes文件');
      throw Exception('非nes文件');
    }
    final nes20Format = byteData.getUint8(7) & 0xc == 0x8;
    return NESRom._create(nes20Format: nes20Format);
  }

  /// 从文件路径创建
  static Future<NESRom> loadFromPath(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('文件不存在');
    }
    return loadFromMemory(await file.readAsBytes());
  }
}

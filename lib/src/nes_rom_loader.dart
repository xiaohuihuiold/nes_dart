import 'dart:io';

import 'package:flutter/services.dart';
import 'bytes_ext.dart';
import 'logger.dart';
import 'nes_rom.dart';

/// ROM加载器
class NESRomLoader {
  /// NES文件头
  static const fileHeader = 'NES';

  /// 构造器
  final _builder = NESRomBuilder();

  /// 数据
  final ByteData _byteData;

  NESRomLoader._create(this._byteData);

  /// 从内存创建
  static NESRom loadFromMemory(Uint8List bytes) {
    final byteData = bytes.buffer.asByteData();
    if (byteData.getString(0) != fileHeader) {
      logger.e('非nes文件');
      throw Exception('非nes文件');
    }
    final loader = NESRomLoader._create(byteData);
    return loader.load();
  }

  /// 从文件路径创建
  static Future<NESRom> loadFromPath(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('文件不存在');
    }
    return loadFromMemory(await file.readAsBytes());
  }

  /// 加载ROM
  NESRom load() {
    int offset = 4;
    offset = _loadPRGAndCHRSize(offset);
    offset = _loadFlag6(offset);
    offset = _loadFlag7(offset);
    return _builder.build();
  }

  /// 获取PRG和CHR大小
  int _loadPRGAndCHRSize(int offset) {
    // offset: 4
    _builder.prgCount = _byteData.getUint8(offset);
    offset += 1;
    // offset: 5
    _builder.chrCount = _byteData.getUint8(offset);
    return offset + 1;
  }

  /// 获取flag
  int _loadFlag6(int offset) {
    // offset: 6
    final byte = _byteData.getUint8(offset);
    // bit(0):
    _builder.nameTableMirrorType = (byte & 0x01 == 1)
        ? NESNameTableMirrorType.vertical
        : NESNameTableMirrorType.horizontal;
    // bit(1):
    _builder.hasBattery = ((byte >> 1) & 0x01) == 1;
    // bit(2):
    _builder.hasTrainer = ((byte >> 2) & 0x01) == 1;
    // bit(3):
    _builder.fourScreenMode = ((byte >> 3) & 0x01) == 1;
    // bit(4-7):
    // TODO: 读取Mapper Number D0-D3
    return offset + 1;
  }

  /// 获取flag
  int _loadFlag7(int offset) {
    // offset: 7
    final byte = _byteData.getUint8(offset);
    // bit(0-1):
    _builder.consoleType = NESConsoleType.values[byte & 0x03];
    // bit(3): 为1则是NES2.0
    _builder.version =
        (byte & 0x0C == 0x08) ? NESVersion.nes20 : NESVersion.nes10;
    // bit(4-7):
    // TODO: 读取Mapper Number D4-D7
    return offset + 1;
  }
}

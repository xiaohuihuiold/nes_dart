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

  /// 从asset创建
  static Future<NESRom> loadFromAsset(
    String key, {
    AssetBundle? bundle,
  }) async {
    final byteData = await (bundle ?? rootBundle).load(key);
    return loadFromMemory(byteData.buffer.asUint8List());
  }

  /// 加载ROM
  NESRom load() {
    _builder.fileSize = _byteData.lengthInBytes;
    int offset = 4;
    offset = _loadHeader(offset);
    offset = _loadPRGAndCHRRom(offset);
    return _builder.build();
  }

  /// 加载header
  int _loadHeader(int offset) {
    offset = _loadPRGAndCHRSize(offset);
    offset = _loadFlag6(offset);
    offset = _loadFlag7(offset);
    if (_builder.version == NESVersion.nes20) {
      // TODO: 实现NES2.0头读取
      throw Exception('未实现NES2.0读取');
    } else {
      offset += 8;
    }
    if (_builder.hasTrainer) {
      // TODO: 实现Trainer
      throw Exception('未实现Trainer');
    }
    return offset;
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
    _builder.mirrorType =
        (byte & 0x01 == 1) ? NESMirrorType.vertical : NESMirrorType.horizontal;
    // bit(1):
    _builder.hasSRAM = ((byte >> 1) & 0x01) == 1;
    // bit(2):
    _builder.hasTrainer = ((byte >> 2) & 0x01) == 1;
    // bit(3):
    _builder.fourScreenMode = ((byte >> 3) & 0x01) == 1;
    // bit(4-7):
    _builder.mapperNumber = (byte >> 4) & 0x0F;
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
    _builder.mapperNumber = byte & 0xF0;
    return offset + 1;
  }

  /// 获取PRG-ROM和CHR-ROM
  int _loadPRGAndCHRRom(int offset) {
    // offset: 16
    final prgSize = _builder.prgCount * kPRGChunkSize;
    final chrSize = _builder.chrCount * kCHRChunkSize;
    _builder.prgRom = _byteData.getUint8List(offset, offset + prgSize);
    offset += prgSize;
    _builder.chrRom = _byteData.getUint8List(offset, offset + chrSize);
    return offset + chrSize;
  }
}

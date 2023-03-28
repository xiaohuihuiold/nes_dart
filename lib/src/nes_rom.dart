import 'dart:io';

import 'package:flutter/services.dart';

/// ROM
class NESRom {
  /// 从内存创建
  factory NESRom.fromMemory(Uint8List bytes) {
    return NESRom._create();
  }

  /// 从文件路径创建
  static Future<NESRom> fromPath(String path) async {
    return NESRom.fromMemory(await File(path).readAsBytes());
  }

  NESRom._create();

  @override
  String toString() {
    return 'NESRom {\n'
        '}';
  }
}

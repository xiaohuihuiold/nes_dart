import 'dart:typed_data';

import 'package:nes_dart/src/bytes_ext.dart';

/// 内存
class NESMemory {
  /// 将可寻址最大地址作为内存大小,65536字节
  static const _memorySize = 2 << 16;

  /// 内存
  ByteData _memory = ByteData(_memorySize);

  /// 重置内存
  void reset() {
    _memory = ByteData(_memorySize);
  }

  /// 获取uint16类型数据
  int read16(int address) {
    return _memory.getUint16(address, Endian.little);
  }

  /// 设置uint16类型数据
  void write16(int address, int value) {
    _memory.setUint16(address, value, Endian.little);
  }

  /// 获取uint8类型数据
  int read(int address) {
    return this[address];
  }

  /// 设置uint8类型数据
  void write(int address, int value) {
    this[address] = value;
  }

  /// 获取多段数据
  Uint8List readAll(int address, int length) {
    return _memory.getUint8List(address, address + length);
  }

  /// 写入多段数据
  void writeAll(int address, List<int> bytes) {
    _memory.setUint8List(address, bytes);
  }

  /// 获取uint8类型数据
  int operator [](int address) {
    return _memory.getUint8(address);
  }

  /// 设置uint8类型数据
  void operator []=(int address, int value) {
    _memory.setUint8(address, value);
  }
}

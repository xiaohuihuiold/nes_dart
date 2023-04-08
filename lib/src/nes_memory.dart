import 'dart:typed_data';

import 'package:nes_dart/src/logger.dart';

import 'bytes_ext.dart';
import 'constants.dart';

/// 内存
class NESMemory {
  /// 页面
  static const pageSize = 0x0100;
  static const pageCount = 0x0100;

  /// 将可寻址最大地址作为内存大小,65536字节
  static const _memorySize = Constants.byte64KiB;

  /// 内存
  ByteData _memory = ByteData(_memorySize);

  /// 重置内存
  void reset() {
    _memory = ByteData(_memorySize);
    logger.v('内存已重置');
  }

  /// 获取uint16类型数据
  int read16(int address) {
    return _memory.getUint16(address, Endian.little);
  }

  /// 设置int16类型数据
  void write16S(int address, int value) {
    _memory.setInt16(address, value, Endian.little);
  }

  /// 获取int16类型数据
  int read16S(int address) {
    return _memory.getInt16(address, Endian.little);
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

  /// 获取int8类型数据
  int readS(int address) {
    return _memory.getInt8(address);
  }

  /// 设置int8类型数据
  void writeS(int address, int value) {
    _memory.setInt8(address, value);
  }

  /// 获取多段数据
  Uint8List readAll(int address, int length) {
    return _memory.getUint8List(address, address + length);
  }

  /// 写入多段数据
  void writeAll(int address, List<int> bytes, {int start = 0, int? end}) {
    _memory.setUint8List(address, bytes, start: start, end: end);
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

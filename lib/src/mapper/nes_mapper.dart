import 'package:flutter/foundation.dart';
import 'package:nes_dart/src/logger.dart';

import '../constants.dart';
import '../nes_memory.dart';
import '../nes_emulator.dart';

part 'nes_mappers.dart';

/// Mapper
///
/// | 地址范围     | 大小  | 描述                |
/// | :---------: | :---: | :----------------: |
/// | $0000-$07FF | $0800 | 2KiB RAM           |
/// | $0800-$0FFF | $0800 | $0000-$07FF的镜像   |
/// | $1000-$17FF | $0800 | $0000-$07FF的镜像   |
/// | $1800-$1FFF | $0800 | $0000-$07FF的镜像   |
/// | $2000-$2007 | $0008 | PPU的寄存器         |
/// | $2008-$3FFF | $1FF8 | $2000-$2007的镜像   |
/// | $4000-$4017 | $0018 | APU和IO寄存器       |
/// | $4018-$401F | $0008 | APU和IO相关         |
/// | $4020-$FFFF | $BFE0 | 卡带空间            |
abstract class NESMapper {
  /// RAM地址mask
  static const maskRAM = 0x07FF;

  /// RAM最大地址
  static const maxRAMAddress = 0x1FFF;

  /// 模拟器
  final NESEmulator emulator;

  /// 内存
  final _memory = NESMemory();

  NESMapper(this.emulator);

  /// 重置
  @mustCallSuper
  void reset() {
    _memory.reset();
  }

  /// 写入数据
  void write(int address, int value);

  /// 读取数据
  int read(int address);
}

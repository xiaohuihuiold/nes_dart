import 'package:flutter/material.dart';

import 'logger.dart';
import 'nes_ppu.dart';
import 'nes_emulator.dart';

/// PPU寄存器类型
enum NESPpuRegister {
  /// PPU控制寄存器
  ctrl(0x2000),

  /// PPU掩码寄存器
  mask(0x2001),

  /// PPU状态寄存器
  status(0x2002),

  /// 精灵RAM指针
  spriteRamPointer(0x2003),

  /// 精灵RAM数据
  spriteRamData(0x2004),

  /// 屏幕滚动偏移
  screenScrollOffset(0x2005),

  /// 显存指针
  vramPointer(0x2006),

  /// 显存数据
  vramData(0x2007),

  /// DMA访问精灵RAM
  dma(0x4014);

  final int address;

  const NESPpuRegister(this.address);
}

/// PPU状态寄存器
enum NESPpuStatusRegister {
  /// VBlank标志位
  vBlank(1 << 7);

  final int bit;

  const NESPpuStatusRegister(this.bit);
}

/// PPU寄存器
/// !!!不要直接修改寄存器,需要通过[emulator.mapper]来修改值
class NESPpuRegisters extends ChangeNotifier {
  /// PPU
  final NESPpu ppu;

  /// 模拟器
  NESEmulator get emulator => ppu.emulator;

  /// 状态寄存器
  int _status = 0;

  int get status => _status;

  set status(int value) {
    _status = value & 0xFF;
    notifyListeners();
    if (emulator.logPpuRegisters) {
      logger
          .v('PPU REG: SET STATUS=${_status.toRadixString(16).toUpperCase()}');
    }
  }

  /// 显存指针
  /// 第一次写入高八位
  /// 第二次写入低八位
  int _vramPointer = 0;

  int get vramPointer => _vramPointer;

  bool first = true;

  set vramPointer(int value) {
    if (first) {
      _vramPointer = (value & 0xFF) << 8;
    } else {
      _vramPointer |= (value & 0xFF);
    }
    notifyListeners();
    if (emulator.logPpuRegisters) {
      logger.v(
          'PPU REG: SET VRAM POINTER(${first ? 'H' : 'L'}=${_vramPointer.toRadixString(16).toUpperCase()}');
    }
  }

  NESPpuRegisters(this.ppu);

  /// 重置寄存器
  void reset() {
    status = 0;
  }
}

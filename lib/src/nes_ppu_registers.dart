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
  scrollOffset(0x2005),

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

/// PPU控制寄存器
enum NESPpuCtrlRegister {
  /// 读写显存增量
  /// 0: +1列,1: +32行
  inc(1 << 2),

  /// 是否NMI中断
  nmi(1 << 7),

  /// 背景
  background(1 << 5);

  final int bit;

  const NESPpuCtrlRegister(this.bit);
}

/// PPU寄存器
/// !!!不要直接修改寄存器,需要通过[emulator.mapper]来修改值
class NESPpuRegisters extends ChangeNotifier {
  /// PPU
  final NESPpu ppu;

  /// 模拟器
  NESEmulator get emulator => ppu.emulator;

  /// 控制寄存器
  int _ctrl = 0;

  int get ctrl => _ctrl;

  set ctrl(int value) {
    _ctrl = value & 0xFF;
    notifyListeners();
    if (emulator.logPpuRegisters) {
      logger.v('PPU REG: SET CTRL=${_ctrl.toRadixString(16).toUpperCase()}');
    }
  }

  /// 掩码寄存器
  int _mask = 0;

  int get mask => _mask;

  set mask(int value) {
    _mask = value & 0xFF;
    if (emulator.logPpuRegisters) {
      logger.v('PPU REG: SET MASK=${_mask.toRadixString(16).toUpperCase()}');
    }
  }

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

  /// 精灵RAM指针
  int _spriteRamPointer = 0;

  int get spriteRamPointer => _spriteRamPointer;

  set spriteRamPointer(int value) {
    _spriteRamPointer = value & 0xFF;
    notifyListeners();
    if (emulator.logPpuRegisters) {
      logger.v(
          'PPU REG: SET SPRITE RAM POINTER=${_spriteRamPointer.toRadixString(16).toUpperCase()}');
    }
  }

  /// 滚动偏移
  /// 第一次写入高八位
  /// 第二次写入低八位
  int _scrollOffset = 0;

  int get scrollOffset => _scrollOffset;

  bool scrollOffsetFirst = true;

  set scrollOffset(int value) {
    _scrollOffset = value & 0xFFFF;
    notifyListeners();
    if (emulator.logPpuRegisters) {
      logger.v(
          'PPU REG: SET SCROLL OFFSET=${_scrollOffset.toRadixString(16).toUpperCase()}');
    }
  }

  /// 显存指针
  /// 第一次写入高八位
  /// 第二次写入低八位
  int _vramPointer = 0;

  int get vramPointer => _vramPointer;

  bool vramPointerFirst = true;

  set vramPointer(int value) {
    _vramPointer = value & 0xFFFF;
    notifyListeners();
    if (emulator.logPpuRegisters) {
      logger.v(
          'PPU REG: SET VRAM POINTER=${_vramPointer.toRadixString(16).toUpperCase()}');
    }
  }

  NESPpuRegisters(this.ppu);

  /// 重置寄存器
  void reset() {
    ctrl = 0;
    mask = 0;
    status = 0;
    spriteRamPointer = 0;
    scrollOffset = 0;
    scrollOffsetFirst = true;
    vramPointer = 0;
    vramPointerFirst = true;
  }
}

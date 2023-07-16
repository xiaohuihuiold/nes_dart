import 'package:flutter/material.dart';

import 'logger.dart';
import 'nes_ppu.dart';
import 'nes_emulator.dart';

/// PPU寄存器
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
    if (emulator.logRegisters) {
      logger.v('PPU REG: SET ACC=${_status.toRadixString(16).toUpperCase()}');
    }
  }

  NESPpuRegisters(this.ppu);

  /// 重置寄存器
  void reset() {
    status = 0;
  }
}

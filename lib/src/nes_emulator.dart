import 'dart:typed_data';

import 'logger.dart';

import 'nes_rom.dart';

/// 模拟器状态
enum NESEmulatorState {
  idle,
  running,
  pause,
  stop,
}

/// NES模拟器
class NESEmulator {
  /// rom
  final NESRom rom;

  /// 程序bank
  final _prgBanks = List<ByteData?>.filled(0x10000 >> 13, null);

  /// 工作内存
  final _saveMemory = ByteData(8 * 1024);

  /// 主内存
  final _mainMemory = ByteData(2 * 1024);

  /// 模拟器状态
  NESEmulatorState _state = NESEmulatorState.idle;

  NESEmulatorState get state => _state;

  NESEmulator({
    required this.rom,
  });

  /// 运行模拟器
  void run() {
    if (state != NESEmulatorState.idle) {
      logger.w('模拟器正在运行中');
      return;
    }
    logger.i('模拟器开始运行...');
    _prgBanks[0] = _saveMemory;
    _prgBanks[3] = _mainMemory;
    _resetMapper00();
  }

  /// 重置mapper00
  void _resetMapper00() {
    final id2 = rom.prgCount & 0x10;
    _loadProgram8k(0, 0);
    _loadProgram8k(1, 1);
    _loadProgram8k(2, id2 + 0);
    _loadProgram8k(3, id2 + 1);
  }

  /// 加载8k PRG-ROM
  void _loadProgram8k(int dest, int src) {
    final prgRom = rom.prgRom;
    if (prgRom == null) {
      logger.e('找不到PRG-ROM');
      return;
    }
  }
}

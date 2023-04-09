import 'nes_memory.dart';
import 'nes_emulator.dart';
import 'logger.dart';

/// PPU
class NESPpu {
  /// VRAM
  final _memory = NESMemory();

  /// 模拟器
  final NESEmulator emulator;

  NESPpu(this.emulator);

  /// 重置
  void reset() {
    _memory.reset();
    logger.v('PPU已重置');
  }
}

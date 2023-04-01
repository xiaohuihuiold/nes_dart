import 'logger.dart';
import 'nes_emulator.dart';

/// CPU中断
///
/// 中断时会执行指定地址存放的地址
enum NESCpuInterrupt {
  // IRQ中断,$FFFE-$FFFF
  irq(0xFFFE),
  // BRK中断,$FFFE-$FFFF
  brk(0xFFFE),
  // NMI中断,$FFFA-$FFFB
  nmi(0xFFFA),
  // RESET中断,$FFFC-$FFFD
  reset(0xFFFC);

  final int address;

  const NESCpuInterrupt(this.address);
}

/// CPU
class NESCpu {
  /// 模拟器
  final NESEmulator emulator;

  NESCpu(this.emulator);

  /// 重置
  void reset() {
    emulator.mapper.reset();
    final irqAddress = emulator.mapper
        .readInterruptAddress(NESCpuInterrupt.irq)
        .toRadixString(16)
        .toUpperCase();
    final nmiAddress = emulator.mapper
        .readInterruptAddress(NESCpuInterrupt.nmi)
        .toRadixString(16)
        .toUpperCase();
    final resetAddress = emulator.mapper
        .readInterruptAddress(NESCpuInterrupt.reset)
        .toRadixString(16)
        .toUpperCase();
    logger.i('IRQ/BRK: \$$irqAddress, NMI: \$$nmiAddress, RESET: \$$resetAddress');
    logger.v('CPU已重置');
  }
}

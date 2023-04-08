import 'nes_cpu_addressing.dart';
import 'logger.dart';
import 'nes_emulator.dart';
import 'nes_cpu_registers.dart';

/// CPU中断
///
/// 中断时会执行指定地址存放的地址
enum NESCpuInterrupt {
  /// IRQ中断,$FFFE-$FFFF
  irq(0xFFFE, 0),

  /// BRK中断,$FFFE-$FFFF
  brk(0xFFFE, 1),

  /// NMI中断,$FFFA-$FFFB
  nmi(0xFFFA, 2),

  /// RESET中断,$FFFC-$FFFD
  reset(0xFFFC, 3);

  final int address;
  final int priority;

  const NESCpuInterrupt(this.address, this.priority);
}

/// CPU
class NESCpu {
  /// 模拟器
  final NESEmulator emulator;

  /// 寄存器
  final registers = NESCpuRegisters();

  /// 寻址
  late final addressing = NESCpuAddressing(this);

  NESCpu(this.emulator);

  /// 重置
  void reset() {
    emulator.mapper.reset();
    registers.pc = emulator.mapper.readInterruptAddress(NESCpuInterrupt.reset);
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
    logger.i(
        'IRQ/BRK: \$$irqAddress, NMI: \$$nmiAddress, RESET: \$$resetAddress');
    logger.v('CPU已重置');
  }
}

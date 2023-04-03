import 'logger.dart';
import 'nes_emulator.dart';

/// CPU中断
///
/// 中断时会执行指定地址存放的地址
enum NESCpuInterrupt {
  // IRQ中断,$FFFE-$FFFF
  irq(0xFFFE, 0),
  // BRK中断,$FFFE-$FFFF
  brk(0xFFFE, 1),
  // NMI中断,$FFFA-$FFFB
  nmi(0xFFFA, 2),
  // RESET中断,$FFFC-$FFFD
  reset(0xFFFC, 3);

  final int address;
  final int priority;

  const NESCpuInterrupt(this.address, this.priority);
}

/// 寄存器
enum NESCpuRegister {
  // 8位累加器
  accumulator,
  // 8位X变址寄存器
  xIndex,
  // 8位Y变址寄存器
  yIndex,
  // 8位状态寄存器,详细状态见[NESCpuStatusRegister]
  status,
  // 16位指令计数器
  programCounter,
  // 8位栈指针
  stackPointer,
}

/// 状态寄存器
enum NESCpuStatusRegister {
  // 进位标记,指令结果是否进位
  c(1 << 0),
  // 零标记,指令结果是否为0
  z(1 << 1),
  // 禁止中断标记,除NMI中断
  i(1 << 2),
  // 十进制模式标记,NES无作用
  d(1 << 3),
  // BRK中断时被设置
  b(1 << 4),
  // 未使用
  r(1 << 5),
  // 溢出标记,指令结果溢出
  v(1 << 6),
  // 符号标记
  s(1 << 7);

  final int bit;

  const NESCpuStatusRegister(this.bit);
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
    logger.i(
        'IRQ/BRK: \$$irqAddress, NMI: \$$nmiAddress, RESET: \$$resetAddress');
    logger.v('CPU已重置');
  }
}

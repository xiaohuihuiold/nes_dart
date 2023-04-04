import 'logger.dart';
import 'nes_emulator.dart';

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

/// 寄存器
class NESCpuRegisters {
  /// 8位累加器
  int acc = 0;

  /// 8位X变址寄存器
  int x = 0;

  /// 8位Y变址寄存器
  int y = 0;

  /// 8位状态寄存器
  final status = NESCpuStatusRegisters();

  /// 16位指令计数器
  int pc = 0;

  /// 8位栈指针
  int sp = 0;
}

/// 状态寄存器
class NESCpuStatusRegisters {
  /// 进位标记,指令结果是否进位
  int c = 0;

  /// 零标记,指令结果是否为0
  int z = 0;

  /// 禁止中断标记,除NMI中断
  /// 1为禁止
  int i = 0;

  /// 十进制模式标记,NES无作用
  int d = 0;

  /// BRK中断时被设置
  int b = 0;

  /// 未使用
  int r = 0;

  /// 溢出标记,指令结果溢出
  int v = 0;

  /// 符号标记
  int s = 0;
}

/// CPU
class NESCpu {
  /// 模拟器
  final NESEmulator emulator;

  /// 寄存器
  final registers = NESCpuRegisters();

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

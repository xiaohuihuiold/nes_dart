import 'logger.dart';
import 'nes_emulator.dart';
import 'nes_cpu_codes.dart';

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
  int status = 0;

  /// 16位指令计数器
  int pc = 0;

  /// 8位栈指针
  int sp = 0;

  /// 获取状态寄存器flag
  int getStatus(NESCpuStatusRegister flag) {
    return (status >> flag.index) & 0x01;
  }

  /// 设置状态寄存器flag
  void setStatus(NESCpuStatusRegister flag, int value) {
    status &= ~flag.bit;
    status |= (value & 0x01) << flag.index;
  }
}

/// 状态寄存器
enum NESCpuStatusRegister {
  /// 进位标记,指令结果是否进位
  c(1 << 0),

  /// 零标记,指令结果是否为0
  z(1 << 1),

  /// 禁止中断标记,除NMI中断
  i(1 << 2),

  /// 十进制模式标记,NES无作用
  d(1 << 3),

  /// BRK中断时被设置
  b(1 << 4),

  /// 未使用
  r(1 << 5),

  /// 溢出标记,指令结果溢出
  v(1 << 6),

  /// 符号标记
  s(1 << 7);

  final int bit;

  const NESCpuStatusRegister(this.bit);
}

/// CPU
class NESCpu {
  /// 模拟器
  final NESEmulator emulator;

  /// 寄存器
  final registers = NESCpuRegisters();

  /// 寻址模式
  late final _addressingMapping = <NESAddressing, int Function()>{
    NESAddressing.accumulator: _addressingAccumulator,
    NESAddressing.implied: _addressingImplied,
    NESAddressing.immediate: _addressingImmediate,
    NESAddressing.absolute: _addressingAbsolute,
    NESAddressing.zeroPage: _addressingZeroPage,
    NESAddressing.absoluteX: _addressingAbsoluteX,
    NESAddressing.absoluteY: _addressingAbsoluteY,
    NESAddressing.zeroPageX: _addressingZeroPageX,
    NESAddressing.zeroPageY: _addressingZeroPageY,
    NESAddressing.indirect: _addressingIndirect,
    NESAddressing.indirectX: _addressingIndirectX,
    NESAddressing.indirectY: _addressingIndirectY,
    NESAddressing.relative: _addressingRelative,
  };

  NESCpu(this.emulator);

  /// 寻址
  int getAddress(NESAddressing mode) {
    return _addressingMapping[mode]?.call() ?? 0;
  }

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

  /// 无需处理
  int _addressingAccumulator() {
    return 0;
  }

  /// 无需处理
  int _addressingImplied() {
    return 0;
  }

  /// 地址是当前PC位置
  int _addressingImmediate() {
    final address = registers.pc;
    registers.pc++;
    return address;
  }

  int _addressingAbsolute() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingZeroPage() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingAbsoluteX() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingAbsoluteY() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingZeroPageX() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingZeroPageY() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingIndirect() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingIndirectX() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingIndirectY() {
    // TODO: 实现
    throw Exception('未实现');
  }

  int _addressingRelative() {
    // TODO: 实现
    throw Exception('未实现');
  }
}

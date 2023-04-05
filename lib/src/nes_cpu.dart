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
  int _acc = 0;

  /// 8位X变址寄存器
  int _x = 0;

  /// 8位Y变址寄存器
  int _y = 0;

  /// 8位状态寄存器
  int _status = 0;

  /// 16位指令计数器
  int _pc = 0;

  /// 8位栈指针
  int _sp = 0;

  int get acc => _acc;

  set acc(int value) => _acc = value & 0xFF;

  int get x => _x;

  set x(int value) => _x = value & 0xFF;

  int get y => _y;

  set y(int value) => _y = value & 0xFF;

  int get status => _status;

  set status(int value) => _status = value & 0xFF;

  int get pc => _pc;

  set pc(int value) => _pc = value & 0xFFFF;

  int get sp => _sp;

  set sp(int value) => _sp = value & 0xFF;

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
    return (_addressingMapping[mode]?.call() ?? 0) & 0xFFFF;
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
    return registers.pc;
  }

  /// 地址是当前PC位置的值,16位
  int _addressingAbsolute() {
    return emulator.mapper.read16(registers.pc);
  }

  /// 地址是当前PC位置的值,8位
  int _addressingZeroPage() {
    return emulator.mapper.read(registers.pc);
  }

  /// PC位置的值加上X变址寄存器的值
  int _addressingAbsoluteX() {
    return registers.x + emulator.mapper.read16(registers.pc);
  }

  /// PC位置的值加上Y变址寄存器的值
  int _addressingAbsoluteY() {
    return registers.y + emulator.mapper.read16(registers.pc);
  }

  /// PC的8位值加上X变址寄存器的值,并取前8位
  int _addressingZeroPageX() {
    return (registers.x + emulator.mapper.read(registers.pc)) & 0xFF;
  }

  /// PC的8位值加上Y变址寄存器的值,并取前8位
  int _addressingZeroPageY() {
    return (registers.y + emulator.mapper.read(registers.pc)) & 0xFF;
  }

  /// 16位,读取PC位置的值指向的地址值作为地址
  /// 当地址是$xxFF时,PC位置的下一个地址把FF变成00
  int _addressingIndirect() {
    final temp = emulator.mapper.read16(registers.pc);
    if (temp & 0xFF == 0xFF) {
      // 实现$xxFF
      return emulator.mapper.read(temp) |
          (emulator.mapper.read(temp & 0xFF00) << 8);
    } else {
      return emulator.mapper.read16(temp);
    }
  }

  /// PC的值与X变址寄存器相加得到新的地址
  /// 新的地址读取两个字节作为新的地址
  int _addressingIndirectX() {
    final temp = emulator.mapper.read(registers.pc) + registers.x;
    return emulator.mapper.read16(temp);
  }

  /// PC的值作为地址,并读取地址的值与Y变址寄存器相加
  int _addressingIndirectY() {
    final temp = emulator.mapper.read(registers.pc);
    return emulator.mapper.read16(temp) + registers.y;
  }

  /// PC加上当前地址值偏移
  int _addressingRelative() {
    return emulator.mapper.read(registers.pc) + registers.pc + 1;
  }
}

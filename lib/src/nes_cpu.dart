import 'nes_cpu_executor.dart';
import 'nes_cpu_addressing.dart';
import 'logger.dart';
import 'nes_emulator.dart';
import 'nes_cpu_registers.dart';
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

/// CPU
class NESCpu {
  /// PAL主频 Hz
  static const clockSpeedPAL = 1773447;
  static const clockSpeedPALus = 1000000 / clockSpeedPAL;

  /// NTSC主频 Hz
  static const clockSpeedNTSC = 1789772;
  static const clockSpeedNTSCus = 1000000 / clockSpeedNTSC;

  /// 模拟器
  final NESEmulator emulator;

  /// 寄存器
  late final registers = NESCpuRegisters(this);

  /// 寻址
  late final addressing = NESCpuAddressing(this);

  /// 指令执行器
  late final executor = NESCpuExecutor(this);

  /// 周期计数
  int cycleCount = 0;

  NESCpu(this.emulator);

  /// 执行一次
  int execute() {
    if (emulator.logCpu) {
      logger.v('------cycles: $cycleCount------');
    }
    final beginCycleCount = cycleCount;
    final beginPc = registers.pc;
    final opCode = emulator.mapper.read(registers.pc);
    registers.pc++;
    final op = NESCpuCodes.getOP(opCode);
    if (op.op == NESOp.error) {
      logger.e('执行错误');
    }
    final address = addressing.getAddress(op.addressing);
    if (emulator.logCpu) {
      logger.d('执行: '
          '\$${beginPc.toRadixString(16).toUpperCase().padLeft(4, '0')}: '
          '${op.op.name} \$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}');
    }
    executor.execute(op, address);
    cycleCount += op.cycles;
    return cycleCount - beginCycleCount;
  }

  /// 重置
  void reset() {
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

  /// 打印错误信息
  void printError(String message) {
    logger.e('$message: '
        '${registers.pc.toRadixString(16).toUpperCase().padLeft(4, '0')}');
  }
}

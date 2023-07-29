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

/// CPU主频
class CpuClockSpeed {
  final int speed;
  final double timeUs;

  const CpuClockSpeed({required this.speed, required this.timeUs});
}

/// CPU
class NESCpu {
  /// 调试用速度
  static const clockSpeedDebug =
      CpuClockSpeed(speed: 1000, timeUs: 1000000 / 1000);

  /// PAL
  static const clockSpeedPAL =
      CpuClockSpeed(speed: 1773447, timeUs: 1000000 / 1773447);

  /// NTSC
  static const clockSpeedNTSC =
      CpuClockSpeed(speed: 1789772, timeUs: 1000000 / 1789772);

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

  /// 当前主频
  CpuClockSpeed clockSpeed = clockSpeedNTSC;

  NESCpu(this.emulator);

  /// 执行一次
  int execute() {
    if (emulator.logCpu) {
      logger.v('------cycles: $cycleCount------');
    }
    final beginCycleCount = cycleCount;
    final beginPc = registers.pc;
    final opCode = emulator.mapper.readU8(registers.pc);
    registers.pc++;
    final op = NESCpuCodes.getOP(opCode);
    if (op.op == NESOp.error) {
      logger.e('执行错误');
    }
    int address = addressing.getAddress(op.addressing);
    final differentPage = (address >> 16) & 0x01 == 1;
    address &= 0xffff;
    if (emulator.logCpu) {
      logger.d('执行: '
          '\$${beginPc.toRadixString(16).toUpperCase().padLeft(4, '0')}: '
          '${op.op.name} \$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}');
    }
    executor.execute(op, address);
    cycleCount += op.cycles;
    if (differentPage && op.otherCycles != 0) {
      cycleCount += op.otherCycles;
    }
    return cycleCount - beginCycleCount;
  }

  /// 重置
  void reset() {
    registers.reset();
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

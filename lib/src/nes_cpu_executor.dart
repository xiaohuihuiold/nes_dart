import 'logger.dart';
import 'nes_cpu_codes.dart';
import 'nes_emulator.dart';
import 'nes_cpu_registers.dart';
import 'nes_cpu.dart';
import 'nes_mapper.dart';

/// 指令执行
typedef ExecutorFun = void Function(NESOpCode, int);

/// 默认执行器
void defaultExecutor(NESOpCode op, int address) {
  if (op.op == NESOp.unk || op.op == NESOp.nop) {
    return;
  }
  throw Exception('未实现的指令: ${op.op}');
}

/// CPU执行器
class NESCpuExecutor {
  /// CPU
  final NESCpu cpu;

  /// 模拟器
  NESEmulator get emulator => cpu.emulator;

  /// 内存
  NESMapper get mapper => emulator.mapper;

  /// 寄存器
  NESCpuRegisters get registers => cpu.registers;

  /// 指令
  late final _opExecutorMapping = <NESOp, ExecutorFun>{
    NESOp.error: defaultExecutor,
    NESOp.unk: defaultExecutor,
    NESOp.lda: _executeLDA,
    NESOp.ldx: _executeLDX,
    NESOp.ldy: defaultExecutor,
    NESOp.sta: defaultExecutor,
    NESOp.stx: defaultExecutor,
    NESOp.sty: defaultExecutor,
    NESOp.adc: defaultExecutor,
    NESOp.sbc: defaultExecutor,
    NESOp.inc: defaultExecutor,
    NESOp.dec: defaultExecutor,
    NESOp.and: defaultExecutor,
    NESOp.ora: defaultExecutor,
    NESOp.era: defaultExecutor,
    NESOp.inx: defaultExecutor,
    NESOp.dex: defaultExecutor,
    NESOp.iny: defaultExecutor,
    NESOp.dey: defaultExecutor,
    NESOp.tax: defaultExecutor,
    NESOp.txa: defaultExecutor,
    NESOp.tay: defaultExecutor,
    NESOp.tya: defaultExecutor,
    NESOp.tsx: defaultExecutor,
    NESOp.txs: _executeTXS,
    NESOp.clc: defaultExecutor,
    NESOp.sec: defaultExecutor,
    NESOp.cld: _executeCLD,
    NESOp.sed: defaultExecutor,
    NESOp.clv: defaultExecutor,
    NESOp.cli: defaultExecutor,
    NESOp.sei: _executeSEI,
    NESOp.cmp: defaultExecutor,
    NESOp.cpx: defaultExecutor,
    NESOp.cpy: defaultExecutor,
    NESOp.bit: defaultExecutor,
    NESOp.asl: defaultExecutor,
    NESOp.lsr: defaultExecutor,
    NESOp.rol: defaultExecutor,
    NESOp.ror: defaultExecutor,
    NESOp.pha: defaultExecutor,
    NESOp.pla: defaultExecutor,
    NESOp.php: defaultExecutor,
    NESOp.plp: defaultExecutor,
    NESOp.jmp: defaultExecutor,
    NESOp.beq: defaultExecutor,
    NESOp.bne: defaultExecutor,
    NESOp.bcs: defaultExecutor,
    NESOp.bcc: defaultExecutor,
    NESOp.bmi: defaultExecutor,
    NESOp.bpl: _executeBPL,
    NESOp.bvs: defaultExecutor,
    NESOp.bvc: defaultExecutor,
    NESOp.jsr: defaultExecutor,
    NESOp.rts: defaultExecutor,
    NESOp.nop: defaultExecutor,
    NESOp.brk: defaultExecutor,
    NESOp.rti: defaultExecutor,
    NESOp.alr: defaultExecutor,
    NESOp.anc: defaultExecutor,
    NESOp.arr: defaultExecutor,
    NESOp.axs: defaultExecutor,
    NESOp.lax: defaultExecutor,
    NESOp.sax: defaultExecutor,
    NESOp.dcp: defaultExecutor,
    NESOp.isc: defaultExecutor,
    NESOp.rla: defaultExecutor,
    NESOp.rra: defaultExecutor,
    NESOp.slo: defaultExecutor,
    NESOp.sre: defaultExecutor,
  };

  NESCpuExecutor(this.cpu);

  /// 执行一次
  void execute(NESOpCode op, int address) {
    final executor = _opExecutorMapping[op.op];
    if (executor == null) {
      throw Exception('未实现的指令: ${op.op}');
    }
    executor(op, address);
  }

  /// TODO: 需要实现跨页周期+1
  /// 值存入寄存器X
  void _executeLDX(NESOpCode op, int address) {
    final value = mapper.readS(address);
    registers.x = value;
    registers.setStatus(NESCpuStatusRegister.s, value < 1 ? 1 : 0);
    registers.setStatus(NESCpuStatusRegister.z, value == 0 ? 1 : 0);
  }

  /// TODO: 需要实现跨页周期+1
  /// 值存入A累加器
  void _executeLDA(NESOpCode op, int address) {
    final value = mapper.readS(address);
    registers.acc = value;
    registers.setStatus(NESCpuStatusRegister.s, value < 1 ? 1 : 0);
    registers.setStatus(NESCpuStatusRegister.z, value == 0 ? 1 : 0);
  }

  /// 寄存器X值存入SP
  void _executeTXS(NESOpCode op, int address) {
    registers.sp = registers.x;
  }

  /// 清除十进制模式标志
  void _executeCLD(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.d, 0);
  }

  /// 设置中断禁止标准
  void _executeSEI(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.i, 1);
  }

  /// TODO: 需要实现跨页周期同一页+1,不同页+2
  /// 标志S=1跳转
  void _executeBPL(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.s) == 1) {
      registers.pc = address;
    }
  }
}

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
  late final _opExecutorMapping = _initMapping();

  NESCpuExecutor(this.cpu);

  List<ExecutorFun?> _initMapping() {
    final list = List<ExecutorFun?>.filled(NESOp.values.length, null);
    list[NESOp.error.index] = defaultExecutor;
    list[NESOp.unk.index] = defaultExecutor;
    list[NESOp.lda.index] = _executeLDA;
    list[NESOp.ldx.index] = _executeLDX;
    list[NESOp.ldy.index] = defaultExecutor;
    list[NESOp.sta.index] = defaultExecutor;
    list[NESOp.stx.index] = defaultExecutor;
    list[NESOp.sty.index] = defaultExecutor;
    list[NESOp.adc.index] = defaultExecutor;
    list[NESOp.sbc.index] = defaultExecutor;
    list[NESOp.inc.index] = defaultExecutor;
    list[NESOp.dec.index] = defaultExecutor;
    list[NESOp.and.index] = defaultExecutor;
    list[NESOp.ora.index] = defaultExecutor;
    list[NESOp.era.index] = defaultExecutor;
    list[NESOp.inx.index] = defaultExecutor;
    list[NESOp.dex.index] = defaultExecutor;
    list[NESOp.iny.index] = defaultExecutor;
    list[NESOp.dey.index] = defaultExecutor;
    list[NESOp.tax.index] = defaultExecutor;
    list[NESOp.txa.index] = defaultExecutor;
    list[NESOp.tay.index] = defaultExecutor;
    list[NESOp.tya.index] = defaultExecutor;
    list[NESOp.tsx.index] = defaultExecutor;
    list[NESOp.txs.index] = _executeTXS;
    list[NESOp.clc.index] = defaultExecutor;
    list[NESOp.sec.index] = defaultExecutor;
    list[NESOp.cld.index] = _executeCLD;
    list[NESOp.sed.index] = defaultExecutor;
    list[NESOp.clv.index] = defaultExecutor;
    list[NESOp.cli.index] = defaultExecutor;
    list[NESOp.sei.index] = _executeSEI;
    list[NESOp.cmp.index] = defaultExecutor;
    list[NESOp.cpx.index] = defaultExecutor;
    list[NESOp.cpy.index] = defaultExecutor;
    list[NESOp.bit.index] = defaultExecutor;
    list[NESOp.asl.index] = defaultExecutor;
    list[NESOp.lsr.index] = defaultExecutor;
    list[NESOp.rol.index] = defaultExecutor;
    list[NESOp.ror.index] = defaultExecutor;
    list[NESOp.pha.index] = defaultExecutor;
    list[NESOp.pla.index] = defaultExecutor;
    list[NESOp.php.index] = defaultExecutor;
    list[NESOp.plp.index] = defaultExecutor;
    list[NESOp.jmp.index] = defaultExecutor;
    list[NESOp.beq.index] = defaultExecutor;
    list[NESOp.bne.index] = defaultExecutor;
    list[NESOp.bcs.index] = defaultExecutor;
    list[NESOp.bcc.index] = defaultExecutor;
    list[NESOp.bmi.index] = defaultExecutor;
    list[NESOp.bpl.index] = _executeBPL;
    list[NESOp.bvs.index] = defaultExecutor;
    list[NESOp.bvc.index] = defaultExecutor;
    list[NESOp.jsr.index] = defaultExecutor;
    list[NESOp.rts.index] = defaultExecutor;
    list[NESOp.nop.index] = defaultExecutor;
    list[NESOp.brk.index] = defaultExecutor;
    list[NESOp.rti.index] = defaultExecutor;
    list[NESOp.alr.index] = defaultExecutor;
    list[NESOp.anc.index] = defaultExecutor;
    list[NESOp.arr.index] = defaultExecutor;
    list[NESOp.axs.index] = defaultExecutor;
    list[NESOp.lax.index] = defaultExecutor;
    list[NESOp.sax.index] = defaultExecutor;
    list[NESOp.dcp.index] = defaultExecutor;
    list[NESOp.isc.index] = defaultExecutor;
    list[NESOp.rla.index] = defaultExecutor;
    list[NESOp.rra.index] = defaultExecutor;
    list[NESOp.slo.index] = defaultExecutor;
    list[NESOp.sre.index] = defaultExecutor;
    return list;
  }

  /// 执行一次
  void execute(NESOpCode op, int address) {
    final executor = _opExecutorMapping[op.op.index] ?? defaultExecutor;
    executor(op, address);
  }

  /// TODO: 需要实现跨页周期+1
  /// 值存入寄存器X
  void _executeLDX(NESOpCode op, int address) {
    final value = mapper.read8(address);
    registers.x = value;
    registers.setStatus(NESCpuStatusRegister.s, value < 1 ? 1 : 0);
    registers.setStatus(NESCpuStatusRegister.z, value == 0 ? 1 : 0);
  }

  /// TODO: 需要实现跨页周期+1
  /// 值存入A累加器
  void _executeLDA(NESOpCode op, int address) {
    final value = mapper.read8(address);
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

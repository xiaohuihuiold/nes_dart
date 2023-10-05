import 'nes_cpu_codes.dart';
import 'nes_emulator.dart';
import 'nes_cpu_registers.dart';
import 'nes_cpu.dart';
import 'nes_mapper.dart';
import 'nes_cpu_addressing.dart';

/// 指令执行
typedef ExecutorFun = void Function(NESOpCode, int);

/// 默认执行器
void defaultExecutor(NESOpCode op, int address) {
  if (op.op == NESOp.unk || op.op == NESOp.nop) {
    return;
  }
  throw Exception(
      '未实现的指令: ${op.opCode.toRadixString(16).padLeft(2, '0')} ${op.op}');
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
    list[NESOp.ldy.index] = _executeLDY;
    list[NESOp.sta.index] = _executeSTA;
    list[NESOp.stx.index] = _executeSTX;
    list[NESOp.sty.index] = _executeSTY;
    list[NESOp.adc.index] = _executeADC;
    list[NESOp.sbc.index] = _executeSBC;
    list[NESOp.inc.index] = _executeINC;
    list[NESOp.dec.index] = _executeDEC;
    list[NESOp.and.index] = _executeAND;
    list[NESOp.ora.index] = _executeORA;
    list[NESOp.era.index] = _executeERA;
    list[NESOp.inx.index] = _executeINX;
    list[NESOp.dex.index] = _executeDEX;
    list[NESOp.iny.index] = _executeINY;
    list[NESOp.dey.index] = _executeDEY;
    list[NESOp.tax.index] = _executeTAX;
    list[NESOp.txa.index] = _executeTXA;
    list[NESOp.tay.index] = _executeTAY;
    list[NESOp.tya.index] = _executeTYA;
    list[NESOp.tsx.index] = _executeTSX;
    list[NESOp.txs.index] = _executeTXS;
    list[NESOp.clc.index] = _executeCLC;
    list[NESOp.sec.index] = _executeSEC;
    list[NESOp.cld.index] = _executeCLD;
    list[NESOp.sed.index] = _executeSED;
    list[NESOp.clv.index] = _executeCLV;
    list[NESOp.cli.index] = _executeCLI;
    list[NESOp.sei.index] = _executeSEI;
    list[NESOp.cmp.index] = _executeCMP;
    list[NESOp.cpx.index] = _executeCPX;
    list[NESOp.cpy.index] = _executeCPY;
    list[NESOp.bit.index] = _executeBIT;
    list[NESOp.asl.index] = _executeASL;
    list[NESOp.lsr.index] = _executeLSR;
    list[NESOp.rol.index] = _executeROL;
    list[NESOp.ror.index] = _executeROR;
    list[NESOp.pha.index] = _executePHA;
    list[NESOp.pla.index] = _executePLA;
    list[NESOp.php.index] = _executePHP;
    list[NESOp.plp.index] = _executePLP;
    list[NESOp.jmp.index] = _executeJMP;
    list[NESOp.beq.index] = _executeBEQ;
    list[NESOp.bne.index] = _executeBNE;
    list[NESOp.bcs.index] = _executeBCS;
    list[NESOp.bcc.index] = _executeBCC;
    list[NESOp.bmi.index] = _executeBMI;
    list[NESOp.bpl.index] = _executeBPL;
    list[NESOp.bvs.index] = _executeBVS;
    list[NESOp.bvc.index] = _executeBVC;
    list[NESOp.jsr.index] = _executeJSR;
    list[NESOp.rts.index] = _executeRTS;
    list[NESOp.nop.index] = defaultExecutor;
    list[NESOp.brk.index] = _executeBRK;
    list[NESOp.rti.index] = _executeRTI;
    list[NESOp.alr.index] = defaultExecutor;
    list[NESOp.anc.index] = _executeANC;
    list[NESOp.arr.index] = defaultExecutor;
    list[NESOp.axs.index] = defaultExecutor;
    list[NESOp.lax.index] = _executeLAX;
    list[NESOp.sax.index] = _executeSAX;
    list[NESOp.dcp.index] = _executeDCP;
    list[NESOp.isc.index] = _executeISC;
    list[NESOp.rla.index] = _executeRLA;
    list[NESOp.rra.index] = _executeRRA;
    list[NESOp.slo.index] = _executeSLO;
    list[NESOp.sre.index] = _executeSRE;
    return list;
  }

  /// 执行一次
  void execute(NESOpCode op, int address) {
    final executor = _opExecutorMapping[op.op.index] ?? defaultExecutor;
    executor(op, address);
  }

  /// 值存入[NESCpuRegisters.x]
  void _executeLDX(NESOpCode op, int address) {
    final value = mapper.readU8(address);
    registers.x = value;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 值存入[NESCpuRegisters.y]
  void _executeLDY(NESOpCode op, int address) {
    final value = mapper.readU8(address);
    registers.y = value;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.acc]的值写入地址
  void _executeSTA(NESOpCode op, int address) {
    mapper.writeU8(address, registers.acc);
  }

  /// 将[NESCpuRegisters.x]的值写入地址
  void _executeSTX(NESOpCode op, int address) {
    mapper.writeU8(address, registers.x);
  }

  /// 将[NESCpuRegisters.y]的值写入地址
  void _executeSTY(NESOpCode op, int address) {
    mapper.writeU8(address, registers.y);
  }

  /// 将[NESCpuRegisters.aac]与[NESCpuStatusRegister.c]和[address]的值相加
  /// 结果存入[NESCpuRegisters.aac]
  void _executeADC(NESOpCode op, int address) {
    final value = mapper.readU8(address);
    final result =
        registers.acc + registers.getStatus(NESCpuStatusRegister.c) + value;
    if (((registers.acc ^ value) & 0x80) == 0 &&
        ((registers.acc ^ result) & 0x80) != 0) {
      registers.setStatus(NESCpuStatusRegister.v, 1);
    } else {
      registers.setStatus(NESCpuStatusRegister.v, 0);
    }
    registers.acc = result;
    registers.setStatus(NESCpuStatusRegister.c, (result >> 8) == 0 ? 0 : 1);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, result & 0xFF);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, result & 0xFF);
  }

  /// 将[NESCpuRegisters.aac]减去[NESCpuStatusRegister.c]和[address]的值
  /// 结果存入[NESCpuRegisters.aac]
  void _executeSBC(NESOpCode op, int address) {
    final value = mapper.readU8(address);
    final result = registers.acc -
        value -
        (1 - registers.getStatus(NESCpuStatusRegister.c));
    if (((registers.acc ^ value) & 0x80) != 0 &&
        ((registers.acc ^ result) & 0x80) != 0) {
      registers.setStatus(NESCpuStatusRegister.v, 1);
    } else {
      registers.setStatus(NESCpuStatusRegister.v, 0);
    }
    registers.acc = result;
    registers.setStatus(NESCpuStatusRegister.c, (result >> 8) == 0 ? 1 : 0);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, result);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, result);
  }

  /// [address]的值+1
  void _executeINC(NESOpCode op, int address) {
    final value = mapper.readU8(address) + 1;
    mapper.writeU8(address, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value & 0xFF);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value & 0xFF);
  }

  /// [address]的值-1
  void _executeDEC(NESOpCode op, int address) {
    final value = mapper.readU8(address) - 1;
    mapper.writeU8(address, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [address]的值与[NESCpuRegisters.aac]进行与运算
  void _executeAND(NESOpCode op, int address) {
    registers.acc &= mapper.readU8(address);
    final value = registers.acc;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [address]的值与[NESCpuRegisters.aac]进行或运算
  void _executeORA(NESOpCode op, int address) {
    registers.acc |= mapper.readU8(address);
    final value = registers.acc;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [address]的值与[NESCpuRegisters.aac]进行异或运算
  void _executeERA(NESOpCode op, int address) {
    registers.acc ^= mapper.readU8(address);
    final value = registers.acc;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.x]的值+1
  void _executeINX(NESOpCode op, int address) {
    registers.x++;
    final value = registers.x;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.x]的值-1
  void _executeDEX(NESOpCode op, int address) {
    registers.x--;
    final value = registers.x;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.y]的值+1
  void _executeINY(NESOpCode op, int address) {
    registers.y++;
    final value = registers.y;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.y]的值-1
  void _executeDEY(NESOpCode op, int address) {
    registers.y--;
    final value = registers.y;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.acc]的值放入[NESCpuRegisters.x]
  void _executeTAX(NESOpCode op, int address) {
    registers.x = registers.acc;
    final value = registers.x;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.x]的值放入[NESCpuRegisters.acc]
  void _executeTXA(NESOpCode op, int address) {
    registers.acc = registers.x;
    final value = registers.acc;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.acc]的值放入[NESCpuRegisters.y]
  void _executeTAY(NESOpCode op, int address) {
    registers.y = registers.acc;
    final value = registers.y;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 将[NESCpuRegisters.y]的值放入[NESCpuRegisters.acc]
  void _executeTYA(NESOpCode op, int address) {
    registers.acc = registers.y;
    final value = registers.acc;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 值存入[NESCpuRegisters.acc]
  void _executeLDA(NESOpCode op, int address) {
    final value = mapper.readU8(address);
    registers.acc = value;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [NESCpuRegisters.sp]的值存入[NESCpuRegisters.x]
  void _executeTSX(NESOpCode op, int address) {
    registers.x = registers.sp;
    final value = registers.x;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [NESCpuRegisters.x]的值存入[NESCpuRegisters.sp]
  void _executeTXS(NESOpCode op, int address) {
    registers.sp = registers.x;
  }

  /// 清除[NESCpuStatusRegister.c]
  void _executeCLC(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.c, 0);
  }

  /// 设置[NESCpuStatusRegister.c]
  void _executeSEC(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.c, 1);
  }

  /// 清除十进制模式[NESCpuStatusRegister.d]标志
  void _executeCLD(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.d, 0);
  }

  /// 设置十进制模式[NESCpuStatusRegister.d]标志
  void _executeSED(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.d, 1);
  }

  /// 清除[NESCpuStatusRegister.v]标志
  void _executeCLV(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.v, 0);
  }

  /// 清除[NESCpuStatusRegister.i]标志
  void _executeCLI(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.i, 0);
  }

  /// 设置中断[NESCpuStatusRegister.i]禁止
  void _executeSEI(NESOpCode op, int address) {
    registers.setStatus(NESCpuStatusRegister.i, 1);
  }

  /// 比较[address]的值与[NESCpuRegisters.acc]
  void _executeCMP(NESOpCode op, int address) {
    final value = registers.acc - mapper.readU8(address);
    registers.setStatus(NESCpuStatusRegister.c, (value & 0x8000) == 0 ? 1 : 0);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 比较[address]的值与[NESCpuRegisters.x]
  void _executeCPX(NESOpCode op, int address) {
    final value = registers.x - mapper.readU8(address);
    registers.setStatus(NESCpuStatusRegister.c, (value & 0x8000) == 0 ? 1 : 0);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// 比较[address]的值与[NESCpuRegisters.y]
  void _executeCPY(NESOpCode op, int address) {
    final value = registers.y - mapper.readU8(address);
    registers.setStatus(NESCpuStatusRegister.c, (value & 0x8000) == 0 ? 1 : 0);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [NESCpuRegisters.acc]&[address]==0时[NESCpuStatusRegister.z]=1,否则[NESCpuStatusRegister.z]=0
  /// 且[NESCpuStatusRegister.s]=[address]值的第七位
  /// [NESCpuStatusRegister.v]=[address]值的第六位
  void _executeBIT(NESOpCode op, int address) {
    final value = mapper.readU8(address);
    registers.setStatus(NESCpuStatusRegister.v, value & (1 << 6) == 0 ? 0 : 1);
    registers.setStatus(NESCpuStatusRegister.s, value & (1 << 7) == 0 ? 0 : 1);
    registers.setStatus(
        NESCpuStatusRegister.z, registers.acc & value == 0 ? 1 : 0);
  }

  /// [NESCpuRegisters.acc]或者[address]按位左移一位
  void _executeASL(NESOpCode op, int address) {
    if (op.addressing == NESAddressing.accumulator) {
      registers.setStatus(
          NESCpuStatusRegister.c, registers.acc & 0x80 == 0 ? 0 : 1);
      registers.acc <<= 1;
      final value = registers.acc;
      registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
    } else {
      int value = mapper.readU8(address);
      registers.setStatus(NESCpuStatusRegister.c, value & 0x80 == 0 ? 0 : 1);
      value <<= 1;
      mapper.writeU8(address, value);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
    }
  }

  /// [NESCpuRegisters.acc]或者[address]按位右移一位
  void _executeLSR(NESOpCode op, int address) {
    if (op.addressing == NESAddressing.accumulator) {
      registers.setStatus(NESCpuStatusRegister.c, registers.acc & 1);
      registers.acc >>= 1;
      final value = registers.acc;
      registers.setStatus(NESCpuStatusRegister.s, 0);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
    } else {
      int value = mapper.readU8(address);
      registers.setStatus(NESCpuStatusRegister.c, value & 1);
      value >>= 1;
      mapper.writeU8(address, value);
      registers.setStatus(NESCpuStatusRegister.s, 0);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
    }
  }

  /// [NESCpuRegisters.acc]或者[address]按位循环左移一位
  void _executeROL(NESOpCode op, int address) {
    if (op.addressing == NESAddressing.accumulator) {
      int value = registers.acc;
      value <<= 1;
      value |= registers.getStatus(NESCpuStatusRegister.c);
      registers.setStatus(NESCpuStatusRegister.c, (value & 0x100) == 0 ? 0 : 1);
      registers.acc = value;
      registers.checkAndUpdateStatus(NESCpuStatusRegister.s, registers.acc);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, registers.acc);
    } else {
      int value = mapper.readU16(address);
      value <<= 1;
      value |= registers.getStatus(NESCpuStatusRegister.c);
      registers.setStatus(NESCpuStatusRegister.c, (value & 0x100) == 0 ? 0 : 1);
      mapper.writeU8(address, value);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
    }
  }

  /// [NESCpuRegisters.acc]或者[address]按位循环右移一位
  void _executeROR(NESOpCode op, int address) {
    if (op.addressing == NESAddressing.accumulator) {
      int value = registers.acc;
      value |= registers.getStatus(NESCpuStatusRegister.c) << 8;
      registers.setStatus(NESCpuStatusRegister.c, value & 1);
      value >>= 1;
      registers.acc = value;
      registers.checkAndUpdateStatus(NESCpuStatusRegister.s, registers.acc);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, registers.acc);
    } else {
      int value = mapper.readU16(address);
      value |= registers.getStatus(NESCpuStatusRegister.c) << 8;
      registers.setStatus(NESCpuStatusRegister.c, value & 1);
      value >>= 1;
      mapper.writeU8(address, value);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
      registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
    }
  }

  /// [NESCpuRegisters.acc]压入栈
  void _executePHA(NESOpCode op, int address) {
    cpu.push(registers.acc);
  }

  /// [NESCpuRegisters.acc]出栈
  void _executePLA(NESOpCode op, int address) {
    registers.acc = cpu.pop();
    final value = registers.acc;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [NESCpuRegisters.status]入栈
  void _executePHP(NESOpCode op, int address) {
    cpu.push(registers.status);
  }

  /// [NESCpuRegisters.status]出栈
  void _executePLP(NESOpCode op, int address) {
    registers.status = cpu.pop();
    registers.setStatus(NESCpuStatusRegister.r, 1);
    registers.setStatus(NESCpuStatusRegister.b, 0);
  }

  /// 跳转
  void _executeJMP(NESOpCode op, int address) {
    registers.pc = address;
  }

  /// 标志[NESCpuStatusRegister.z]==1跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBEQ(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.z) == 1) {
      registers.pc = address;
    }
  }

  /// 标志[NESCpuStatusRegister.z]==0跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBNE(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.z) == 0) {
      registers.pc = address;
    }
  }

  /// 标志[NESCpuStatusRegister.c]==1跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBCS(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.c) == 1) {
      registers.pc = address;
    }
  }

  /// 标志[NESCpuStatusRegister.c]==0跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBCC(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.c) == 0) {
      registers.pc = address;
    }
  }

  /// 标志[NESCpuStatusRegister.s]==1跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBMI(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.s) == 1) {
      registers.pc = address;
    }
  }

  /// 标志[NESCpuStatusRegister.s]==0跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBPL(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.s) == 0) {
      registers.pc = address;
    }
  }

  /// 标志[NESCpuStatusRegister.v]==1跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBVS(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.v) == 1) {
      registers.pc = address;
    }
  }

  /// 标志[NESCpuStatusRegister.v]==0跳转
  /// TODO: 时钟周期同一页面+1,不同页面+2
  void _executeBVC(NESOpCode op, int address) {
    if (registers.getStatus(NESCpuStatusRegister.v) == 0) {
      registers.pc = address;
    }
  }

  /// 跳转至子程序,记录当前地址
  void _executeJSR(NESOpCode op, int address) {
    final pc = registers.pc - 1;
    cpu.push(pc >> 8);
    cpu.push(pc);
    registers.pc = address;
  }

  /// 从子程序返回
  void _executeRTS(NESOpCode op, int address) {
    final pcL = cpu.pop();
    final pcH = cpu.pop();
    registers.pc = pcL | (pcH << 8);
    registers.pc++;
  }

  /// 强制中断
  void _executeBRK(NESOpCode op, int address) {
    final pcP1 = registers.pc + 1;
    final pcH = (pcP1 >> 8) & 0xFF;
    final pcL = pcP1 & 0xFF;
    cpu.push(pcH);
    cpu.push(pcL);
    cpu.push(registers.status |
        NESCpuStatusRegister.r.bit |
        NESCpuStatusRegister.b.bit);
    registers.setStatus(NESCpuStatusRegister.i, 1);
    final pcL2 = emulator.mapper
        .readU8(emulator.mapper.readInterruptAddress(NESCpuInterrupt.irq) + 0);
    final pcH2 = emulator.mapper
        .readU8(emulator.mapper.readInterruptAddress(NESCpuInterrupt.irq) + 1);
    registers.pc = pcL2 | (pcH2 << 8);
  }

  /// 从中断返回
  void _executeRTI(NESOpCode op, int address) {
    registers.status = cpu.pop();
    registers.setStatus(NESCpuStatusRegister.r, 1);
    registers.setStatus(NESCpuStatusRegister.b, 0);

    final pcL = cpu.pop();
    final pcH = cpu.pop();
    registers.pc = pcL | (pcH << 8);
  }

  /// 与[NESCpuRegisters.acc],设置[NESCpuStatusRegister.c]到第七位
  void _executeANC(NESOpCode op, int address) {
    registers.acc &= mapper.readU8(address);
    final value = registers.acc;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
    registers.setStatus(NESCpuStatusRegister.c,
        registers.getStatus(NESCpuStatusRegister.s) == 0 ? 0 : 1);
  }

  /// [address]的值加载到[NESCpuRegisters.acc]和[NESCpuRegisters.x]
  void _executeLAX(NESOpCode op, int address) {
    final value = mapper.readU8(address);
    registers.acc = value;
    registers.x = value;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, value);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, value);
  }

  /// [NESCpuRegisters.acc]和[NESCpuRegisters.x]写入[address]
  void _executeSAX(NESOpCode op, int address) {
    mapper.writeU8(address, registers.acc & registers.x);
  }

  /// [address]的值-1与[NESCpuRegisters.acc]比较
  void _executeDCP(NESOpCode op, int address) {
    int value = mapper.readU8(address);
    value--;
    mapper.writeU8(address, value);
    int result = registers.acc - value;
    registers.setStatus(NESCpuStatusRegister.c, (result & 0x8000) == 0 ? 1 : 0);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, result);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, result);
  }

  /// [address]的值+1与[NESCpuRegisters.acc]相减
  void _executeISC(NESOpCode op, int address) {
    int value = mapper.readU8(address);
    value++;
    mapper.writeU8(address, value);

    final result =
        registers.acc - registers.getStatus(NESCpuStatusRegister.c) - value;
    registers.setStatus(NESCpuStatusRegister.c, result < 0 ? 0 : 1);
    if (((registers.acc ^ value) & 0x80) != 0 &&
        ((registers.acc ^ result) & 0x80) != 0) {
      registers.setStatus(NESCpuStatusRegister.v, 1);
    } else {
      registers.setStatus(NESCpuStatusRegister.v, 0);
    }
    registers.acc = result;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, result);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, result);
  }

  /// [address]的值循环左移一位和[NESCpuRegisters.acc]以及进位标记相与
  void _executeRLA(NESOpCode op, int address) {
    // ROL
    int value = mapper.readU8(address);
    final old = registers.getStatus(NESCpuStatusRegister.c);
    registers.setStatus(NESCpuStatusRegister.c, (value & 0x100) == 0 ? 0 : 1);
    value = ((value << 1) & 0xFF) + old;
    mapper.writeU8(address, value);

    // AND
    registers.acc &= value;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, registers.acc);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, registers.acc);
  }

  /// [address]的值循环右移一位和[NESCpuRegisters.acc]以及进位标记相加
  void _executeRRA(NESOpCode op, int address) {
    // ROR
    final old = registers.getStatus(NESCpuStatusRegister.c) << 7;
    registers.setStatus(NESCpuStatusRegister.c, registers.acc & 1);
    int value = (registers.acc >> 1) + old;
    mapper.writeU8(address, value);

    // ADC
    final result =
        registers.acc + registers.getStatus(NESCpuStatusRegister.c) + value;
    if (((registers.acc ^ value) & 0x80) == 0 &&
        ((registers.acc ^ result) & 0x80) != 0) {
      registers.setStatus(NESCpuStatusRegister.v, 1);
    } else {
      registers.setStatus(NESCpuStatusRegister.v, 0);
    }
    registers.acc = result;
    registers.setStatus(NESCpuStatusRegister.c, (result >> 8) == 0 ? 0 : 1);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, result);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, result);
  }

  /// [address]的值左移一位和[NESCpuRegisters.acc]或运算
  void _executeSLO(NESOpCode op, int address) {
    // ASL
    int value = mapper.readU8(address);
    registers.setStatus(NESCpuStatusRegister.c, (value & 0x80) == 0 ? 0 : 1);
    value <<= 1;
    mapper.writeU8(address, value);

    // ORA
    registers.acc |= value;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, registers.acc);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, registers.acc);
  }

  /// [address]的值左移一位和[NESCpuRegisters.acc]或运算
  void _executeSRE(NESOpCode op, int address) {
    // LSR
    int value = mapper.readU8(address);
    registers.setStatus(NESCpuStatusRegister.c, value & 1);
    value >>= 1;
    mapper.writeU8(address, value);

    // EOR
    registers.acc |= value;
    registers.checkAndUpdateStatus(NESCpuStatusRegister.s, registers.acc);
    registers.checkAndUpdateStatus(NESCpuStatusRegister.z, registers.acc);
  }
}

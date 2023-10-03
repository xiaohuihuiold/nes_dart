import 'nes_cpu.dart';
import 'nes_emulator.dart';
import 'nes_cpu_registers.dart';

/// 寻址模式
enum NESAddressing {
  /// 未知
  unknown,

  /// 累加器寻址
  accumulator,

  /// 隐含寻址
  implied,

  /// 立即寻址
  immediate,

  /// 绝对寻址
  absolute,

  /// 零页寻址
  zeroPage,

  /// 绝对X变址
  absoluteX,

  /// 绝对Y变址
  absoluteY,

  /// 零页X变址
  zeroPageX,

  /// 零页Y变址
  zeroPageY,

  /// 间接寻址,JMP ($xxFF)会有问题
  indirect,

  /// 间接X变址
  indirectX,

  /// 间接Y变址
  indirectY,

  /// 相对寻址
  relative,
}

/// 寻址
typedef AddressingCallback = int Function();

/// 寻址
class NESCpuAddressing {
  /// CPU
  final NESCpu cpu;

  /// 模拟器
  NESEmulator get emulator => cpu.emulator;

  /// 寄存器
  NESCpuRegisters get registers => cpu.registers;

  /// 寻址模式
  late final _addressingMapping = _initMapping();

  NESCpuAddressing(this.cpu);

  List<AddressingCallback?> _initMapping() {
    final list =
        List<AddressingCallback?>.filled(NESAddressing.values.length, null);
    list[NESAddressing.accumulator.index] = _addressingAccumulator;
    list[NESAddressing.implied.index] = _addressingImplied;
    list[NESAddressing.immediate.index] = _addressingImmediate;
    list[NESAddressing.absolute.index] = _addressingAbsolute;
    list[NESAddressing.zeroPage.index] = _addressingZeroPage;
    list[NESAddressing.absoluteX.index] = _addressingAbsoluteX;
    list[NESAddressing.absoluteY.index] = _addressingAbsoluteY;
    list[NESAddressing.zeroPageX.index] = _addressingZeroPageX;
    list[NESAddressing.zeroPageY.index] = _addressingZeroPageY;
    list[NESAddressing.indirect.index] = _addressingIndirect;
    list[NESAddressing.indirectX.index] = _addressingIndirectX;
    list[NESAddressing.indirectY.index] = _addressingIndirectY;
    list[NESAddressing.relative.index] = _addressingRelative;
    return list;
  }

  /// 寻址
  /// 第17位表示是否跨页
  int getAddress(NESAddressing mode) {
    return (_addressingMapping[mode.index]?.call() ?? 0) & 0x1FFFF;
  }

  /// 地址是否跨页
  bool isDifferentPage(int a, int b) {
    return (a & 0xff00) != (b & 0xff00);
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

  /// 地址是当前PC位置的值,16位
  int _addressingAbsolute() {
    final address = emulator.mapper.readU16(registers.pc);
    registers.pc += 2;
    return address;
  }

  /// 地址是当前PC位置的值,8位
  int _addressingZeroPage() {
    final address = emulator.mapper.readU8(registers.pc);
    registers.pc++;
    return address;
  }

  /// PC位置的值加上X变址寄存器的值
  int _addressingAbsoluteX() {
    int cycles = 0;
    int address = emulator.mapper.read16(registers.pc);
    if (isDifferentPage(address, address + registers.x)) {
      cycles = 1;
    }
    address += registers.x;
    registers.pc += 2;
    return address | (cycles << 16);
  }

  /// PC位置的值加上Y变址寄存器的值
  int _addressingAbsoluteY() {
    int cycles = 0;
    int address = emulator.mapper.read16(registers.pc);
    if (isDifferentPage(address, address + registers.y)) {
      cycles = 1;
    }
    address += registers.y;
    registers.pc += 2;
    return address | (cycles << 16);
  }

  /// PC的8位值加上X变址寄存器的值,并取前8位
  int _addressingZeroPageX() {
    final address = (registers.x + emulator.mapper.read8(registers.pc)) & 0xFF;
    registers.pc++;
    return address;
  }

  /// PC的8位值加上Y变址寄存器的值,并取前8位
  int _addressingZeroPageY() {
    final address = (registers.y + emulator.mapper.read8(registers.pc)) & 0xFF;
    registers.pc++;
    return address;
  }

  /// 16位,读取PC位置的值指向的地址值作为地址
  /// 当地址是$xxFF时,PC位置的下一个地址把FF变成00
  int _addressingIndirect() {
    final temp = emulator.mapper.readU16(registers.pc);
    registers.pc += 2;
    if (temp & 0xFF == 0xFF) {
      // 实现$xxFF
      return emulator.mapper.readU8(temp) |
          (emulator.mapper.readU8(temp & 0xFF00) << 8);
    } else {
      return emulator.mapper.readU16(temp);
    }
  }

  /// PC的值与X变址寄存器相加得到新的地址
  /// 新的地址读取两个字节作为新的地址
  int _addressingIndirectX() {
    int cycles = 0;
    int address = emulator.mapper.read8(registers.pc);
    if (isDifferentPage(address, address + registers.x)) {
      cycles = 1;
    }
    address += registers.x;
    address &= 0xff;
    address = emulator.mapper.readU16(address);
    registers.pc++;
    return address | (cycles << 16);
  }

  /// PC的值作为地址,并读取地址的值与Y变址寄存器相加
  int _addressingIndirectY() {
    int cycles = 0;
    int address = emulator.mapper.readU8(registers.pc);
    address = emulator.mapper.readU16(address);
    if (isDifferentPage(address, address + registers.y)) {
      cycles = 1;
    }
    address += registers.y;
    registers.pc++;
    return address | (cycles << 16);
  }

  /// PC加上当前地址值偏移
  int _addressingRelative() {
    final address = emulator.mapper.read8(registers.pc) + registers.pc + 1;
    registers.pc++;
    return address;
  }
}

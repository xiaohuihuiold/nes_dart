/// 寻址模式
enum NESAddressing {
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

/// 指令
enum NESOp {
  /// 加载到A累加器
  lda('LDA'),

  /// 加载到X变址寄存器
  ldx('LDX'),

  /// 加载到Y变址寄存器
  ldy('LDY'),

  /// 将A累加器的值存入
  sta('STA');

  final String name;

  const NESOp(this.name);
}

/// 指令
class NESOpCode {
  /// 指令代码
  final int opCode;

  /// 指令字节
  final int size;

  /// 指令
  final NESOp op;

  /// 寻址模式
  final NESAddressing addressing;

  /// 指令周期
  final int cycles;

  /// 额外指令周期
  final int extraCycles;

  NESOpCode(this.opCode, this.size, this.op, this.addressing, this.cycles,
      this.extraCycles);
}

/// 指令映射
final nesCpuCodeMapping = {for (final code in nesCpuCodes) code.opCode: code};

/// 指令
final nesCpuCodes = [
  /// LDA
  NESOpCode(0xA9, 2, NESOp.lda, NESAddressing.immediate, 2, 0),
  NESOpCode(0xA5, 2, NESOp.lda, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xB5, 2, NESOp.lda, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0xAD, 3, NESOp.lda, NESAddressing.absolute, 4, 0),
  NESOpCode(0xBD, 3, NESOp.lda, NESAddressing.absoluteX, 4, 1),
  NESOpCode(0xB9, 3, NESOp.lda, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0xA1, 2, NESOp.lda, NESAddressing.indirectX, 6, 0),
  NESOpCode(0xB1, 2, NESOp.lda, NESAddressing.indirectY, 5, 1),

  /// LDX
  NESOpCode(0xA2, 2, NESOp.ldx, NESAddressing.immediate, 2, 0),
  NESOpCode(0xA6, 2, NESOp.ldx, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xB6, 2, NESOp.ldx, NESAddressing.zeroPageY, 4, 0),
  NESOpCode(0xAE, 3, NESOp.ldx, NESAddressing.absolute, 4, 0),
  NESOpCode(0xBE, 3, NESOp.ldx, NESAddressing.absoluteY, 4, 1),

  /// LDY
  NESOpCode(0xA2, 2, NESOp.ldy, NESAddressing.immediate, 2, 0),
  NESOpCode(0xA2, 2, NESOp.ldy, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xA2, 2, NESOp.ldy, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0xA2, 3, NESOp.ldy, NESAddressing.absolute, 4, 0),
  NESOpCode(0xA2, 3, NESOp.ldy, NESAddressing.absoluteX, 4, 1),

  /// STA
  NESOpCode(0x85, 2, NESOp.sta, NESAddressing.immediate, 3, 0),
  NESOpCode(0x95, 2, NESOp.sta, NESAddressing.immediate, 4, 0),
  NESOpCode(0x80, 3, NESOp.sta, NESAddressing.immediate, 4, 0),
  NESOpCode(0x90, 3, NESOp.sta, NESAddressing.immediate, 5, 0),
  NESOpCode(0x99, 3, NESOp.sta, NESAddressing.immediate, 5, 0),
  NESOpCode(0x81, 2, NESOp.sta, NESAddressing.immediate, 6, 0),
  NESOpCode(0x91, 2, NESOp.sta, NESAddressing.immediate, 6, 0),
];

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
  sta('STA'),

  /// 将X变址寄存器的值存入
  stx('STX'),

  /// 将Y变址寄存器的值存入
  sty('STY'),

  /// 累加器,地址值,进位标志C相加结果存入累加器A
  adc('ADC'),

  /// 从累加器A减去存储值和进位标志C结果送入累加器A
  sbc('SBC'),

  /// 值加1
  inc('INC'),

  /// 值减1
  dec('DEC'),

  /// 值与累加器做与运算,结果放入累加器A
  and('AND'),

  /// 值与累加器做或运算,结果放入累加器A
  ora('ORA'),

  /// 值与累加器做异或运算,结果放入累加器A
  era('ERA');

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
  NESOpCode(0x85, 2, NESOp.sta, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x95, 2, NESOp.sta, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0x80, 3, NESOp.sta, NESAddressing.absolute, 4, 0),
  NESOpCode(0x90, 3, NESOp.sta, NESAddressing.absoluteX, 5, 0),
  NESOpCode(0x99, 3, NESOp.sta, NESAddressing.absoluteY, 5, 0),
  NESOpCode(0x81, 2, NESOp.sta, NESAddressing.indirectX, 6, 0),
  NESOpCode(0x91, 2, NESOp.sta, NESAddressing.indirectY, 6, 0),

  /// STX
  NESOpCode(0x86, 2, NESOp.stx, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x96, 2, NESOp.stx, NESAddressing.zeroPageY, 4, 0),
  NESOpCode(0x8E, 3, NESOp.stx, NESAddressing.absolute, 4, 0),

  /// STY
  NESOpCode(0x84, 2, NESOp.sty, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x94, 2, NESOp.sty, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0x8C, 3, NESOp.sty, NESAddressing.absolute, 4, 0),

  /// ADC
  NESOpCode(0x69, 2, NESOp.adc, NESAddressing.immediate, 2, 0),
  NESOpCode(0x65, 2, NESOp.adc, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x75, 2, NESOp.adc, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0x60, 3, NESOp.adc, NESAddressing.absolute, 4, 0),
  NESOpCode(0x70, 3, NESOp.adc, NESAddressing.absoluteX, 4, 1),
  NESOpCode(0x79, 3, NESOp.adc, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0x61, 2, NESOp.adc, NESAddressing.indirectX, 6, 0),
  NESOpCode(0x71, 2, NESOp.adc, NESAddressing.indirectY, 5, 1),

  /// SBC
  NESOpCode(0xE9, 2, NESOp.sbc, NESAddressing.immediate, 2, 0),
  NESOpCode(0xE5, 2, NESOp.sbc, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xF5, 2, NESOp.sbc, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0xED, 3, NESOp.sbc, NESAddressing.absolute, 4, 0),
  NESOpCode(0xFD, 3, NESOp.sbc, NESAddressing.absoluteX, 4, 1),
  NESOpCode(0xF9, 3, NESOp.sbc, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0xE1, 2, NESOp.sbc, NESAddressing.indirectX, 6, 0),
  NESOpCode(0xF1, 2, NESOp.sbc, NESAddressing.indirectY, 5, 0),

  /// INC
  NESOpCode(0xE6, 2, NESOp.inc, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0xF6, 2, NESOp.inc, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0xEE, 3, NESOp.inc, NESAddressing.absolute, 6, 0),
  NESOpCode(0xFE, 3, NESOp.inc, NESAddressing.absoluteX, 7, 0),

  /// DEC
  NESOpCode(0xC6, 2, NESOp.dec, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0xD6, 2, NESOp.dec, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0xCE, 3, NESOp.dec, NESAddressing.absolute, 6, 0),
  NESOpCode(0xDE, 3, NESOp.dec, NESAddressing.absoluteX, 7, 0),

  /// AND
  NESOpCode(0x29, 2, NESOp.and, NESAddressing.immediate, 2, 0),
  NESOpCode(0x25, 2, NESOp.and, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x35, 2, NESOp.and, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0x2D, 3, NESOp.and, NESAddressing.absolute, 4, 0),
  NESOpCode(0x3D, 3, NESOp.and, NESAddressing.absoluteX, 4, 1),
  NESOpCode(0x39, 3, NESOp.and, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0x21, 2, NESOp.and, NESAddressing.indirectX, 6, 0),
  NESOpCode(0x31, 2, NESOp.and, NESAddressing.indirectY, 5, 0),

  /// ORA
  NESOpCode(0x09, 2, NESOp.ora, NESAddressing.immediate, 2, 0),
  NESOpCode(0x05, 2, NESOp.ora, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x15, 2, NESOp.ora, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0x0D, 3, NESOp.ora, NESAddressing.absolute, 4, 0),
  NESOpCode(0x10, 3, NESOp.ora, NESAddressing.absoluteX, 4, 1),
  NESOpCode(0x19, 3, NESOp.ora, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0x01, 2, NESOp.ora, NESAddressing.indirectX, 6, 0),
  NESOpCode(0x11, 2, NESOp.ora, NESAddressing.indirectY, 5, 0),

  /// ERA
  NESOpCode(0x49, 2, NESOp.era, NESAddressing.immediate, 2, 0),
  NESOpCode(0x45, 2, NESOp.era, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x55, 2, NESOp.era, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0x40, 3, NESOp.era, NESAddressing.absolute, 4, 0),
  NESOpCode(0x50, 3, NESOp.era, NESAddressing.absoluteX, 4, 1),
  NESOpCode(0x59, 3, NESOp.era, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0x41, 2, NESOp.era, NESAddressing.indirectX, 6, 0),
  NESOpCode(0x51, 2, NESOp.era, NESAddressing.indirectY, 5, 1),
];

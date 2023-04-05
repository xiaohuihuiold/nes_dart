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
  era('ERA'),

  /// X变址寄存器加1
  inx('INX'),

  /// X变址寄存器减1
  dex('DEX'),

  /// Y变址寄存器加1
  iny('INY'),

  /// Y变址寄存器减1
  dey('DEY'),

  /// 累加器A的内容存入变址寄存器X
  tax('TAX'),

  /// 变址寄存器X的内容存入累加器A
  txa('TXA'),

  /// 累加器A的内容存入变址寄存器Y
  tay('TAY'),

  /// 变址寄存器Y的内容存入累加器A
  tya('TYA'),

  /// 将SP存入X
  tsx('TSX'),

  /// 将X存入SP
  txs('TXS'),

  /// C标志设置为0
  clc('CLC'),

  /// C标志设置为1
  sec('SEC'),

  /// D标志设置为0
  cld('CLD'),

  /// D标志设置为1
  sed('SED'),

  /// V标志设置为0
  clv('CLV'),

  /// I标志设置为0
  cli('CLI'),

  /// I标志设置为1
  sei('SEI'),

  /// 比较地址值与A
  cmp('CMP'),

  /// 比较地址值与X
  cpx('CPX'),

  /// 比较地址值与Y
  cpy('CPY'),

  /// 位测试,与A
  bit('BIT'),

  /// 左位移
  asl('ASL'),

  /// 右位移
  lsr('LSR'),

  /// 循环左位移
  rol('ROL'),

  /// 循环右位移
  ror('ROR'),

  /// A压入栈顶
  pha('PHA'),

  /// A移出栈顶
  pla('PLA'),

  /// 状态压入栈顶
  php('PHP'),

  /// 状态移出栈顶
  plp('PLP'),

  /// 跳转
  jmp('JMP'),

  /// Z等于1跳转
  beq('BEQ'),

  /// Z等于0跳转
  bne('BNE'),

  /// C等于1跳转
  bcs('BCS'),

  /// C等于0跳转
  bcc('BCC'),

  /// S等于1跳转
  bmi('BMI'),

  /// S等于0跳转
  bpl('BPL'),

  /// V等于1跳转
  bvs('BVS'),

  /// V等于0跳转
  bvc('BVC'),

  /// 跳转子程序
  jsr('JSR'),

  /// 从子程序返回
  rts('RTS'),

  /// 无操作
  nop('NOP'),

  /// 强制中断
  brk('BRK'),

  /// 从中断返回
  rti('RTI'),

  /// ----------扩展指令----------
  /// AND+LSR
  alr('ALR'),

  /// AND后复制S到C
  anc('ANC'),

  /// AND+ROR
  arr('ARR'),

  /// A AND X然后减去地址的值放入X
  axs('AXS'),

  /// 地址值放入A再放入X
  lax('LAX'),

  /// 地址放入A AND X
  sax('SAX'),

  /// **nop**
  dcp('DCP'),

  /// **nop**
  isc('ISC'),

  /// **nop**
  rla('RLA'),

  /// **nop**
  rra('RRA'),

  /// **nop**
  slo('SLO'),

  /// **nop**
  sre('SRE');

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

  /// INX
  NESOpCode(0xE8, 1, NESOp.inx, NESAddressing.implied, 2, 0),

  /// DEX
  NESOpCode(0xCA, 1, NESOp.dex, NESAddressing.implied, 2, 0),

  /// INY
  NESOpCode(0xC8, 1, NESOp.iny, NESAddressing.implied, 2, 0),

  /// DEY
  NESOpCode(0x88, 1, NESOp.dey, NESAddressing.implied, 2, 0),

  /// TAX
  NESOpCode(0xAA, 1, NESOp.tax, NESAddressing.implied, 2, 0),

  /// TXA
  NESOpCode(0x8A, 1, NESOp.txa, NESAddressing.implied, 2, 0),

  /// TAY
  NESOpCode(0xA8, 1, NESOp.tay, NESAddressing.implied, 2, 0),

  /// TYA
  NESOpCode(0x98, 1, NESOp.tya, NESAddressing.implied, 2, 0),

  /// TSX
  NESOpCode(0xBA, 1, NESOp.tsx, NESAddressing.implied, 2, 0),

  /// TXS
  NESOpCode(0x9A, 1, NESOp.txs, NESAddressing.implied, 2, 0),

  /// CLC
  NESOpCode(0x18, 1, NESOp.clc, NESAddressing.implied, 2, 0),

  /// SEC
  NESOpCode(0x38, 1, NESOp.sec, NESAddressing.implied, 2, 0),

  /// CLD
  NESOpCode(0xD8, 1, NESOp.cld, NESAddressing.implied, 2, 0),

  /// SED
  NESOpCode(0xF8, 1, NESOp.sed, NESAddressing.implied, 2, 0),

  /// CLV
  NESOpCode(0xB8, 1, NESOp.clv, NESAddressing.implied, 2, 0),

  /// CLI
  NESOpCode(0x58, 1, NESOp.cli, NESAddressing.implied, 2, 0),

  /// SEI
  NESOpCode(0x78, 1, NESOp.sei, NESAddressing.implied, 2, 0),

  /// CMP
  NESOpCode(0xC9, 2, NESOp.cmp, NESAddressing.immediate, 2, 0),
  NESOpCode(0xC5, 2, NESOp.cmp, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xD5, 2, NESOp.cmp, NESAddressing.zeroPageX, 4, 0),
  NESOpCode(0xCD, 3, NESOp.cmp, NESAddressing.absolute, 4, 0),
  NESOpCode(0xDD, 3, NESOp.cmp, NESAddressing.absoluteX, 4, 1),
  NESOpCode(0xD9, 3, NESOp.cmp, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0xC1, 2, NESOp.cmp, NESAddressing.indirectX, 6, 0),
  NESOpCode(0xD1, 2, NESOp.cmp, NESAddressing.indirectY, 5, 1),

  /// CPX
  NESOpCode(0xE0, 2, NESOp.cpx, NESAddressing.immediate, 2, 0),
  NESOpCode(0xE4, 2, NESOp.cpx, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xEC, 3, NESOp.cpx, NESAddressing.absolute, 4, 0),

  /// CPY
  NESOpCode(0xC0, 2, NESOp.cpy, NESAddressing.immediate, 2, 0),
  NESOpCode(0xC4, 2, NESOp.cpy, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xCC, 3, NESOp.cpy, NESAddressing.absolute, 4, 0),

  /// BIT
  NESOpCode(0x24, 2, NESOp.bit, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0x2C, 3, NESOp.bit, NESAddressing.absolute, 4, 0),

  /// ASL
  NESOpCode(0x0A, 1, NESOp.asl, NESAddressing.accumulator, 2, 0),
  NESOpCode(0x06, 2, NESOp.asl, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x16, 2, NESOp.asl, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x16, 3, NESOp.asl, NESAddressing.absolute, 6, 0),
  NESOpCode(0x1E, 3, NESOp.asl, NESAddressing.absoluteX, 7, 0),

  /// LSR
  NESOpCode(0x4A, 1, NESOp.lsr, NESAddressing.accumulator, 2, 0),
  NESOpCode(0x46, 2, NESOp.lsr, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x56, 2, NESOp.lsr, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x4E, 3, NESOp.lsr, NESAddressing.absolute, 6, 0),
  NESOpCode(0x5E, 3, NESOp.lsr, NESAddressing.absoluteX, 7, 0),

  /// ROL
  NESOpCode(0x2A, 1, NESOp.rol, NESAddressing.accumulator, 2, 0),
  NESOpCode(0x26, 2, NESOp.rol, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x36, 2, NESOp.rol, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x2E, 3, NESOp.rol, NESAddressing.absolute, 6, 0),
  NESOpCode(0x3E, 3, NESOp.rol, NESAddressing.absoluteX, 7, 0),

  /// ROR
  NESOpCode(0x6A, 1, NESOp.ror, NESAddressing.accumulator, 2, 0),
  NESOpCode(0x66, 2, NESOp.ror, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x76, 2, NESOp.ror, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x6E, 3, NESOp.ror, NESAddressing.absolute, 6, 0),
  NESOpCode(0x7E, 3, NESOp.ror, NESAddressing.absoluteX, 7, 0),

  /// PHA
  NESOpCode(0x48, 1, NESOp.pha, NESAddressing.implied, 3, 0),

  /// PLA
  NESOpCode(0x68, 1, NESOp.pla, NESAddressing.implied, 4, 0),

  /// PHP
  NESOpCode(0x08, 1, NESOp.php, NESAddressing.implied, 3, 0),

  /// PLP
  NESOpCode(0x28, 1, NESOp.plp, NESAddressing.implied, 4, 0),

  /// JMP
  NESOpCode(0x4C, 3, NESOp.jmp, NESAddressing.absolute, 3, 0),
  NESOpCode(0x6C, 3, NESOp.jmp, NESAddressing.indirect, 5, 0),

  /// BEQ
  NESOpCode(0xF0, 2, NESOp.beq, NESAddressing.relative, 2, 1),

  /// BNE
  NESOpCode(0xD0, 2, NESOp.bne, NESAddressing.relative, 2, 1),

  /// BCS
  NESOpCode(0xB0, 2, NESOp.bcs, NESAddressing.relative, 2, 1),

  /// BCC
  NESOpCode(0x90, 2, NESOp.bcc, NESAddressing.relative, 2, 1),

  /// BMI
  NESOpCode(0x30, 2, NESOp.bmi, NESAddressing.relative, 2, 1),

  /// BPL
  NESOpCode(0x10, 2, NESOp.bpl, NESAddressing.relative, 2, 1),

  /// BVS
  NESOpCode(0x70, 2, NESOp.bvs, NESAddressing.relative, 2, 1),

  /// BVC
  NESOpCode(0x50, 2, NESOp.bvc, NESAddressing.relative, 2, 1),

  /// JSR
  NESOpCode(0x20, 3, NESOp.jsr, NESAddressing.absolute, 6, 0),

  /// RTS
  NESOpCode(0x60, 1, NESOp.rts, NESAddressing.implied, 6, 0),

  /// NOP
  NESOpCode(0xEA, 1, NESOp.nop, NESAddressing.implied, 2, 0),

  /// BRK
  NESOpCode(0x00, 1, NESOp.brk, NESAddressing.implied, 7, 0),

  /// RTI
  NESOpCode(0x4D, 1, NESOp.rti, NESAddressing.implied, 6, 0),
  /// ALR
  NESOpCode(0x4B, 2, NESOp.alr, NESAddressing.immediate, 2, 0),
  /// ANC
  NESOpCode(0x0B, 2, NESOp.anc, NESAddressing.immediate, 2, 0),
  /// ARR
  NESOpCode(0x6B, 2, NESOp.arr, NESAddressing.immediate, 2, 0),
  /// AXS
  NESOpCode(0xCB, 2, NESOp.axs, NESAddressing.immediate, 2, 0),
  /// LAX
  NESOpCode(0xA7, 2, NESOp.lax, NESAddressing.zeroPage, 3, 0),
  NESOpCode(0xB7, 2, NESOp.lax, NESAddressing.zeroPageY, 4, 0),
  NESOpCode(0xAF, 3, NESOp.lax, NESAddressing.absolute, 4, 0),
  NESOpCode(0xBF, 3, NESOp.lax, NESAddressing.absoluteY, 4, 1),
  NESOpCode(0xA3, 2, NESOp.lax, NESAddressing.indirectX, 6, 0),
  NESOpCode(0xB3, 2, NESOp.lax, NESAddressing.indirectY, 5, 1),

  /// SAX
  NESOpCode(0x87, 2, NESOp.sax, NESAddressing.implied, 3, 0),
  NESOpCode(0x97, 2, NESOp.sax, NESAddressing.implied, 4, 0),
  NESOpCode(0x83, 2, NESOp.sax, NESAddressing.implied, 6, 0),
  NESOpCode(0x8F, 3, NESOp.sax, NESAddressing.implied, 4, 0),

  /// DCP
  NESOpCode(0xC7, 2, NESOp.dcp, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0xD7, 2, NESOp.dcp, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0xCF, 3, NESOp.dcp, NESAddressing.absolute, 6, 0),
  NESOpCode(0xDF, 3, NESOp.dcp, NESAddressing.absoluteX, 7, 0),
  NESOpCode(0xDB, 3, NESOp.dcp, NESAddressing.absoluteY, 7, 0),
  NESOpCode(0xC3, 2, NESOp.dcp, NESAddressing.indirectX, 8, 0),
  NESOpCode(0xD3, 2, NESOp.dcp, NESAddressing.indirectY, 8, 0),

  /// ISC
  NESOpCode(0xE7, 2, NESOp.isc, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0xF7, 2, NESOp.isc, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0xEF, 3, NESOp.isc, NESAddressing.absolute, 6, 0),
  NESOpCode(0xFF, 3, NESOp.isc, NESAddressing.absoluteX, 7, 0),
  NESOpCode(0xFB, 3, NESOp.isc, NESAddressing.absoluteY, 7, 0),
  NESOpCode(0xE3, 2, NESOp.isc, NESAddressing.indirectX, 8, 0),
  NESOpCode(0xF3, 2, NESOp.isc, NESAddressing.indirectY, 8, 0),

  /// RLA
  NESOpCode(0x27, 2, NESOp.rla, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x37, 2, NESOp.rla, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x2F, 3, NESOp.rla, NESAddressing.absolute, 6, 0),
  NESOpCode(0x3F, 3, NESOp.rla, NESAddressing.absoluteX, 7, 0),
  NESOpCode(0x3B, 3, NESOp.rla, NESAddressing.absoluteY, 7, 0),
  NESOpCode(0x23, 2, NESOp.rla, NESAddressing.indirectX, 8, 0),
  NESOpCode(0x33, 2, NESOp.rla, NESAddressing.indirectY, 8, 0),

  /// RRA
  NESOpCode(0x67, 2, NESOp.rra, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x77, 2, NESOp.rra, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x6F, 3, NESOp.rra, NESAddressing.absolute, 6, 0),
  NESOpCode(0x7F, 3, NESOp.rra, NESAddressing.absoluteX, 7, 0),
  NESOpCode(0x7B, 3, NESOp.rra, NESAddressing.absoluteY, 7, 0),
  NESOpCode(0x63, 2, NESOp.rra, NESAddressing.indirectX, 8, 0),
  NESOpCode(0x73, 2, NESOp.rra, NESAddressing.indirectY, 8, 0),

  /// SLO
  NESOpCode(0x07, 2, NESOp.slo, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x17, 2, NESOp.slo, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x0F, 3, NESOp.slo, NESAddressing.absolute, 6, 0),
  NESOpCode(0x1F, 3, NESOp.slo, NESAddressing.absoluteX, 7, 0),
  NESOpCode(0x1B, 3, NESOp.slo, NESAddressing.absoluteY, 7, 0),
  NESOpCode(0x03, 2, NESOp.slo, NESAddressing.indirectX, 8, 0),
  NESOpCode(0x13, 2, NESOp.slo, NESAddressing.indirectY, 8, 0),

  /// SRE
  NESOpCode(0x47, 2, NESOp.sre, NESAddressing.zeroPage, 5, 0),
  NESOpCode(0x57, 2, NESOp.sre, NESAddressing.zeroPageX, 6, 0),
  NESOpCode(0x4F, 3, NESOp.sre, NESAddressing.absolute, 6, 0),
  NESOpCode(0x5F, 3, NESOp.sre, NESAddressing.absoluteX, 7, 0),
  NESOpCode(0x5B, 3, NESOp.sre, NESAddressing.absoluteY, 7, 0),
  NESOpCode(0x43, 2, NESOp.sre, NESAddressing.indirectX, 8, 0),
  NESOpCode(0x53, 2, NESOp.sre, NESAddressing.indirectY, 8, 0),
];

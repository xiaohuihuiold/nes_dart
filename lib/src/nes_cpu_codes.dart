/// 寻址模式
enum NESAddressing {
  // 累加器寻址
  accumulator,
  // 隐含寻址
  implied,
  // 立即寻址
  immediate,
  // 绝对寻址
  absolute,
  // 零页寻址
  zeroPageAbsolute,
  // 绝对X变址
  absoluteX,
  // 绝对Y变址
  absoluteY,
  // 零页X变址
  zeroPageX,
  // 零页Y变址
  zeroPageY,
  // 间接寻址,JMP ($xxFF)会有问题
  indirect,
  // 间接X变址
  indirectX,
  // 间接Y变址
  indirectY,
  // 相对寻址
  relative,
}

/// 指令
enum NESOp {
  lda('LDA');

  final String name;

  const NESOp(this.name);
}

/// 指令
class NESOpCode {
  /// 指令代码
  final int opCode;

  /// 指令
  final NESOp op;

  /// 寻址模式
  final NESAddressing addressing;

  /// 指令字节
  final int size;

  /// 指令周期
  final int cycles;

  /// 额外指令周期
  final int extraCycles;

  NESOpCode(this.opCode, this.op, this.addressing, this.size, this.cycles,
      [this.extraCycles = 0]);
}

/// 指令
final nesCpuCodes = {
  // LDA
  0xA9: NESOpCode(0xA9, NESOp.lda, NESAddressing.immediate, 2, 2),
};

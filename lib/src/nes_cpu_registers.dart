/// 寄存器
class NESCpuRegisters {
  /// 8位累加器
  int _acc = 0;

  /// 8位X变址寄存器
  int _x = 0;

  /// 8位Y变址寄存器
  int _y = 0;

  /// 8位状态寄存器
  int _status = 0;

  /// 16位指令计数器
  int _pc = 0;

  /// 8位栈指针
  int _sp = 0;

  int get acc => _acc;

  set acc(int value) => _acc = value & 0xFF;

  int get x => _x;

  set x(int value) => _x = value & 0xFF;

  int get y => _y;

  set y(int value) => _y = value & 0xFF;

  int get status => _status;

  set status(int value) => _status = value & 0xFF;

  int get pc => _pc;

  set pc(int value) => _pc = value & 0xFFFF;

  int get sp => _sp;

  set sp(int value) => _sp = value & 0xFF;

  /// 获取状态寄存器flag
  int getStatus(NESCpuStatusRegister flag) {
    return (status >> flag.index) & 0x01;
  }

  /// 设置状态寄存器flag
  void setStatus(NESCpuStatusRegister flag, int value) {
    status &= ~flag.bit;
    status |= (value & 0x01) << flag.index;
  }
}

/// 状态寄存器
enum NESCpuStatusRegister {
  /// 进位标记,指令结果是否进位
  c(1 << 0),

  /// 零标记,指令结果是否为0
  z(1 << 1),

  /// 禁止中断标记,除NMI中断
  i(1 << 2),

  /// 十进制模式标记,NES无作用
  d(1 << 3),

  /// BRK中断时被设置
  b(1 << 4),

  /// 未使用
  r(1 << 5),

  /// 溢出标记,指令结果溢出
  v(1 << 6),

  /// 符号标记
  s(1 << 7);

  final int bit;

  const NESCpuStatusRegister(this.bit);
}

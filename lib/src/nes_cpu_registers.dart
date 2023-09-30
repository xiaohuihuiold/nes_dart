import 'package:flutter/foundation.dart';

import 'logger.dart';
import 'nes_cpu.dart';
import 'nes_emulator.dart';

/// 寄存器
class NESCpuRegisters extends ChangeNotifier {
  /// CPU
  final NESCpu cpu;

  /// 模拟器
  NESEmulator get emulator => cpu.emulator;

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

  set acc(int value) {
    _acc = value & 0xFF;
    notifyListeners();
    if (emulator.logRegisters) {
      logger.v('REG: SET ACC=${_acc.toRadixString(16).toUpperCase()}');
    }
  }

  int get x => _x;

  set x(int value) {
    _x = value & 0xFF;
    notifyListeners();
    if (emulator.logRegisters) {
      logger.v('REG: SET X=${_x.toRadixString(16).toUpperCase()}');
    }
  }

  int get y => _y;

  set y(int value) {
    _y = value & 0xFF;
    notifyListeners();
    if (emulator.logRegisters) {
      logger.v('REG: SET Y=${_y.toRadixString(16).toUpperCase()}');
    }
  }

  int get status => _status;

  set status(int value) => _status = value & 0xFF;

  int get pc => _pc;

  set pc(int value) {
    _pc = value & 0xFFFF;
    notifyListeners();
    if (emulator.logRegisters) {
      logger.v('REG: SET PC=${_pc.toRadixString(16).toUpperCase()}');
    }
  }

  int get sp => _sp;

  set sp(int value) {
    _sp = value & 0xFF;
    notifyListeners();
    if (emulator.logRegisters) {
      logger.v('REG: SET SP=${_sp.toRadixString(16).toUpperCase()}');
    }
  }

  NESCpuRegisters(this.cpu);

  /// 获取状态寄存器flag
  int getStatus(NESCpuStatusRegister flag) {
    return (status >> flag.index) & 0x01;
  }

  /// 设置状态寄存器flag
  void setStatus(NESCpuStatusRegister flag, int value) {
    status &= ~flag.bit;
    status |= (value & 0x01) << flag.index;
    notifyListeners();
    if (emulator.logRegisters) {
      logger.v('REG: SET ${flag.name.toUpperCase()}=$value');
    }
  }

  /// 检查更新状态寄存器
  void checkAndUpdateStatus(NESCpuStatusRegister flag, int value) {
    value &= 0xFF;
    switch (flag) {
      case NESCpuStatusRegister.s:
        setStatus(NESCpuStatusRegister.s, (value >> 7) & 1);
        break;
      case NESCpuStatusRegister.z:
        setStatus(NESCpuStatusRegister.z, value == 0 ? 1 : 0);
        break;
      default:
        throw Exception('未实现的状态寄存器标志位');
    }
  }

  /// 重置寄存器
  void reset() {
    status = 0;
    acc = 0;
    x = 0;
    y = 0;
    pc = 0;
    sp = 0;
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

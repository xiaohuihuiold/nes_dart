import 'nes_cpu_codes.dart';
import 'nes_cpu_registers.dart';
import 'nes_cpu.dart';

/// 指令执行
typedef ExecutorFun = void Function(NESOpCode, int);

/// CPU执行器
class NESCpuExecutor {
  /// CPU
  final NESCpu cpu;

  /// 指令
  final _opExecutorMapping = <NESOp, ExecutorFun>{};

  NESCpuExecutor(this.cpu);

  /// 执行一次
  void execute(NESOpCode op, int address) {
    final executor = _opExecutorMapping[op.op];
    if (executor == null) {
      throw Exception('未实现的指令: ${op.op}');
    }
    executor(op, address);
  }
}

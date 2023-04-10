import 'nes_cpu.dart';
import 'nes_ppu.dart';
import 'nes_mapper.dart';
import 'logger.dart';
import 'nes_cpu_codes.dart';
import 'nes_rom.dart';

/// 模拟器状态
enum NESEmulatorState {
  idle,
  running,
  paused,
  stopped,
}

/// NES模拟器
class NESEmulator {
  /// 是否输出内存日志
  bool logMemory = false;

  /// 是否输出CPU日志
  bool logCpu = false;

  /// 是否输出寄存器日志
  bool logRegisters = false;

  /// rom
  final NESRom rom;

  /// 内存映射
  late NESMapper _mapper;

  NESMapper get mapper => _mapper;

  /// CPU
  late final cpu = NESCpu(this);

  /// PPU
  late final ppu = NESPpu(this);

  /// 模拟器状态
  NESEmulatorState _state = NESEmulatorState.idle;

  NESEmulatorState get state => _state;

  /// 最近一条指令结束时间
  int _lastOpTime = DateTime.now().microsecondsSinceEpoch;

  /// CPU循环是否开启中
  bool _cpuRunning = false;

  NESEmulator({
    required this.rom,
    this.logMemory = false,
    this.logCpu = false,
    this.logRegisters = false,
  }) {
    // TODO: 根据mapper编号创建
    _mapper = NESMapper000(this);
  }

  /// 运行模拟器
  void run() {
    if (state != NESEmulatorState.idle) {
      logger.w('模拟器正在运行中');
      return;
    }
    reset();
    _state = NESEmulatorState.running;
    logger.i('模拟器开始运行...');
    _startCPULoop();
  }

  /// 重置
  void reset() {
    mapper.reset();
    cpu.reset();
    ppu.reset();
    logger.i('模拟器已重置');
  }

  /// 恢复
  void resume() {
    if (state != NESEmulatorState.paused) {
      logger.w('模拟器不在暂停中');
      return;
    }
    _state = NESEmulatorState.running;
    _startCPULoop();
  }

  /// 暂停
  void pause() {
    if (state != NESEmulatorState.running) {
      logger.w('模拟器不在运行中');
      return;
    }
    _state = NESEmulatorState.paused;
    logger.i('模拟器已暂停');
  }

  /// 暂停
  void stop() {
    _state = NESEmulatorState.stopped;
    logger.i('模拟器已停止');
  }

  /// TODO: 优化
  /// 开始CPU循环
  Future<void> _startCPULoop() async {
    if (_cpuRunning) {
      return;
    }
    _cpuRunning = true;
    while (state == NESEmulatorState.running) {
      final beginTime = DateTime.now().microsecondsSinceEpoch;
      int cycleCount = 0;
      while (cycleCount < NESCpu.clockSpeedNTSC) {
        cycleCount += cpu.execute();
      }
      final spendTime = DateTime.now().microsecondsSinceEpoch - beginTime;
      logger.v('执行时间: ${spendTime}us');
      final delay =
          ((1000 * 1000 / 50) - spendTime).toInt().clamp(0, 1000 * 1000);
      await Future.delayed(Duration(microseconds: delay));
      _lastOpTime = DateTime.now().microsecondsSinceEpoch;
    }
    _cpuRunning = false;
  }

  /// 打印指令
  void printCodes() {
    if (state != NESEmulatorState.running && state != NESEmulatorState.paused) {
      logger.w('模拟器未加载程序');
      return;
    }
    final prg = rom.prgRom;
    const addressPRGRom = NESMapper000.addressPRGRom;
    for (int i = 0; i < prg.length;) {
      final address = addressPRGRom + i;
      final byte = mapper.read(address);
      final op = NESCpuCodes.getOP(byte);

      if (op.op == NESOp.error) {
        logger.e('错误: ${byte.toRadixString(16)}');
        break;
      }

      final stringBuffer = StringBuffer();
      final addressStr =
          address.toRadixString(16).toUpperCase().padLeft(4, '0');
      stringBuffer.write(addressStr);
      stringBuffer.write(': ');
      stringBuffer.write(op.op.name);
      if (op.size > 1) {
        String value = mapper
            .read(address + 1)
            .toRadixString(16)
            .toUpperCase()
            .padLeft(2, '0');
        if (op.size == 3) {
          value = mapper
              .read16(address + 1)
              .toRadixString(16)
              .toUpperCase()
              .padLeft(2, '0');
        }
        stringBuffer.write(' ');
        stringBuffer.write(value);
      }
      logger.v(stringBuffer.toString());
      i += op.size;
    }
  }
}

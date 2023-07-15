import 'dart:async';

import 'package:flutter/foundation.dart';

import 'nes_cpu.dart';
import 'nes_ppu.dart';
import 'nes_mapper.dart';
import 'logger.dart';
import 'nes_cpu_codes.dart';
import 'nes_rom.dart';
import 'utils.dart';

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

  /// 帧率
  final double frameRate;

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
  final _stateValue = ValueNotifier<NESEmulatorState>(NESEmulatorState.idle);

  ValueListenable<NESEmulatorState> get state => _stateValue;

  /// FPS
  int _fps = 0;
  final _fpsValue = ValueNotifier<int>(0);

  ValueListenable<int> get fpsValue => _fpsValue;

  Timer? _fpsTimer;

  /// 最近一条指令结束花费时间
  int _overTime = 0;

  /// CPU循环是否开启中
  bool _cpuRunning = false;

  NESEmulator({
    required this.rom,
    this.frameRate = 60,
    this.logMemory = false,
    this.logCpu = false,
    this.logRegisters = false,
  }) {
    // TODO: 根据mapper编号创建
    _mapper = NESMapper000(this);
  }

  /// 运行模拟器
  void run() {
    if (state.value != NESEmulatorState.idle) {
      logger.w('模拟器正在运行中');
      return;
    }
    reset();
    _stateValue.value = NESEmulatorState.running;
    logger.i('模拟器开始运行...');
    _startFpsTimer();
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
    if (state.value != NESEmulatorState.paused) {
      logger.w('模拟器不在暂停中');
      return;
    }
    _stateValue.value = NESEmulatorState.running;
    logger.i('模拟器已恢复');
    _startFpsTimer();
    _startCPULoop();
  }

  /// 暂停
  void pause() {
    if (state.value != NESEmulatorState.running) {
      logger.w('模拟器不在运行中');
      return;
    }
    _stateValue.value = NESEmulatorState.paused;
    _stopFpsTimer();
    logger.i('模拟器已暂停');
  }

  /// 停止
  void stop() {
    _stateValue.value = NESEmulatorState.stopped;
    _stopFpsTimer();
    logger.i('模拟器已停止');
  }

  /// TODO: 优化
  /// 开始CPU循环
  Future<void> _startCPULoop() async {
    if (_cpuRunning) {
      return;
    }
    _cpuRunning = true;
    while (state.value == NESEmulatorState.running) {
      final beginTime = Time.nowUs;
      int cycleCount = 0;
      while (cycleCount < NESCpu.clockSpeedNTSC / frameRate) {
        cycleCount += cpu.execute();
      }
      final spendTime = Time.nowUs - beginTime + _overTime;
      final lastTime = Time.nowUs;
      final delay =
          ((1000 * 1000 / frameRate) - spendTime).toInt().clamp(0, 1000 * 1000);
      logger.v('帧: $cycleCount(cycles)\t $spendTime(us)\t delay: $delay(us)');
      await Future.delayed(Duration(microseconds: delay));
      _overTime = Time.nowUs - lastTime - delay;
      _fps++;
    }
    _cpuRunning = false;
  }

  /// 开始FPS
  void _startFpsTimer() {
    _fpsTimer?.cancel();
    _fpsTimer = null;
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final fps = _fps;
      _fps = 0;
      _fpsValue.value = fps;
    });
  }

  /// 停止FPS
  void _stopFpsTimer() {
    _fpsTimer?.cancel();
    _fpsTimer = null;
    _fpsValue.value = 0;
  }

  /// 打印指令
  void printCodes() {
    if (state.value != NESEmulatorState.running &&
        state.value != NESEmulatorState.paused) {
      logger.w('模拟器未加载程序');
      return;
    }
    final prg = rom.prgRom;
    const addressPRGRom = NESMapper000.addressPRGRom;
    for (int i = 0; i < prg.length;) {
      final address = addressPRGRom + i;
      final byte = mapper.readU8(address);
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
            .readU8(address + 1)
            .toRadixString(16)
            .toUpperCase()
            .padLeft(2, '0');
        if (op.size == 3) {
          value = mapper
              .readU16(address + 1)
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

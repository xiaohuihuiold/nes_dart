import 'mapper/mapper.dart';
import 'logger.dart';

import 'nes_rom.dart';

/// 模拟器状态
enum NESEmulatorState {
  idle,
  running,
  pause,
  stop,
}

/// NES模拟器
class NESEmulator {
  /// rom
  final NESRom rom;

  /// 内存映射
  late NESMapper _mapper;

  NESMapper get mapper => _mapper;

  /// 模拟器状态
  NESEmulatorState _state = NESEmulatorState.idle;

  NESEmulatorState get state => _state;

  NESEmulator({
    required this.rom,
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
  }

  /// 重置
  void reset() {
    _mapper.reset();
    logger.i('模拟器已重置');
  }

  /// 暂停
  void pause() {
    if (state != NESEmulatorState.running) {
      logger.w('模拟器不在运行中');
      return;
    }
    _state = NESEmulatorState.pause;
    logger.i('模拟器已暂停');
  }

  /// 暂停
  void stop() {
    _state = NESEmulatorState.stop;
    logger.i('模拟器已停止');
  }
}

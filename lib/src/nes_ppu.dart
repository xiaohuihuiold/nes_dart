import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

import 'bytes_ext.dart';
import 'nes_memory.dart';
import 'nes_emulator.dart';
import 'logger.dart';

/// PPU
///
/// | 地址范围     | 大小  | 描述                |
/// | :---------: | :---: | :----------------: |
/// | $0000-$0FFF | $1000 | Pattern table 0    |
/// | $1000-$1FFF | $1000 | Pattern table 1    |
/// | $2000-$23FF | $0400 | 名称表0             |
/// | $2400-$27FF | $0400 | 名称表1             |
/// | $2800-$2BFF | $0400 | 名称表2             |
/// | $2C00-$2FFF | $0400 | 名称表3             |
/// | $3000-$3EFF | $0F00 | $2000-$2EFF的镜像   |
/// | $3F00-$3F1F | $0020 | 调色板索引          |
/// | $3F20-$3FFF | $00E0 | $3F00-$3F1F的镜像   |
/// | $3F20-$3FFF | $00E0 | $3F00-$3F1F的镜像   |
/// | $4000-$FFFF | $BFFF | $0000-$3FFF的镜像   |
class NESPpu {
  /// 屏幕缓冲区大小
  static const screenBufferSize = (256 * 256 + 256) * 4;

  /// VRAM
  final _memory = NESMemory();

  /// 模拟器
  final NESEmulator emulator;

  /// 屏幕缓冲区
  ByteData _screenBuffer = ByteData(screenBufferSize);

  /// 屏幕图像
  final _screen = ValueNotifier<ui.Image?>(null);

  ValueListenable<ui.Image?> get screen => _screen;

  NESPpu(this.emulator);

  /// 重置
  void reset() {
    _memory.reset();
    resetScreen();
    submitScreen();
    logger.v('PPU已重置');
  }

  void resetScreen([int fillColor = 0x000000FF]) {
    _screenBuffer = ByteData(screenBufferSize);
    for (int i = 0; i < screenBufferSize; i += 4) {
      _screenBuffer.setUint32(i, fillColor);
    }
    for (int i = 0; i < 32; i++) {
      for (int y = 1; y <= 240; y++) {
        drawPoint(i * 8 + 1, y, 0x222222FF);
      }
    }
    for (int i = 0; i < 30; i++) {
      for (int x = 1; x <= 256; x++) {
        drawPoint(x, i * 8 + 1, 0x222222FF);
      }
    }
  }

  /// TODO: 释放图像
  /// 刷新屏幕
  Future<void> submitScreen() async {
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(
          _screenBuffer.buffer.asUint8List());
      final imageDescriptor = ui.ImageDescriptor.raw(
        buffer,
        width: 256,
        height: 240,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      buffer.dispose();
      final codec = await imageDescriptor.instantiateCodec();
      final frameInfo = await codec.getNextFrame();
      codec.dispose();
      imageDescriptor.dispose();
      final oldScreen = _screen.value;
      _screen.value = frameInfo.image;
      if (oldScreen != null) {
        oldScreen.dispose();
      }
    } catch (e) {
      logger.e('屏幕刷新错误', error: e);
    }
  }

  /// 绘制像素点
  void drawPoint(int x, int y, int rbga) async {
    if (x <= 0 || x > 256 || y <= 0 || y > 240) {
      return;
    }
    _screenBuffer.setUint32(((y - 1) * 256 + (x - 1)) * 4, rbga);
  }
}

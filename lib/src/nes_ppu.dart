import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

import 'nes_memory.dart';
import 'nes_palettes.dart';
import 'nes_emulator.dart';
import 'nes_ppu_registers.dart';
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
  static const screenBufferSize = (256 * 256 + 256) * 4 * 4;

  /// 图样表最大地址
  static const maxPatternAddress = 0x1FFF;

  /// 名称表地址
  static const minNameTablesAddress = 0x2000;
  static const maxNameTablesAddress = 0x3EFF;

  /// 调色板索引
  static const minPaletteAddress = 0x3F00;

  /// VRAM
  final _memory = NESMemory();

  /// Sprite RAM
  final _spriteMemory = NESMemory();

  /// 模拟器
  final NESEmulator emulator;

  /// 寄存器
  late final registers = NESPpuRegisters(this);

  /// 屏幕缓冲区
  ByteData _screenBuffer = ByteData(screenBufferSize);

  /// 屏幕图像
  final _screen = ValueNotifier<ui.Image?>(null);

  ValueListenable<ui.Image?> get screen => _screen;

  /// 调色板
  final _palette = ValueNotifier<List<int>>(NESPalettes.ntsc);

  ValueListenable<List<int>> get palette => _palette;

  NESPpu(this.emulator);

  /// 重置
  void reset() {
    _memory.reset();
    _spriteMemory.reset();
    registers.reset();
    loadPalette(NESPalettes.ntsc);
    resetScreen();
    submitScreen();
    logger.v('PPU已重置');
  }

  /// 加载调色板
  void loadPalette(List<int> palette) {
    if (palette.length != 64) {
      throw Exception('调色板数量不正确,需要长度为64');
    }
    _palette.value = palette.toList();
    logger.v('调色板已加载');
  }

  /// 重置屏幕画面
  void resetScreen([int fillColor = 0x000000FF]) {
    _screenBuffer = ByteData(screenBufferSize);
    for (int i = 0; i < screenBufferSize; i += 4) {
      _screenBuffer.setUint32(i, fillColor);
    }
    for (int i = 0; i < 32; i++) {
      for (int y = 0; y < 240; y++) {
        drawPoint(i * 8, y, 0x222222FF);
      }
    }
    for (int i = 0; i < 30; i++) {
      for (int x = 0; x < 256; x++) {
        drawPoint(x, i * 8, 0x222222FF);
      }
    }
  }

  /// 刷新屏幕
  void refreshScreen() {
    final nameTable = readAll(minNameTablesAddress, 960);
    // 1字节4x4个图块
    final attributeTable = readAll(minNameTablesAddress + 960, 64);
    final patternTable = readAll(
        (registers.ctrl & NESPpuCtrlRegister.background.bit != 0 ? 1 : 0) *
            0x1000,
        0x1000);
    final palette = readAll(minPaletteAddress, 0x20);
    final paletteData = palette.map((e) => this.palette.value[e]).toList();
    // TODO: 优化实现
    int tileX = 0;
    int tileY = 0;
    for (int i = 0; i < nameTable.length; i++) {
      final tileIndex = nameTable[i];
      final tileBegin = tileIndex * 16;
      int x = 0;
      int y = 0;
      final attrX = tileX ~/ 4;
      final attrY = tileY ~/ 4;
      final attr = attributeTable[attrY * 8 + attrX];
      for (int b = 0; b < 8; b++) {
        final byteL = patternTable[tileBegin + b];
        final byteH = patternTable[tileBegin + b + 8];
        final attrOffset = b ~/ 2;
        final colorAttr = (attr >> (attrOffset * 2)) & 0x3;
        for (int j = 7; j >= 0; j--) {
          final pL = (byteL >> j) & 1;
          final pH = (byteH >> j) & 1;
          final pixel = pL | (pH << 1);
          int color = paletteData[pixel | (colorAttr << 2)];
          drawPoint(tileX * 8 + x, tileY * 8 + y, color);
          x++;
          if (x >= 8) {
            x = 0;
            y++;
          }
          if (y >= 8) {
            y = 0;
          }
        }
      }
      tileX++;
      if (tileX >= 32) {
        tileX = 0;
        tileY++;
      }
    }
  }

  /// 绘制像素点
  void drawPoint(int x, int y, int rbga) {
    if (x < 0 || x > 256 || y < 0 || y > 240) {
      return;
    }
    _screenBuffer.setUint32((y * 256 + x) * 4, rbga);
  }

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
      logger.e('屏幕提交错误', error: e);
    }
  }

  /// 开始VBlank,设置[NESPpuRegister.status]的[NESPpuStatusRegister.vBlank]标志位
  /// 修改内存会自动更新PPU寄存器
  void beginVBlank() {
    emulator.mapper.writeU8(NESPpuRegister.status.address,
        registers.status | NESPpuStatusRegister.vBlank.bit);
    if (registers.ctrl & NESPpuCtrlRegister.nmi.bit != 0) {
      emulator.cpu.executeNMI();
    }
  }

  /// 结束VBlank,清除[NESPpuRegister.status]的[NESPpuStatusRegister.vBlank]标志位
  /// 修改内存会自动更新PPU寄存器
  void endVBlank() {
    emulator.mapper.writeU8(NESPpuRegister.status.address,
        registers.status & (~NESPpuStatusRegister.vBlank.bit));
  }

  /// TODO: PPU其它表
  int readU8(int address) {
    _printRead(address);
    _incVramPointer();
    if (address <= maxPatternAddress) {
      return _memory.readU8(address);
    } else if (address <= maxNameTablesAddress) {
      return _memory.readU8(address);
    } else if (address >= minPaletteAddress &&
        address < minPaletteAddress + 0x20) {
      return _memory.readU8(address);
    } else {
      return _memory.readU8(address);
    }
  }

  /// TODO: PPU其它表
  void writeU8(int address, int value) {
    _printWrite(address, value);
    _incVramPointer();
    if (address <= maxPatternAddress) {
      _memory.writeU8(address, value);
    } else if (address <= maxNameTablesAddress) {
      _memory.writeU8(address, value);
    } else if (address >= minPaletteAddress &&
        address < minPaletteAddress + 0x20) {
      if (address == 0x3F00 || address == 0x3F10) {
        _memory.writeU8(0x3F00, value);
        _memory.writeU8(0x3F10, value);
      } else if (address == 0x3F04 || address == 0x3F14) {
        _memory.writeU8(0x3F04, value);
        _memory.writeU8(0x3F14, value);
      } else if (address == 0x3F08 || address == 0x3F18) {
        _memory.writeU8(0x3F08, value);
        _memory.writeU8(0x3F18, value);
      } else if (address == 0x3F0C || address == 0x3F1C) {
        _memory.writeU8(0x3F0C, value);
        _memory.writeU8(0x3F1C, value);
      } else {
        _memory.writeU8(address, value);
      }
    } else {
      _memory.writeU8(address, value);
    }
  }

  Uint8List readAll(int address, int length) {
    return _memory.readAll(address, length);
  }

  void writeAll(int address, List<int> bytes, {int start = 0, int? end}) {
    _memory.writeAll(address, bytes, start: start, end: end);
  }

  int spriteRamRead(int address) {
    _printSpriteRead(address);
    return _spriteMemory.readU8(address);
  }

  void spriteRamWrite(int address, int value) {
    _printSpriteWrite(address, value);
    _spriteMemory.writeU8(address, value);
  }

  void _incVramPointer() {
    registers.vramPointer +=
        (registers.ctrl & NESPpuCtrlRegister.inc.bit) == 0 ? 1 : 32;
  }

  void _printRead(int address) {
    if (emulator.logVideoMemory) {
      logger.v(
          'R VRAM: \$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}');
    }
  }

  void _printWrite(int address, int value) {
    if (emulator.logVideoMemory) {
      logger.v('W VRAM: '
          '\$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}'
          '='
          '${value.toRadixString(16).toUpperCase()}');
    }
  }

  void _printSpriteRead(int address) {
    if (emulator.logVideoSpriteMemory) {
      logger.v(
          'R SRAM: \$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}');
    }
  }

  void _printSpriteWrite(int address, int value) {
    if (emulator.logVideoSpriteMemory) {
      logger.v('W SRAM: '
          '\$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}'
          '='
          '${value.toRadixString(16).toUpperCase()}');
    }
  }
}

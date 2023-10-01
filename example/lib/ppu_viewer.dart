import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:nes_dart/nes_dart.dart';

/// PPU查看器
class PPUViewer extends StatefulWidget {
  /// 模拟器
  final NESEmulator? emulator;

  const PPUViewer({super.key, required this.emulator});

  @override
  State<PPUViewer> createState() => _PPUViewerState();
}

class _PPUViewerState extends State<PPUViewer> {
  @override
  Widget build(BuildContext context) {
    final emulator = widget.emulator;
    if (emulator == null) {
      return const SizedBox();
    }
    return Container(
      width: 300,
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white10,
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupMenuButton<List<int>>(
              child: const Text('调色板'),
              onSelected: (palette) {
                emulator.ppu.loadPalette(palette);
              },
              itemBuilder: (BuildContext context) {
                return const [
                  PopupMenuItem(
                    value: NESPalettes.ntsc,
                    child: Text('NTSC'),
                  ),
                  PopupMenuItem(
                    value: NESPalettes.pal,
                    child: Text('PAL'),
                  ),
                ];
              },
            ),
            const SizedBox(height: 8),
            _PaletteViewer(emulator: emulator),
            const SizedBox(height: 8),
            const Divider(),
            const Text('图样表'),
            const SizedBox(height: 8),
            _PatternTable(index: 0, emulator: emulator),
            const SizedBox(height: 8),
            _PatternTable(index: 1, emulator: emulator),
          ],
        ),
      ),
    );
  }
}

/// 调色板查看器
class _PaletteViewer extends StatelessWidget {
  final NESEmulator emulator;

  const _PaletteViewer({
    super.key,
    required this.emulator,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: emulator.ppu.palette,
      builder: (context, palette, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 4; i++)
              Row(
                children: [
                  for (int k = 0; k < 16; k++)
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _buildColor(palette[i * 16 + k]),
                      ),
                    )
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildColor(int rgba) {
    int argb = rgba >> 8;
    argb |= (rgba & 0xff) << 24;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(argb),
        border: Border.all(color: Colors.grey, width: 1),
      ),
    );
  }
}

/// 图样表查看器
class _PatternTable extends StatefulWidget {
  /// 图样表序号
  final int index;
  final NESEmulator emulator;

  const _PatternTable({
    super.key,
    required this.index,
    required this.emulator,
  });

  @override
  State<_PatternTable> createState() => _PatternTableState();
}

class _PatternTableState extends State<_PatternTable> {
  /// 屏幕缓冲区大小
  static const screenBufferSize = (128 * 128) * 4;
  Timer? _refreshTimer;

  Uint8List? _patternTable;

  ui.Image? _screen;

  /// 屏幕缓冲区
  ByteData _screenBuffer = ByteData(screenBufferSize);

  void _refreshData() {
    _patternTable = widget.emulator.ppu.readAll(widget.index * 0x1000, 0x1000);
    _resetScreen();
    _refreshScreen();
    _submitScreen();
  }

  void _resetScreen([int fillColor = 0x000000FF]) {
    _screenBuffer = ByteData(screenBufferSize);
    for (int i = 0; i < screenBufferSize; i += 4) {
      _screenBuffer.setUint32(i, fillColor);
    }
  }

  void _drawPoint(int x, int y, int rbga) {
    if (x <= 0 || x > 128 || y <= 0 || y > 128) {
      return;
    }
    _screenBuffer.setUint32(((y - 1) * 128 + (x - 1)) * 4, rbga);
  }

  void _refreshScreen() {
    final patternTable = _patternTable;
    if (patternTable == null) {
      return;
    }
    int x = 0;
    int y = 1;
    int blockX = 0;
    int blockY = 0;
    for (int i = 0; i < patternTable.length; i += 16) {
      // 2位表示一个像素
      // 16字节描述8x8图块,一共16x16图块
      // 前8字节表示2位的低位,后8字节表示高位
      for (int b = 0; b < 8; b++) {
        final byteL = patternTable[i + b];
        final byteH = patternTable[i + b + 8];
        for (int j = 7; j >= 0; j--) {
          final pL = (byteL >> j) & 1;
          final pH = (byteH >> j) & 1;
          final pixel = pL | (pH << 1);
          int color = 0x000000FF;
          if (pixel == 0) {
            color = 0x000000FF;
          } else if (pixel == 1) {
            color = 0xFF0000FF;
          } else if (pixel == 2) {
            color = 0x00FF00FF;
          } else if (pixel == 3) {
            color = 0x0000FFFF;
          }
          x++;
          if (x > 8) {
            x = 1;
            y++;
          }
          if (y > 8) {
            y = 1;
            blockX++;
            if (blockX >= 16) {
              blockX = 0;
              blockY++;
            }
          }
          _drawPoint(blockX * 8 + x, blockY * 8 + y, color);
        }
      }
      /*for (int j = 0; j < 4; j++) {
        final pixel = (byte >> j) & 0x3;
        int color = 0x000000FF;
        if (pixel == 0) {
          color = 0x000000FF;
        } else if (pixel == 1) {
          color = 0xFF0000FF;
        } else if (pixel == 2) {
          color = 0x00FF00FF;
        } else if (pixel == 3) {
          color = 0x0000FFFF;
        }
        x++;
        if (x > 8) {
          x = 1;
          y++;
        }
        _drawPoint(x, y, color);
      }*/
      /*for (int j = 0; j < 16; j++) {
        final byte = patternTable[i * 16 + j];
        for (int k = 0; k < 4; k++) {
          final pixel = (byte >> k) & 0x3;
          final x = 0;
          final y = 0;
          if (pixel == 0) {
            _drawPoint(x, y, 0x000000FF);
          } else if (pixel == 1) {
            _drawPoint(x, y, 0xFF0000FF);
          } else if (pixel == 2) {
            _drawPoint(x, y, 0x00FF00FF);
          } else if (pixel == 3) {
            _drawPoint(x, y, 0x0000FFFF);
          }
        }
      }*/
    }
  }

  Future<void> _submitScreen() async {
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(
          _screenBuffer.buffer.asUint8List());
      final imageDescriptor = ui.ImageDescriptor.raw(
        buffer,
        width: 128,
        height: 128,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      buffer.dispose();
      final codec = await imageDescriptor.instantiateCodec();
      final frameInfo = await codec.getNextFrame();
      codec.dispose();
      imageDescriptor.dispose();
      final oldScreen = _screen;
      _screen = frameInfo.image;
      if (mounted) {
        setState(() {});
      }
      if (oldScreen != null) {
        oldScreen.dispose();
      }
    } catch (e) {
      logger.e('PPUViewer', error: e);
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      try {
        _refreshData();
      } catch (e) {
        logger.e('PPUViewer', error: e);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _PatternPainter(image: _screen),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final ui.Image? image;

  _PatternPainter({required this.image});

  @override
  void paint(Canvas canvas, ui.Size size) {
    final image = this.image;
    if (image != null) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        Offset.zero & size,
        Paint(),
      );
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

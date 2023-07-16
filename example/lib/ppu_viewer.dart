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

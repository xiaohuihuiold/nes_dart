import 'package:flutter/material.dart';
import 'package:nes_dart/nes_dart.dart';

/// 内存查看器
class MemoryViewer extends StatefulWidget {
  /// 模拟器对象
  final NESEmulator? emulator;

  const MemoryViewer({
    super.key,
    required this.emulator,
  });

  @override
  State<MemoryViewer> createState() => _MemoryViewerState();
}

class _MemoryViewerState extends State<MemoryViewer> {
  List<OpCodeInfo> _opCodes = [];

  /// 加载指令码
  void _loadOpCodes() {
    final emulator = widget.emulator;
    if (emulator == null) {
      _opCodes = [];
    } else {
      _opCodes = emulator.getCodes();
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadOpCodes();
  }

  @override
  void didUpdateWidget(covariant MemoryViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emulator != oldWidget.emulator) {
      _loadOpCodes();
    }
  }

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
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: ListenableBuilder(
        listenable: emulator.cpu.registers,
        builder: (context, child) {
          return _MemoryViewerWidget(
            pc: emulator.cpu.registers.pc,
            opCodes: _opCodes,
          );
        },
      ),
    );
  }
}

class _MemoryViewerWidget extends LeafRenderObjectWidget {
  final int pc;
  final List<OpCodeInfo> opCodes;

  const _MemoryViewerWidget({
    super.key,
    required this.pc,
    required this.opCodes,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMemoryViewer(
      pc: pc,
      opCodes: opCodes,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMemoryViewer renderObject) {
    renderObject
      ..pc = pc
      ..opCodes = opCodes;
  }
}

class _RenderMemoryViewer extends RenderBox {
  int _pc = 0;

  set pc(int value) {
    if (_pc == value) {
      return;
    }
    _pc = value;
    _pcIndex = _mapping[_pc] ?? -1;
    markNeedsPaint();
  }

  List<OpCodeInfo> _opCodes = [];

  set opCodes(List<OpCodeInfo> value) {
    if (_opCodes == value) {
      return;
    }
    _opCodes = value;
    _texts = [];
    _mapping = {};
    for (int i = 0; i < _opCodes.length; i++) {
      final opCodeInfo = _opCodes[i];
      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: opCodeInfo.address
                  .toRadixString(16)
                  .toUpperCase()
                  .padLeft(4, '0'),
              style: const TextStyle(color: Colors.grey),
            ),
            const TextSpan(text: '  '),
            TextSpan(text: opCodeInfo.op.op.name),
            const TextSpan(text: '  '),
            TextSpan(text: opCodeInfo.data),
          ],
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      _textHeight = textPainter.size.height;
      _texts.add(textPainter);
      for (int j = 0; j < opCodeInfo.op.size; j++) {
        _mapping[opCodeInfo.address + j] = i;
      }
    }
    _pcIndex = _mapping[_pc] ?? -1;
    markNeedsLayout();
  }

  double _textHeight = 0.0;
  List<TextPainter> _texts = [];
  Map<int, int> _mapping = {};
  int _pcIndex = -1;

  _RenderMemoryViewer({
    required int pc,
    required List<OpCodeInfo> opCodes,
  }) {
    this.pc = pc;
    this.opCodes = opCodes;
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.translate(offset.dx, offset.dy);
    canvas.clipRect(Offset.zero & size);
    for (int i = 0; i < _texts.length; i++) {
      final y = (i - (_pcIndex.clamp(0, _texts.length))) * (2 + _textHeight);
      if (y + _textHeight < 0 || y > size.height) {
        continue;
      }
      final offset = Offset(0, y);
      if (_pcIndex == i) {
        canvas.drawRect(
          Offset(0, y) & Size(size.width, _textHeight),
          Paint()
            ..color = Colors.blue.withOpacity(0.5)
            ..style = PaintingStyle.fill,
        );
      }
      _texts[i].paint(canvas, offset);
    }
  }
}

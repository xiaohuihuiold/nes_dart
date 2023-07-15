import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'nes_emulator.dart';

/// 显示
class NESView extends StatelessWidget {
  /// 填充方式
  final BoxFit fit;

  /// 模拟器
  final NESEmulator emulator;

  const NESView({
    super.key,
    this.fit = BoxFit.contain,
    required this.emulator,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ui.Image?>(
      valueListenable: emulator.ppu.screen,
      builder: (context, image, child) {
        return _NESWidget(
          fit: fit,
          emulator: emulator,
          image: image,
        );
      },
    );
  }
}

/// 渲染组件
class _NESWidget extends LeafRenderObjectWidget {
  /// 填充方式
  final BoxFit fit;

  /// 模拟器
  final NESEmulator emulator;

  /// 屏幕
  final ui.Image? image;

  const _NESWidget({
    super.key,
    required this.fit,
    required this.emulator,
    required this.image,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderNES(
      fit: fit,
      emulator: emulator,
      image: image,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderNES renderObject) {
    renderObject
      ..fit = fit
      ..emulator = emulator
      ..image = image;
  }
}

/// 渲染
class _RenderNES extends RenderBox {
  /// 默认尺寸
  static const screenWidth = 256;
  static const screenHeight = 240;
  static const screenRatio = screenWidth / screenHeight;
  static const screenBounds = Rect.fromLTWH(0, 0, 256, 240);

  /// 填充方式
  BoxFit _fit;

  set fit(BoxFit value) {
    if (_fit == value) {
      return;
    }
    _fit = value;
    markNeedsLayout();
  }

  /// 模拟器
  NESEmulator _emulator;

  set emulator(NESEmulator value) {
    if (_emulator == value) {
      return;
    }
    _emulator = value;
    markNeedsLayout();
  }

  /// 图像
  ui.Image? _image;

  set image(ui.Image? value) {
    if (_image == value) {
      return;
    }
    _image = value;
    markNeedsPaint();
  }

  /// 渲染区域
  Rect _renderBounds = Rect.zero;

  _RenderNES({
    required BoxFit fit,
    required NESEmulator emulator,
    required ui.Image? image,
  })  : _fit = fit,
        _emulator = emulator,
        _image = image;

  @override
  bool get sizedByParent => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    final viewRatio = size.aspectRatio;
    double renderX = 0;
    double renderY = 0;
    double renderWidth = 0;
    double renderHeight = 0;
    switch (_fit) {
      case BoxFit.none:
      case BoxFit.contain:
        if (viewRatio > screenRatio) {
          renderHeight = size.height;
          renderWidth = renderHeight * screenRatio;
          renderX = (size.width - renderWidth) / 2;
        } else {
          renderWidth = size.width;
          renderHeight = renderWidth / screenRatio;
          renderY = (size.height - renderHeight) / 2;
        }
        break;
      case BoxFit.fill:
        renderWidth = size.width;
        renderHeight = size.height;
        break;
      case BoxFit.cover:
        if (viewRatio < screenRatio) {
          renderHeight = size.height;
          renderWidth = renderHeight * screenRatio;
          renderX = (size.width - renderWidth) / 2;
        } else {
          renderWidth = size.width;
          renderHeight = renderWidth / screenRatio;
          renderY = (size.height - renderHeight) / 2;
        }
        break;
      case BoxFit.fitWidth:
        renderWidth = size.width;
        renderHeight = renderWidth / screenRatio;
        renderY = (size.height - renderHeight) / 2;
        break;
      case BoxFit.fitHeight:
        renderHeight = size.height;
        renderWidth = renderHeight * screenRatio;
        renderX = (size.width - renderWidth) / 2;
        break;
      case BoxFit.scaleDown:
        if (size.width > screenWidth && size.height > screenHeight) {
          renderWidth = screenWidth.toDouble();
          renderHeight = screenHeight.toDouble();
        } else {
          if (viewRatio > screenRatio) {
            renderHeight = size.height;
            renderWidth = renderHeight * screenRatio;
          } else {
            renderWidth = size.width;
            renderHeight = renderWidth / screenRatio;
          }
        }
        renderX = (size.width - renderWidth) / 2;
        renderY = (size.height - renderHeight) / 2;
        break;
    }
    _renderBounds = Rect.fromLTWH(renderX, renderY, renderWidth, renderHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.translate(offset.dx, offset.dy);
    canvas.clipRect(Offset.zero & size);
    _drawBounds(canvas);
    _drawScreen(canvas);
    _drawBounds(canvas, background: false);
  }

  /// 绘制屏幕
  void _drawScreen(Canvas canvas) {
    final image = _image;
    if (image == null) {
      return;
    }
    canvas.drawImageRect(image, screenBounds, _renderBounds, Paint());
  }

  /// 绘制区域
  void _drawBounds(Canvas canvas, {bool background = true}) {
    if (background) {
      canvas.drawRect(
        _renderBounds,
        Paint()
          ..color = Colors.white10
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawRect(
      _renderBounds,
      Paint()
        ..strokeWidth = 2
        ..color = Colors.green
        ..style = PaintingStyle.stroke,
    );
  }
}

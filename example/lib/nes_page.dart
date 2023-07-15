import 'package:flutter/material.dart';
import 'package:nes_dart/nes_dart.dart';

/// 游戏页
class NESPage extends StatefulWidget {
  const NESPage({Key? key}) : super(key: key);

  @override
  State<NESPage> createState() => _NESPageState();
}

class _NESPageState extends State<NESPage> {
  /// 模拟器对象
  NESEmulator? _emulator;

  /// 加载rom
  Future<void> _loadNES() async {
    _emulator?.stop();
    _emulator = null;
    final rom = await NESRomLoader.loadFromAsset('assets/roms/nestest.nes');
    _emulator = NESEmulator(rom: rom);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final emulator = _emulator;

    Widget body;
    if (emulator == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = NESView(emulator: emulator);
    }

    Widget controllerBar;
    if (emulator == null) {
      controllerBar = FloatingActionButton(
        onPressed: _loadNES,
        child: const Icon(Icons.file_download),
      );
    } else {
      controllerBar = _EmulatorControllerBar(
        emulator: emulator,
        loadNES: _loadNES,
      );
    }

    return Scaffold(
      floatingActionButton: controllerBar,
      body: body,
    );
  }
}

/// 控制器
class _EmulatorControllerBar extends StatefulWidget {
  /// 模拟器对象
  final NESEmulator emulator;

  /// 加载rom
  final VoidCallback loadNES;

  const _EmulatorControllerBar({
    super.key,
    required this.emulator,
    required this.loadNES,
  });

  @override
  State<_EmulatorControllerBar> createState() => _EmulatorControllerBarState();
}

class _EmulatorControllerBarState extends State<_EmulatorControllerBar> {
  /// 开始游戏
  void _play() {
    widget.emulator.run();
  }

  /// 暂停游戏
  void _pause() {
    widget.emulator.pause();
  }

  /// 恢复游戏
  void _resume() {
    widget.emulator.resume();
  }

  /// 重置游戏
  void _reset() {
    widget.emulator.reset();
  }

  /// 停止游戏
  void _stop() {
    widget.emulator.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NESEmulatorState>(
      valueListenable: widget.emulator.state,
      builder: (context, state, child) {
        if (state == NESEmulatorState.stopped) {
          return FloatingActionButton(
            onPressed: widget.loadNES,
            child: const Icon(Icons.file_download),
          );
        }
        return Column(
          children: [
            switch (state) {
              NESEmulatorState.stopped ||
              NESEmulatorState.idle =>
                FloatingActionButton(
                  onPressed: _play,
                  child: const Icon(Icons.play_arrow),
                ),
              NESEmulatorState.running => FloatingActionButton(
                  onPressed: _pause,
                  child: const Icon(Icons.pause),
                ),
              NESEmulatorState.paused => FloatingActionButton(
                  onPressed: _resume,
                  child: const Icon(Icons.play_arrow),
                ),
            },
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: _reset,
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: _stop,
              child: const Icon(Icons.stop),
            ),
          ],
        );
      },
    );
  }
}

import 'package:example/memory_viewer.dart';
import 'package:flutter/material.dart';
import 'package:nes_dart/nes_dart.dart';

import 'ppu_viewer.dart';

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
    _emulator = NESEmulator(
      rom: rom,
      // debug: true,
      // logCpu: true,
      // logRegisters: true,
      // logLoop: true,
      // logPpuRegisters: true,
      // logVideoMemory: true,
    );
    _emulator?.state.addListener(() {
      if (_emulator?.state.value == NESEmulatorState.stopped) {
        _onStop();
      }
    });
    if (mounted) setState(() {});
  }

  /// 停止
  void _onStop() {
    _emulator = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final emulator = _emulator;

    Widget body;
    if (emulator == null) {
      body = Center(
        child: AspectRatio(
          aspectRatio: 256 / 240,
          child: Container(color: Colors.black),
        ),
      );
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
      body: Row(
        children: [
          MemoryViewer(emulator: emulator),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: body,
          )),
          PPUViewer(emulator: emulator),
        ],
      ),
      bottomNavigationBar: _EmulatorStatusBar(emulator: emulator),
    );
  }
}

/// 状态栏
class _EmulatorStatusBar extends StatefulWidget {
  /// 模拟器对象
  final NESEmulator? emulator;

  const _EmulatorStatusBar({
    super.key,
    required this.emulator,
  });

  @override
  State<_EmulatorStatusBar> createState() => _EmulatorStatusBarState();
}

class _EmulatorStatusBarState extends State<_EmulatorStatusBar> {
  Widget _buildStatus(NESEmulator emulator) {
    return Row(
      children: [
        ValueListenableBuilder<NESEmulatorState>(
          valueListenable: emulator.state,
          builder: (context, state, child) {
            Color color = Colors.blue;
            String text = '已就绪';
            switch (state) {
              case NESEmulatorState.idle:
                color = Colors.blue;
                text = '已就绪';
                break;
              case NESEmulatorState.running:
                color = Colors.green;
                text = '运行中';
                break;
              case NESEmulatorState.paused:
                color = Colors.orange;
                text = '已暂停';
                break;
              case NESEmulatorState.stopped:
                color = Colors.grey;
                text = '已停止';
                break;
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(text),
              ],
            );
          },
        ),
        const VerticalDivider(),
        Expanded(
          child: ListenableBuilder(
            listenable: emulator.cpu.registers,
            builder: (context, child) {
              final registers = emulator.cpu.registers;
              return Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                        'PC: ${registers.pc.toRadixString(16).toUpperCase()}'),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    width: 60,
                    child: Text(
                        'SP: ${registers.sp.toRadixString(16).toUpperCase()}'),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    width: 50,
                    child: Text(
                        'X: ${registers.x.toRadixString(16).toUpperCase()}'),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    width: 50,
                    child: Text(
                        'Y: ${registers.y.toRadixString(16).toUpperCase()}'),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    width: 70,
                    child: Text(
                        'ACC: ${registers.acc.toRadixString(16).toUpperCase()}'),
                  ),
                  const VerticalDivider(),
                  const SizedBox(child: Text('STATUS:')),
                  const SizedBox(width: 4),
                  _RegisterStatus(
                    color: Colors.red,
                    flag: NESCpuStatusRegister.c,
                    status: registers.status,
                  ),
                  _RegisterStatus(
                    color: Colors.green,
                    flag: NESCpuStatusRegister.z,
                    status: registers.status,
                  ),
                  _RegisterStatus(
                    color: Colors.blue,
                    flag: NESCpuStatusRegister.i,
                    status: registers.status,
                  ),
                  _RegisterStatus(
                    color: Colors.orange,
                    flag: NESCpuStatusRegister.d,
                    status: registers.status,
                  ),
                  _RegisterStatus(
                    color: Colors.indigo,
                    flag: NESCpuStatusRegister.b,
                    status: registers.status,
                  ),
                  _RegisterStatus(
                    color: Colors.teal,
                    flag: NESCpuStatusRegister.r,
                    status: registers.status,
                  ),
                  _RegisterStatus(
                    color: Colors.brown,
                    flag: NESCpuStatusRegister.v,
                    status: registers.status,
                  ),
                  _RegisterStatus(
                    color: Colors.deepPurple,
                    flag: NESCpuStatusRegister.s,
                    status: registers.status,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final emulator = widget.emulator;
    Widget result;
    if (emulator == null) {
      result = const Text('未就绪');
    } else {
      result = _buildStatus(emulator);
    }
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: kBottomNavigationBarHeight / 2,
      decoration: BoxDecoration(
        color: Theme.of(context).navigationBarTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: result,
    );
  }
}

class _RegisterStatus extends StatelessWidget {
  final Color color;
  final NESCpuStatusRegister flag;
  final int status;

  const _RegisterStatus({
    super.key,
    required this.color,
    required this.flag,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = ((status >> flag.index) & 0x1) == 1;
    return Container(
      width: kBottomNavigationBarHeight / 2,
      height: kBottomNavigationBarHeight / 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? color : Colors.transparent,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Text(flag.name.toUpperCase()),
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
          mainAxisSize: MainAxisSize.min,
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

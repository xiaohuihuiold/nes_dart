import 'package:flutter_test/flutter_test.dart';
import 'package:nes_dart/nes_dart.dart';

void main() {
  test('run nestest', () async {
    // 查找重复的指令码
    final codeMap = <int, int>{};
    for (final code in NESCpuCodes.nesCpuCodes) {
      codeMap[code.opCode] = (codeMap[code.opCode] ?? 0) + 1;
    }
    codeMap.removeWhere((key, value) => value == 1);
    expect(codeMap.keys.map((e) => e.toRadixString(16)).toList(), [],
        reason: '重复定义的指令码');

    // 加载rom
    final rom = await NESRomLoader.loadFromPath('roms/nestest.nes');
    print(rom);
    final emulator = NESEmulator(rom: rom);
    emulator.fpsValue.addListener(() {
      final fps = emulator.fpsValue.value;
      print('FPS: $fps');
    });
    emulator.run();
    await Future.delayed(const Duration(days: 1));
  }, timeout: const Timeout(Duration(days: 1)));
}

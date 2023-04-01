import 'package:flutter_test/flutter_test.dart';
import 'package:nes_dart/nes_dart.dart';

void main() {
  test('run nestest', () async {
    final rom = await NESRomLoader.loadFromPath('roms/nestest.nes');
    print(rom);
    final emulator = NESEmulator(rom: rom);
    emulator.run();
    print(emulator.mapper.read(0xc003));
  });
}

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nes_dart/nes_dart.dart';

void main() {
  test('run nestest', () async {
    final rom = await NESRomLoader.loadFromPath('roms/nestest.nes');
    print(rom);
    final emulator = NESEmulator(rom: rom);
    emulator.run();
  });
  test('byte test', () {
    final bytes = Uint8List(100 * 1024 * 1024);
    final byteData = ByteData.view(bytes.buffer);
    final time = DateTime.now().microsecondsSinceEpoch;
    final b = byteData.buffer.asUint8List();
    print(DateTime.now().microsecondsSinceEpoch - time);
    print(b.length);
    print(bytes is List<int>);
  });
}

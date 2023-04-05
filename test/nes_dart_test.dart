import 'package:flutter_test/flutter_test.dart';
import 'package:nes_dart/nes_dart.dart';

void main() {
  test('run nestest', () async {
    final codeMap = <int, int>{};
    for (final code in NESCpuCodes.nesCpuCodes) {
      codeMap[code.opCode] = (codeMap[code.opCode] ?? 0) + 1;
    }
    codeMap.removeWhere((key, value) => value == 1);
    print(codeMap.keys.map((e) => e.toRadixString(16)));
    expect(
        NESCpuCodes.nesCpuCodeMapping.length, NESCpuCodes.nesCpuCodes.length);
    final rom = await NESRomLoader.loadFromPath('roms/nestest.nes');
    print(rom);
    final emulator = NESEmulator(rom: rom);
    emulator.run();
    final prg = emulator.rom.prgRom;
    bool error = false;
    for (int i = 0; i < prg.length;) {
      final byte = prg[i];
      final op = NESCpuCodes.getOP(byte);
      if (op.op == NESOp.error) {
        error = true;
        print('错误: ${byte.toRadixString(16)}');
        break;
      }
      final stringBuffer = StringBuffer(
          '${i.toRadixString(16).toUpperCase().padLeft(4, '0')}: ${op.op.name}');
      for (int d = 1; d < op.size; d++) {
        final byte = prg[i + d].toRadixString(16).toUpperCase();
        stringBuffer.write(' ');
        stringBuffer.write(byte);
      }
      print(stringBuffer.toString());
      i += op.size;
    }
    expect(error, false);
  });
}

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
    emulator.run();

    // 输出指令
    final prg = emulator.rom.prgRom;
    bool error = false;
    const addressPRGRom = NESMapper000.addressPRGRom;
    for (int i = 0; i < prg.length;) {
      final address = addressPRGRom + i;
      final byte = emulator.mapper.read(address);
      final op = NESCpuCodes.getOP(byte);

      if (op.op == NESOp.error) {
        error = true;
        print('错误: ${byte.toRadixString(16)}');
        break;
      }

      final stringBuffer = StringBuffer();
      final addressStr =
          address.toRadixString(16).toUpperCase().padLeft(4, '0');
      stringBuffer.write(addressStr);
      stringBuffer.write(': ');
      stringBuffer.write(op.op.name);
      if (op.size > 1) {
        String value = emulator.mapper
            .read(address + 1)
            .toRadixString(16)
            .toUpperCase()
            .padLeft(2, '0');
        if (op.size == 3) {
          value = emulator.mapper
              .read16(address + 1)
              .toRadixString(16)
              .toUpperCase()
              .padLeft(2, '0');
        }
        stringBuffer.write(' ');
        stringBuffer.write(value);
      }
      print(stringBuffer.toString());
      i += op.size;
    }
    expect(error, false);
  });
}

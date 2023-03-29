part of 'nes_rom_loader.dart';

/// ROM
class NESRom {
  /// 是否是NES2.0
  final bool nes20Format;

  NESRom._create({
    required this.nes20Format,
  });

  @override
  String toString() {
    return 'NESRom {\n'
        '\tnes20Format: $nes20Format\n'
        '}';
  }
}

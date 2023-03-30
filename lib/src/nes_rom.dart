import 'dart:typed_data';

/// NES版本
enum NESVersion {
  nes10,
  nes20,
}

/// 镜像类型
enum NESMirrorType {
  horizontal,
  vertical,
}

/// 控制台类型
enum NESConsoleType {
  // Nintendo Entertainment System/Family Computer
  nesc,
  // Nintendo Vs. System
  nvs,
  // Nintendo Playchoice 10
  np10,
  // Extended Console Type
  ect,
}

/// PRG区块大小
const kPRGChunkSize = 16 * 1024;

/// CHR区块大小
const kCHRChunkSize = 8 * 1024;

/// ROM
class NESRom {
  /// 文件大小
  final int fileSize;

  /// NES版本
  final NESVersion version;

  /// PRG-ROM大小
  final int prgCount;

  /// CHR-ROM大小
  final int chrCount;

  /// 镜像类型
  final NESMirrorType mirrorType;

  /// 是否有SRAM,$6000-$7FFF
  final bool hasSRAM;

  /// 是否有Trainer,$6000-$71FF
  final bool hasTrainer;

  /// 是否四屏模式,为true忽略[mirrorType]
  final bool fourScreenMode;

  /// 控制台类型
  final NESConsoleType consoleType;

  /// Mapper Number
  final int mapperNumber;

  /// PRG-ROM
  final Uint8List? prgRom;

  /// CHR-ROM
  final Uint8List? chrRom;

  NESRom._create({
    required this.fileSize,
    required this.version,
    required this.prgCount,
    required this.chrCount,
    required this.mirrorType,
    required this.hasSRAM,
    required this.hasTrainer,
    required this.fourScreenMode,
    required this.consoleType,
    required this.mapperNumber,
    required this.prgRom,
    required this.chrRom,
  });

  @override
  String toString() {
    return 'NESRom {\n'
        '\tfileSize: $fileSize\n'
        '\tversion: ${version.name}\n'
        '\tPRG-ROM: $prgCount*16KiB\n'
        '\tCHR-ROM: $chrCount*8KiB\n'
        '\tmirrorType: ${mirrorType.name}\n'
        '\thasSRAM: $hasSRAM\n'
        '\thasTrainer: $hasTrainer\n'
        '\tfourScreenMode: $fourScreenMode\n'
        '\tconsoleType: ${consoleType.name}\n'
        '\tmapperNumber: $mapperNumber\n'
        '}';
  }
}

/// ROM Builder
class NESRomBuilder {
  int fileSize = 0;
  NESVersion version = NESVersion.nes10;
  int prgCount = 0;
  int chrCount = 0;
  NESMirrorType mirrorType = NESMirrorType.horizontal;
  bool hasSRAM = false;
  bool hasTrainer = false;
  bool fourScreenMode = false;
  NESConsoleType consoleType = NESConsoleType.nesc;
  int _mapperNumber = 0;
  Uint8List? prgRom;
  Uint8List? chrRom;

  set mapperNumber(int value) => _mapperNumber |= value;

  /// 构建ROM
  NESRom build() {
    return NESRom._create(
      fileSize: fileSize,
      version: version,
      prgCount: prgCount,
      chrCount: chrCount,
      mirrorType: mirrorType,
      hasSRAM: hasSRAM,
      hasTrainer: hasTrainer,
      fourScreenMode: fourScreenMode,
      consoleType: consoleType,
      mapperNumber: _mapperNumber,
      prgRom: prgRom,
      chrRom: chrRom,
    );
  }
}

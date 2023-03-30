/// NES版本
enum NESVersion {
  nes10,
  nes20,
}

///
enum NESNameTableMirrorType {
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

/// ROM
class NESRom {
  /// NES版本
  final NESVersion version;

  /// PRG-ROM大小
  final int prgCount;
  final int prgSize;

  /// CHR-ROM大小
  final int chrCount;
  final int chrSize;

  ///
  final NESNameTableMirrorType nameTableMirrorType;

  /// 是否有电池
  final bool hasBattery;

  /// 是否有Trainer
  final bool hasTrainer;

  /// 是否四屏模式
  final bool fourScreenMode;

  /// 控制台类型
  final NESConsoleType consoleType;

  NESRom._create({
    required this.version,
    required this.prgCount,
    required this.prgSize,
    required this.chrCount,
    required this.chrSize,
    required this.nameTableMirrorType,
    required this.hasBattery,
    required this.hasTrainer,
    required this.fourScreenMode,
    required this.consoleType,
  });

  @override
  String toString() {
    return 'NESRom {\n'
        '\tversion: ${version.name}\n'
        '\tPRG-ROM size: $prgCount*${0x4000}=$prgSize\n'
        '\tCHR-ROM size: $chrCount*${0x2000}=$chrSize\n'
        '\tnameTableMirrorType: ${nameTableMirrorType.name}\n'
        '\thasBattery: $hasBattery\n'
        '\thasTrainer: $hasTrainer\n'
        '\tfourScreenMode: $fourScreenMode\n'
        '\tconsoleType: ${consoleType.name}\n'
        '}';
  }
}

/// ROM Builder
class NESRomBuilder {
  NESVersion _version = NESVersion.nes10;
  int _prgCount = 0;
  int _chrCount = 0;
  NESNameTableMirrorType _nameTableMirrorType =
      NESNameTableMirrorType.horizontal;
  bool _hasBattery = false;
  bool _hasTrainer = false;
  bool _fourScreenMode = false;
  NESConsoleType _consoleType = NESConsoleType.nesc;

  set version(NESVersion value) => _version = value;

  set prgCount(int value) => _prgCount = value;

  set chrCount(int value) => _chrCount = value;

  set nameTableMirrorType(NESNameTableMirrorType value) =>
      _nameTableMirrorType = value;

  set hasBattery(bool value) => _hasBattery = value;

  set hasTrainer(bool value) => _hasTrainer = value;

  set fourScreenMode(bool value) => _fourScreenMode = value;

  set consoleType(NESConsoleType value) => _consoleType = value;

  /// 构建ROM
  NESRom build() {
    return NESRom._create(
      version: _version,
      prgCount: _prgCount,
      prgSize: _prgCount * 0x4000,
      chrCount: _chrCount,
      chrSize: _chrCount * 0x2000,
      nameTableMirrorType: _nameTableMirrorType,
      hasBattery: _hasBattery,
      hasTrainer: _hasTrainer,
      fourScreenMode: _fourScreenMode,
      consoleType: _consoleType,
    );
  }
}

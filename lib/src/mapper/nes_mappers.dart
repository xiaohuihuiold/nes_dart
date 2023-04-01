part of 'nes_mapper.dart';

/// Mapper000
/// PRG-ROM容量: 16KiB或者32KiB
///
/// | 地址范围     | 大小  | 描述                |
/// | :---------: | :---: | :----------------: |
/// | $4020-$5FFF | $1FDF | 扩展ROM             |
/// | $6000-$7FFF | $1FFF | SRAM               |
/// | $8000-$FFFF | $7FFF | PRG-ROM            |
class NESMapper000 extends NESMapper {
  /// PRG-ROM起始地址
  static const addressPRGRom = 0x8000;

  NESMapper000(super.emulator);

  @override
  void reset() {
    super.reset();
    _loadPRGRom();
  }

  @override
  void write(int address, int value) {
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      _memory.write(address & NESMapper.maskRAM, value);
    }
  }

  @override
  int read(int address) {
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      return _memory.read(address & NESMapper.maskRAM);
    }
    return _memory.read(address);
  }

  void _loadPRGRom() {
    logger.v('加载PRG-ROM...');
    final bankCount = emulator.rom.prgCount;
    if (bankCount == 1) {
      _load16KiBRomBank(0, addressPRGRom);
      _load16KiBRomBank(0, addressPRGRom + Constants.byte16KiB);
    } else if (bankCount > 1) {
      _load16KiBRomBank(0, addressPRGRom);
      _load16KiBRomBank(1, addressPRGRom + Constants.byte16KiB);
    } else {
      throw Exception('没有PRG-ROM');
    }
    logger.v('PRG-ROM已加载');
  }

  void _load16KiBRomBank(int bank, int address) {
    final start = bank * Constants.byte16KiB;
    _memory.writeAll(
      address,
      emulator.rom.prgRom,
      start: start,
      end: start + Constants.byte16KiB,
    );
  }
}

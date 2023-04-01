import 'package:flutter/foundation.dart';
import 'package:nes_dart/src/logger.dart';

import 'constants.dart';
import 'nes_memory.dart';
import 'nes_emulator.dart';

/// Mapper
///
/// | 地址范围     | 大小  | 描述                |
/// | :---------: | :---: | :----------------: |
/// | $0000-$07FF | $0800 | 2KiB RAM           |
/// | $0800-$0FFF | $0800 | $0000-$07FF的镜像   |
/// | $1000-$17FF | $0800 | $0000-$07FF的镜像   |
/// | $1800-$1FFF | $0800 | $0000-$07FF的镜像   |
/// | $2000-$2007 | $0008 | PPU的寄存器         |
/// | $2008-$3FFF | $1FF8 | $2000-$2007的镜像   |
/// | $4000-$4017 | $0018 | APU和IO寄存器       |
/// | $4018-$401F | $0008 | APU和IO相关         |
/// | $4020-$FFFF | $BFE0 | 卡带空间            |
abstract class NESMapper {
  /// RAM地址mask
  static const maskRAM = 0x07FF;

  /// RAM最大地址
  static const maxRAMAddress = 0x1FFF;

  /// 模拟器
  final NESEmulator emulator;

  /// 内存
  final _memory = NESMemory();

  NESMapper(this.emulator);

  /// 重置
  @mustCallSuper
  void reset() {
    _memory.reset();
  }

  /// 写入数据
  void write(int address, int value) {
    _memory.write(address, value);
  }

  /// 读取数据
  int read(int address) {
    return _memory.read(address);
  }

  /// 写入数据
  void write16(int address, int value) {
    _memory.write16(address, value);
  }

  /// 读取数据
  int read16(int address) {
    return _memory.read16(address);
  }
}

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
    } else {
      super.write(address, value);
    }
  }

  @override
  int read(int address) {
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      return _memory.read(address & NESMapper.maskRAM);
    } else {
      return super.read(address);
    }
  }

  @override
  void write16(int address, int value) {
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      _memory.write16(address & NESMapper.maskRAM, value);
    } else {
      super.write16(address, value);
    }
  }

  @override
  int read16(int address) {
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      return _memory.read16(address & NESMapper.maskRAM);
    } else {
      return super.read16(address);
    }
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

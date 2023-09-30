import 'package:flutter/foundation.dart';

import 'logger.dart';
import 'constants.dart';
import 'nes_memory.dart';
import 'nes_emulator.dart';
import 'nes_cpu.dart';
import 'nes_ppu_registers.dart';

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

  /// PPU地址mask
  static const maskPPU = 0x2007;

  /// PPU结束地址
  static const maxPPUAddress = 0x3FFF;

  /// 栈地址
  static const minStackAddress = 0x100;

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

  int readU8(int address) {
    return _memory.readU8(address);
  }

  void writeU8(int address, int value) {
    _memory.writeU8(address, value);
  }

  int read8(int address) {
    return _memory.read8(address);
  }

  void write8(int address, int value) {
    _memory.write8(address, value);
  }

  int readU16(int address) {
    return _memory.readU16(address);
  }

  void writeU16(int address, int value) {
    _memory.writeU16(address, value);
  }

  int read16(int address) {
    return _memory.read16(address);
  }

  void write16(int address, int value) {
    _memory.write16(address, value);
  }

  /// 获取中断地址
  int readInterruptAddress(NESCpuInterrupt interrupt) {
    return _memory.readU16(interrupt.address);
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

  /// CHR-ROM起始地址,在PPU
  static const addressCHRRom = 0x0000;

  NESMapper000(super.emulator);

  @override
  void reset() {
    super.reset();
    _loadPRGRom();
    _loadCHRRom();
  }

  @override
  int readU8(int address) {
    _printRead(address);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      return _memory.readU8(address & NESMapper.maskRAM);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      return _regPPUReadU8(address & NESMapper.maskPPU);
    } else {
      return super.readU8(address);
    }
  }

  @override
  void writeU8(int address, int value) {
    _printWrite(address, value);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      _memory.writeU8(address & NESMapper.maskRAM, value);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      _regPPUWriteU8(address & NESMapper.maskPPU, value);
    } else {
      super.writeU8(address, value);
    }
  }

  @override
  int read8(int address) {
    _printRead(address);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      return _memory.read8(address & NESMapper.maskRAM);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      return _regPPURead8(address & NESMapper.maskPPU);
    } else {
      return super.read8(address);
    }
  }

  @override
  void write8(int address, int value) {
    _printWrite(address, value);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      _memory.write8(address & NESMapper.maskRAM, value);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      _regPPUWrite8(address & NESMapper.maskPPU, value);
    } else {
      super.write8(address, value);
    }
  }

  @override
  int readU16(int address) {
    _printRead(address);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      return _memory.readU16(address & NESMapper.maskRAM);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      return _regPPUReadU16(address & NESMapper.maskPPU);
    } else {
      return super.readU16(address);
    }
  }

  @override
  void writeU16(int address, int value) {
    _printWrite(address, value);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      _memory.writeU16(address & NESMapper.maskRAM, value);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      _regPPUWriteU16(address & NESMapper.maskPPU, value);
    } else {
      super.writeU16(address, value);
    }
  }

  @override
  int read16(int address) {
    _printRead(address);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      return _memory.read16(address & NESMapper.maskRAM);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      return _regPPURead16(address & NESMapper.maskPPU);
    } else {
      return super.read16(address);
    }
  }

  @override
  void write16(int address, int value) {
    _printWrite(address, value);
    if (address <= NESMapper.maxRAMAddress) {
      // $2000以下的地址映射到$0000-$07FF
      _memory.write16(address & NESMapper.maskRAM, value);
    } else if (address <= NESMapper.maxPPUAddress) {
      // $2000-$3FFF 映射到PPU寄存器
      _regPPUWrite16(address & NESMapper.maskPPU, value);
    } else {
      super.write16(address, value);
    }
  }

  /// PPU寄存器写入
  void _regPPUWriteU8(int address, int value) {
    _regPPUWrite(address, value);
    _memory.writeU8(address, value);
  }

  /// PPU寄存器读取
  int _regPPUReadU8(int address) {
    return _regPPURead(address);
  }

  /// PPU寄存器写入
  void _regPPUWrite8(int address, int value) {
    _regPPUWrite(address, value);
    _memory.write8(address, value);
  }

  /// PPU寄存器读取
  int _regPPURead8(int address) {
    return _regPPURead(address);
  }

  /// PPU寄存器写入
  void _regPPUWriteU16(int address, int value) {
    _regPPUWrite(address, value);
    _memory.writeU16(address, value);
  }

  /// PPU寄存器读取
  int _regPPUReadU16(int address) {
    return _regPPURead(address);
  }

  /// PPU寄存器写入
  void _regPPUWrite16(int address, int value) {
    _regPPUWrite(address, value);
    _memory.write16(address, value);
  }

  /// PPU寄存器读取
  int _regPPURead16(int address) {
    return _regPPURead(address);
  }

  /// PPU寄存器写入
  void _regPPUWrite(int address, int value) {
    if (address == NESPpuRegister.ctrl.address) {
      emulator.ppu.registers.ctrl = value;
    } else if (address == NESPpuRegister.status.address) {
      emulator.ppu.registers.status = value;
    } else if (address == NESPpuRegister.vramPointer.address) {
      // 写显存指针
      if (emulator.ppu.registers.vramPointerFirst) {
        emulator.ppu.registers.vramPointerFirst = false;
        emulator.ppu.registers.vramPointer = (value & 0xFF) << 8;
      } else {
        emulator.ppu.registers.vramPointerFirst = true;
        emulator.ppu.registers.vramPointer |= (value & 0xFF);
      }
    } else if (address == NESPpuRegister.vramData.address) {
      // 写显存数据
      emulator.ppu.writeU8(emulator.ppu.registers.vramPointer, value);
    }
  }

  /// PPU寄存器读取
  int _regPPURead(int address) {
    int value = 0;
    if (address == NESPpuRegister.status.address) {
      value = emulator.ppu.registers.status;
      emulator.ppu.endVBlank();
    } else if (address == NESPpuRegister.status.address) {
      value = emulator.ppu.registers.status;
    } else if (address == NESPpuRegister.vramPointer.address) {
      // 读显存指针,不一定会用到
      value = emulator.ppu.registers.vramPointer;
    } else if (address == NESPpuRegister.vramData.address) {
      // 读显存数据
      value = emulator.ppu.readU8(emulator.ppu.registers.vramPointer);
    }
    return value;
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

  /// 加载PRG-ROM
  /// Mapper000容量16KiB或者32KiB,所以一次加载16KiB
  void _load16KiBRomBank(int bank, int address) {
    final start = bank * Constants.byte16KiB;
    _memory.writeAll(
      address,
      emulator.rom.prgRom,
      start: start,
      end: start + Constants.byte16KiB,
    );
  }

  void _loadCHRRom() {
    logger.v('加载CHR-ROM');
    final bankCount = emulator.rom.chrCount;
    if (bankCount == 1) {
      _load8KiBVRomBank(0, addressCHRRom);
    }
    logger.v('CHR-ROM已加载');
  }

  /// 加载CHR-ROM
  /// PPU前8KiB是CHR-ROM区域
  void _load8KiBVRomBank(int bank, int address) {
    final start = bank * Constants.byte8KiB;
    emulator.ppu.writeAll(
      address,
      emulator.rom.chrRom,
      start: start,
      end: start + Constants.byte8KiB,
    );
  }

  /// 打印读消息
  void _printRead(int address) {
    if (emulator.logMemory) {
      logger
          .v('R: \$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}');
    }
  }

  /// 打印写消息
  void _printWrite(int address, int value) {
    if (emulator.logMemory) {
      logger.v('W: '
          '\$${address.toRadixString(16).toUpperCase().padLeft(4, '0')}'
          '='
          '${value.toRadixString(16).toUpperCase()}');
    }
  }
}

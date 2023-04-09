import 'nes_memory.dart';
import 'nes_emulator.dart';
import 'logger.dart';

/// PPU
///
/// | 地址范围     | 大小  | 描述                |
/// | :---------: | :---: | :----------------: |
/// | $0000-$0FFF | $1000 | Pattern table 0    |
/// | $1000-$1FFF | $1000 | Pattern table 1    |
/// | $2000-$23FF | $0400 | 名称表0             |
/// | $2400-$27FF | $0400 | 名称表1             |
/// | $2800-$2BFF | $0400 | 名称表2             |
/// | $2C00-$2FFF | $0400 | 名称表3             |
/// | $3000-$3EFF | $0F00 | $2000-$2EFF的镜像   |
/// | $3F00-$3F1F | $0020 | 调色板索引          |
/// | $3F20-$3FFF | $00E0 | $3F00-$3F1F的镜像   |
/// | $3F20-$3FFF | $00E0 | $3F00-$3F1F的镜像   |
/// | $4000-$FFFF | $BFFF | $0000-$3FFF的镜像   |
class NESPpu {
  /// VRAM
  final _memory = NESMemory();

  /// 模拟器
  final NESEmulator emulator;

  NESPpu(this.emulator);

  /// 重置
  void reset() {
    _memory.reset();
    logger.v('PPU已重置');
  }
}

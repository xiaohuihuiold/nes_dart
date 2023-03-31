import 'nes_mapper.dart';

/// Mapper实现
///
/// | 地址范围     | 大小  | 描述                |
/// | :---------: | :---: | :----------------: |
/// | $4020-$5FFF | $1FDF | 扩展ROM             |
/// | $6000-$7FFF | $1FFF | SRAM               |
/// | $8000-$FFFF | $7FFF | PRG-ROM            |
class NESMapper000 extends NESMapper {
  NESMapper000(super.emulator);
}

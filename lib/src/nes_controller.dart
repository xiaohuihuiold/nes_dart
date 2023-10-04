import 'nes_emulator.dart';

/// 按键
enum NESControllerKey {
  a,
  b,
  select,
  start,
  up,
  down,
  left,
  right,
}

/// 玩家
enum NESPlayer {
  player1,
  player2,
}

/// 控制器
class NESController {
  /// 模拟器
  final NESEmulator emulator;

  int _input1Index = 0;
  int _input2Index = 0;

  /// 手柄1
  List<int> _input1 = List.filled(8, 0);

  /// 手柄2
  List<int> _input2 = List.filled(8, 0);

  NESController(this.emulator);

  void reset() {
    _input1Index = 0;
    _input2Index = 0;
    _input1 = List.filled(8, 0);
    _input2 = List.filled(8, 0);
  }

  void resetIndex() {
    _input1Index = 0;
    _input2Index = 0;
  }

  List<int> _getInput(NESPlayer player) {
    return switch (player) {
      NESPlayer.player1 => _input1,
      NESPlayer.player2 => _input2,
    };
  }

  void onKeyDown(NESPlayer player, NESControllerKey key) {
    final input = _getInput(player);
    input[key.index] = 1;
  }

  void onKeyUp(NESPlayer player, NESControllerKey key) {
    final input = _getInput(player);
    input[key.index] = 0;
  }

  int getInputState(NESPlayer player) {
    int value = 0;
    switch (player) {
      case NESPlayer.player1:
        value = _input1[_input1Index];
        _input1Index++;
        if (_input1Index >= 8) {
          _input1Index = 0;
        }
        break;
      case NESPlayer.player2:
        value = _input1[_input2Index];
        _input2Index++;
        if (_input2Index >= 8) {
          _input2Index = 0;
        }
        break;
    }
    return value;
  }
}

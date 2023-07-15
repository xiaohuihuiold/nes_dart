import 'package:flutter/material.dart';

import 'nes_emulator.dart';

/// 显示
class NESView extends StatefulWidget {
  /// 模拟器
  final NESEmulator emulator;

  const NESView({
    super.key,
    required this.emulator,
  });

  @override
  State<NESView> createState() => _NESViewState();
}

class _NESViewState extends State<NESView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

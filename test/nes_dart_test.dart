import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nes_dart/nes_dart.dart';

void main() {
  test('run nestest', () {
    final emulator =
        NESEmulator(bytes: File('../roms/nestest.nes').readAsBytesSync());
    emulator.load();
  });
}

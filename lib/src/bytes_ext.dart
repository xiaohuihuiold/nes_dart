import 'dart:typed_data';

import 'constants.dart';

/// ByteData扩展
extension ByteDataExt on ByteData {
  String getString(int offset, [int? end]) {
    end ??= buffer
        .asUint8List()
        .indexWhere((element) => element == Constants.eof, offset);
    if (end == -1) {
      end = null;
    }
    return String.fromCharCodes(buffer.asUint8List(), offset, end);
  }

  Uint8List getUint8List(int offset, [int? end]) {
    return buffer.asUint8List(offset, end == null ? null : end - offset);
  }

  void setUint8List(int offset, List<int> bytes, {int start = 0, int? end}) {
    final length = end == null ? null : end - start;
    for (int i = offset; i < offset + (length ?? bytes.length); i++) {
      setUint8(i, bytes[i - offset + start]);
    }
  }
}

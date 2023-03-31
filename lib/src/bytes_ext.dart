import 'dart:typed_data';

/// EOF
const _eof = 0x1A;

/// ByteData扩展
extension ByteDataExt on ByteData {
  String getString(int offset, [int? end]) {
    end ??=
        buffer.asUint8List().indexWhere((element) => element == _eof, offset);
    if (end == -1) {
      end = null;
    }
    return String.fromCharCodes(buffer.asUint8List(), offset, end);
  }

  Uint8List getUint8List(int offset, [int? end]) {
    return buffer.asUint8List(offset, end == null ? null : end - offset);
  }

  void setUint8List(int offset, List<int> bytes) {
    for (int i = offset; i < offset + bytes.length; i++) {
      setUint8(i, bytes[i - offset]);
    }
  }
}

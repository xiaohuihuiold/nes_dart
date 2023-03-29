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
}

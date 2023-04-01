/// 常量
class Constants {
  /// 大小
  static const byte1KiB = 1024;
  static const byte2KiB = 2 * byte1KiB;
  static const byte4KiB = 4 * byte1KiB;
  static const byte8KiB = 8 * byte1KiB;
  static const byte16KiB = 16 * byte1KiB;
  static const byte32KiB = 32 * byte1KiB;
  static const byte64KiB = 64 * byte1KiB;

  /// 文件头
  static const fileHeader = 'NES';

  /// EOF
  static const eof = 0x1A;
  static const eofString = '\x1A';
}

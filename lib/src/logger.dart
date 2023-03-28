import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:logger/logger.dart';

final logger = LoggerWrapper();

/// 自定义日志
class LoggerWrapper {
  final logger = Logger(
    printer: HybridPrinter(_MySimplePrinter()),
  );

  void nope() {}

  void v(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(Level.verbose, message, error: error, stackTrace: stackTrace);
  }

  void d(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(Level.debug, message, error: error, stackTrace: stackTrace);
  }

  void i(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(Level.info, message, error: error, stackTrace: stackTrace);
  }

  void w(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(Level.warning, message, error: error, stackTrace: stackTrace);
  }

  void e(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(Level.error, message, error: error, stackTrace: stackTrace);
  }

  void wtf(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(Level.wtf, message, error: error, stackTrace: stackTrace);
  }

  void log(
    Level level,
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    logger.log(level, message, error, stackTrace);
  }
}

/// 自定义简单日志
class _MySimplePrinter extends SimplePrinter {
  static final grey = AnsiColor.fg(8);
  static final timeFormat = [HH, ':', nn, ':', ss];

  _MySimplePrinter() : super(printTime: true, colors: true);

  @override
  List<String> log(LogEvent event) {
    var messageStr = _stringifyMessage(event.message);
    var errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    var timeStr = printTime ? grey(formatDate(event.time, timeFormat)) : '';
    return ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];
  }

  String _labelFor(Level level) {
    var prefix = SimplePrinter.levelPrefixes[level]!;
    var color = SimplePrinter.levelColors[level]!;
    return colors ? color(prefix) : prefix;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = const JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}

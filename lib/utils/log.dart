
import 'package:logger/logger.dart';

class Log {

  final String _name;
  final Logger _logger;

  Log(
    String name,
    {LogFilter? filter,
    LogPrinter? printer,
    LogOutput? output,
    Level? level,
  }) : _name = name,
    _logger = Logger(
      filter: filter, 
      printer: printer, 
      output: output, 
      level: level
    );


  String get name {return _name;}


  void log(Level level, String message, [dynamic error, StackTrace? stackTrace]) {
    message = "[$_name] ${message.toString()}";

    void Function(String, [dynamic, StackTrace?])? function;

    switch (level) {
      
      case Level.verbose:
        function = _logger.v;
        break;
      case Level.debug:
        function = _logger.d;
        break;
      case Level.info:
        function = _logger.i;
        break;
      case Level.warning:
        function = _logger.w;
        break;
      case Level.error:
        function = _logger.e;
        break;
      case Level.wtf:
        function = _logger.wtf;
        break;
      case Level.nothing:
        function = null;
        break;
    }

    if (function != null) {
      if (error != null) {
        function(message, error, stackTrace);
      } else {
        function(message);
      }
    }


  }

  void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.verbose, message, error, stackTrace);
  }

  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.debug, message, error, stackTrace);
  }

  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.info, message, error, stackTrace);
  }

  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.warning, message, error, stackTrace);
  }

  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.error, message, error, stackTrace);
  }

  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.wtf, message, error, stackTrace);
  }

  



}
class Logger {
  static bool _isDebugEnabled = true;

  static void enableDebugLogging(bool enable) {
    _isDebugEnabled = enable;
  }

  static void d(String message) {
    if (_isDebugEnabled) {
      _log('DEBUG', message);
    }
  }

  static void e(String message) {
    if (_isDebugEnabled) {
      _log('ERROR', message);
    }
  }

  static void i(String message) {
    if (_isDebugEnabled) {
      _log('INFO', message);
    }
  }

  static void w(String message) {
    if (_isDebugEnabled) {
      _log('WARNING', message);
    }
  }

  static void _log(String level, String message) {
    print('$level: $message');
  }
}

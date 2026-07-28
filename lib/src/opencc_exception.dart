/// Exception thrown when an OpenCC operation fails.
class OpenCCException implements Exception {
  /// The error message.
  final String message;

  /// Optional underlying error code.
  final int? code;

  const OpenCCException(this.message, {this.code});

  @override
  String toString() {
    if (code != null) {
      return 'OpenCCException($code): $message';
    }
    return 'OpenCCException: $message';
  }
}

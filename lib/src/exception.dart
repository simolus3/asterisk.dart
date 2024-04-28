import 'definitions/common.dart';

/// Superclass for Asterisk-specific exceptions thrown by this package.
///
/// In addition to this exception, subclasses of [Error] may be thrown for
/// fatal errors. Also, I/O errors related to network errors in HTTP requests
/// are not wrapped into an [AsteriskException] and are instead rethrown
/// directly.
sealed class AsteriskException implements Exception {}

/// An exception thrown when an asterisk API call returns a status code
/// indicating that the request has failed.
final class AsteriskHttpException implements AsteriskException {
  /// The original request URI for which the request has failed.
  final Uri requestUri;

  /// The returned status code.
  final int status;

  /// The returned reason phrase from the response.
  final String? reasonPhrase;

  /// The body of the error response if it's valid JSON.
  final JsonObject? response;

  AsteriskHttpException({
    required this.requestUri,
    required this.status,
    this.reasonPhrase,
    this.response,
  });

  @override
  String toString() {
    return 'Error $reasonPhrase $status to $requestUri: $response';
  }
}

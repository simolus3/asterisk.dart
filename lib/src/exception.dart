import 'definitions/common.dart';

/// An exception thrown when an asterisk API call returns a status code
/// indicating that the request has failed.
final class AsteriskHttpException implements Exception {
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

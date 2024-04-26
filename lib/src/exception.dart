import 'definitions/common.dart';

final class AsteriskHttpException implements Exception {
  final Uri requestUri;
  final int status;
  final String? reasonPhrase;
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

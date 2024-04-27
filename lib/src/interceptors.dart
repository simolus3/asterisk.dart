@internal
library;

import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'definitions/common.dart';
import 'exception.dart';

final class AddHeaders with BaseClient {
  final Client _inner;
  final Map<String, String> _addHeaders;

  AddHeaders(this._inner, {required Map<String, String> headers})
      : _addHeaders = headers;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    _addHeaders.forEach((key, value) {
      request.headers.putIfAbsent(key, () => value);
    });

    return _inner.send(request);
  }

  @override
  void close() {
    return _inner.close();
  }
}

final class ThrowOnError with BaseClient {
  final Client _inner;

  ThrowOnError(this._inner);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode case >= 400 && <= 599) {
      JsonObject? body;
      if (response.headers['content-type'] == 'application/json') {
        try {
          body = await response.stream.transform(json.fuse(utf8).decoder).first
              as JsonObject?;
        } on Object {
          //
        }
      }

      throw AsteriskHttpException(
        requestUri: request.url,
        status: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        response: body,
      );
    }

    return response;
  }

  @override
  void close() {
    return _inner.close();
  }
}

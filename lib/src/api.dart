import 'dart:convert';

import 'package:http/http.dart';

import 'definitions/application.dart';
import 'definitions/bridge.dart';
import 'definitions/common.dart';
import 'definitions/endpoint.dart';
import 'definitions/playback.dart';
import 'definitions/recordings.dart';

List<T> Function(Object?) _decodeJsonList<T>(T Function(JsonObject) fromJson) {
  return (data) {
    return [for (final entry in data as List) fromJson(entry)];
  };
}

final class AsteriskApi {
  static final _jsonUtf8 = json.fuse(utf8);

  final Uri _baseUri;
  final Client _httpClient;

  AsteriskApi(this._baseUri, this._httpClient);

  late final BridgesApi bridges = BridgesApi(this);
  late final ChannelsApi channels = ChannelsApi(this);

  Future<StreamedResponse> _makeRequest({
    String method = 'GET',
    Map<String, String>? queryParameters,
    required String path,
  }) async {
    var uri = _baseUri.resolve(path);
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final request = Request(method, uri)
      ..headers['Accept'] = 'application/json';

    return await _httpClient.send(request);
  }

  Future<T> _jsonCall<T, J>({
    String method = 'GET',
    Map<String, String>? queryParameters,
    required String path,
    required T Function(J) fromJson,
  }) async {
    final response = await _makeRequest(
        path: path, method: method, queryParameters: queryParameters);
    return await response.stream
        .transform(_jsonUtf8.decoder)
        .cast<J>()
        .map(fromJson)
        .first;
  }

  // Applications

  Future<List<Application>> listApplications() {
    return _jsonCall(
        path: 'applications', fromJson: _decodeJsonList(Application.fromJson));
  }

  Future<Application> subscribe(String name, String eventSource) {
    return _jsonCall(
      method: 'POST',
      path: 'applications/$name/subscription',
      queryParameters: {'eventSource': eventSource},
      fromJson: Application.fromJson,
    );
  }

  Future<Application> unsubscribe(String name, String eventSource) {
    return _jsonCall(
      method: 'DELETE',
      path: 'applications/$name/subscription',
      queryParameters: {'eventSource': eventSource},
      fromJson: Application.fromJson,
    );
  }

  // Endpoints

  Future<List<Endpoint>> listEndpoints() {
    return _jsonCall(
        path: 'endpoints', fromJson: _decodeJsonList(Endpoint.fromJson));
  }
}

final class BridgesApi {
  final AsteriskApi _api;

  BridgesApi(this._api);

  Future<Bridge> createBridge({
    required String name,
    required String type,
  }) {
    return _api._jsonCall(
      path: 'bridges',
      method: 'POST',
      fromJson: Bridge.fromJson,
      queryParameters: {
        'name': name,
        'type': type,
      },
    );
  }

  Future<void> addChannel({
    required String bridge,
    required String channel,
    bool absorbDTMF = false,
    bool mute = false,
    bool inhibitConnectedLineUpdates = false,
  }) async {
    await _api._makeRequest(
      path: 'bridges/$bridge/addChannel',
      method: 'POST',
      queryParameters: {
        'channel': channel,
        'absorbDTMF': absorbDTMF.toString(),
        'mute': mute.toString(),
        'inhibitConnectedLineUpdates': inhibitConnectedLineUpdates.toString(),
      },
    );
  }

  Future<void> removeChannel({
    required String bridge,
    required String channel,
  }) async {
    await _api._makeRequest(
        path: 'bridges/$bridge/removeChannel',
        method: 'POST',
        queryParameters: {
          'channel': channel,
        });
  }

  Future<void> destroy(String bridge) async {
    await _api._makeRequest(
      path: 'bridges/$bridge',
      method: 'DELETE',
    );
  }
}

final class ChannelsApi {
  final AsteriskApi _api;

  ChannelsApi(this._api);

  Future<void> answer(String channel) async {
    await _api._makeRequest(path: 'channels/$channel/answer', method: 'POST');
  }

  Future<void> startRinging(String channel) async {
    await _api._makeRequest(path: 'channels/$channel/ring', method: 'POST');
  }

  Future<void> stopRinging(String channel) async {
    await _api._makeRequest(path: 'channels/$channel/ring', method: 'DELETE');
  }

  Future<void> hangup(String channel) async {
    await _api._makeRequest(path: 'channels/$channel', method: 'DELETE');
  }

  Future<Playback> play(String channel, String media) async {
    return await _api._jsonCall(
      path: 'channels/$channel/play',
      method: 'POST',
      queryParameters: {'media': media},
      fromJson: Playback.fromJson,
    );
  }

  Future<Recording> record(
    String channel, {
    required String name,
    required String format,
    required int maxDurationSeconds,
    required int maxSilenceSeconds,
    String ifExists = 'fail',
    bool beep = false,
    String terminateOn = 'none',
  }) async {
    return await _api._jsonCall(
      path: 'channels/$channel/record',
      method: 'POST',
      queryParameters: {
        'name': name,
        'format': format,
        'maxDurationSeconds': maxDurationSeconds.toString(),
        'maxSilenceSeconds': maxSilenceSeconds.toString(),
        'ifExists': ifExists,
        'beep': beep.toString(),
        'terminateOn': terminateOn,
      },
      fromJson: Recording.fromJson,
    );
  }
}

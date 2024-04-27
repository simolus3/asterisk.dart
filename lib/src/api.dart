import 'dart:convert';

import 'package:http/http.dart';

import 'definitions/application.dart';
import 'definitions/bridge.dart';
import 'definitions/channel.dart';
import 'definitions/common.dart';
import 'definitions/endpoint.dart';
import 'definitions/playback.dart';
import 'definitions/recordings.dart';

List<T> Function(Object?) _decodeJsonList<T>(T Function(JsonObject) fromJson) {
  return (data) {
    return [for (final entry in data as List) fromJson(entry)];
  };
}

/// Direct bindings to the Asterisk RESTful interface.
final class AsteriskApi {
  static final _jsonUtf8 = json.fuse(utf8);

  final Uri _baseUri;
  final Client _httpClient;

  AsteriskApi(this._baseUri, this._httpClient);

  /// Methods related to bridges: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Bridges_REST_API/
  late final BridgesApi bridges = BridgesApi(this);

  /// Methods related to channels: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/
  late final ChannelsApi channels = ChannelsApi(this);

  /// Methods related to recordings: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Recordings_REST_API/
  late final RecordingsApi recordings = RecordingsApi(this);

  Future<StreamedResponse> _makeRequest({
    String method = 'GET',
    Map<String, String>? queryParameters,
    required String path,
    String? body,
    Map<String, String>? headers,
  }) async {
    var uri = _baseUri.resolve(path);
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final request = Request(method, uri)
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.body = body;
    }
    if (headers != null) {
      request.headers.addAll(headers);
    }

    return await _httpClient.send(request);
  }

  Future<T> _jsonCall<T, J>({
    String method = 'GET',
    Map<String, String>? queryParameters,
    required String path,
    required T Function(J) fromJson,
    Object? body,
  }) async {
    final response = await _makeRequest(
      path: path,
      method: method,
      queryParameters: queryParameters,
      body: body != null ? json.encode(body) : null,
      headers: body != null ? {'Content-Type': 'application/json'} : null,
    );
    return await response.stream
        .transform(_jsonUtf8.decoder)
        .cast<J>()
        .map(fromJson)
        .first;
  }

  // Applications

  /// Lists all applications currently registered against this Asterisk server.
  Future<List<Application>> listApplications() {
    return _jsonCall(
        path: 'applications', fromJson: _decodeJsonList(Application.fromJson));
  }

  /// Subscribes an application to the given [eventSource].
  ///
  /// This package uses this on-demand to signal interest after a stream on a
  /// [LiveObject] is listened to.
  Future<Application> subscribe(String name, String eventSource) {
    return _jsonCall(
      method: 'POST',
      path: 'applications/$name/subscription',
      queryParameters: {'eventSource': eventSource},
      fromJson: Application.fromJson,
    );
  }

  /// Unsubscribes an application from the given [eventSource].
  ///
  /// This package uses this after subscriptions on a [LiveObject] stream are
  /// cancelled to avoid receiving superfluous messages.
  Future<Application> unsubscribe(String name, String eventSource) {
    return _jsonCall(
      method: 'DELETE',
      path: 'applications/$name/subscription',
      queryParameters: {'eventSource': eventSource},
      fromJson: Application.fromJson,
    );
  }

  // Endpoints

  /// Lists all endpoints currently known to Asterisk.
  Future<List<Endpoint>> listEndpoints() {
    return _jsonCall(
        path: 'endpoints', fromJson: _decodeJsonList(Endpoint.fromJson));
  }
}

/// Methods related to bridges: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Bridges_REST_API/
final class BridgesApi {
  final AsteriskApi _api;

  BridgesApi(this._api);

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Bridges_REST_API/#create
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

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Bridges_REST_API/#addchannel
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

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Bridges_REST_API/#removechannel
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

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Bridges_REST_API/#destroy
  Future<void> destroy(String bridge) async {
    await _api._makeRequest(
      path: 'bridges/$bridge',
      method: 'DELETE',
    );
  }
}

/// Methods related to channels: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/
final class ChannelsApi {
  final AsteriskApi _api;

  ChannelsApi(this._api);

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#create
  Future<Channel> createChannel({
    required String endpoint,
    required String app,
    String? appArgs,
    String? originator,
    String? channelId,
    String? otherChannelId,
    Iterable<String>? formats,
    Map<String, String>? variables,
  }) async {
    return _api._jsonCall(
      path: 'channels/create',
      fromJson: Channel.fromJson,
      method: 'POST',
      body: {
        'endpoint': endpoint,
        'app': app,
        if (appArgs != null) 'appArgs': appArgs,
        if (channelId != null) 'channelId': channelId,
        if (otherChannelId != null) 'otherChannelId': otherChannelId,
        if (originator != null) 'originator': originator,
        if (formats != null) 'formats': formats.join(','),
        if (variables != null) 'variables': variables,
      },
    );
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#answer
  Future<void> answer(String channel) async {
    await _api._makeRequest(path: 'channels/$channel/answer', method: 'POST');
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#answer
  Future<void> startRinging(String channel) async {
    await _api._makeRequest(path: 'channels/$channel/ring', method: 'POST');
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#ringstop
  Future<void> stopRinging(String channel) async {
    await _api._makeRequest(path: 'channels/$channel/ring', method: 'DELETE');
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#hangup
  Future<void> hangup(String channel) async {
    await _api._makeRequest(path: 'channels/$channel', method: 'DELETE');
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#dial
  Future<void> dial(String channel, int? timeoutInSeconds) async {
    await _api._makeRequest(
      path: 'channels/$channel/dial',
      method: 'POST',
      queryParameters: {
        if (timeoutInSeconds != null) 'timeout': timeoutInSeconds.toString(),
      },
    );
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#play
  Future<Playback> play(String channel, String media) async {
    return await _api._jsonCall(
      path: 'channels/$channel/play',
      method: 'POST',
      queryParameters: {'media': media},
      fromJson: Playback.fromJson,
    );
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#record
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

/// Methods related to recordings: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Recordings_REST_API/
class RecordingsApi {
  final AsteriskApi _api;

  RecordingsApi(this._api);

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Recordings_REST_API/#getstoredfile
  Future<StreamedResponse> storedContents(String recording) {
    return _api._makeRequest(path: 'recordings/stored/$recording/file');
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Recordings_REST_API/#deletestored
  Future<void> deleteStored(String recording) async {
    await _api._makeRequest(
        path: 'recordings/stored/$recording', method: 'DELETE');
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Recordings_REST_API/#deletestored
  Future<void> deleteLive(String recording) async {
    await _api._makeRequest(
        path: 'recordings/live/$recording', method: 'DELETE');
  }

  /// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Recordings_REST_API/#stop
  Future<void> stopAndStoreLive(String recording,
      {required String recordingName}) async {
    await _api._makeRequest(
      path: 'recordings/live/$recording/stop',
      method: 'POST',
      queryParameters: {'recordingName': recordingName},
    );
  }
}

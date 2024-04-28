import 'dart:convert';
import 'dart:io';

import 'package:asterisk/asterisk.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockServer {
  final int port;
  final Map<(String, String), Handler> _handlers = {};
  final List<WebSocketChannel> channels = [];
  HttpServer? _server;

  MockServer({required this.port});

  static Future<MockServer> open() async {
    Future<int> findFreeLocalPort() async {
      ServerSocket? serverSocket;
      try {
        serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        return serverSocket.port;
      } catch (e) {
        throw Exception('Failed to find a free local port: $e');
      } finally {
        serverSocket?.close();
      }
    }

    final port = await findFreeLocalPort();
    final server = MockServer(port: port);
    await server.start();
    return server;
  }

  Future<void> start() async {
    registerHandler('ari/events', 'GET',
        webSocketHandler((WebSocketChannel webSocket) {
      channels.add(webSocket);

      webSocket.stream.drain().then((value) {
        channels.remove(webSocket);
      });
    }));

    _server = await io.serve(
      (request) async {
        final handler = _handlers[(request.url.path, request.method)];
        if (handler == null) {
          return Response.internalServerError(body: 'Not found');
        } else {
          return handler(request);
        }
      },
      InternetAddress.loopbackIPv4,
      port,
    );
  }

  Future<void> stop() async {
    await _server?.close();
  }

  Asterisk createClient({
    String applicationName = 'test',
    String username = 'test',
    String password = 'test',
  }) {
    return Asterisk(
      baseUri: Uri(host: 'localhost', scheme: 'http', port: port),
      applicationName: applicationName,
      username: username,
      password: password,
    );
  }

  void broadcastMessage(Object? message) {
    final encoded = jsonEncode(message);
    for (final channel in channels) {
      channel.sink.add(encoded);
    }
  }

  void registerHandler(String path, String method, Handler handler) {
    _handlers[(path, method)] = handler;
  }

  static Response json(Object? data, {int statusCode = 200}) {
    return Response(
      statusCode,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Map<String, Object?> event(Map<String, Object?> data) {
    return {
      'asterisk_id': 'mock',
      'application': 'demo',
      'timestamp': DateTime.now().toIso8601String(),
      ...data,
    };
  }
}

Map<String, Object?> testChannel = {
  'id': 'test-channel',
  'protocol_id': 'test',
  'name': 'test-channel',
  'state': 'Up',
  'caller': {'name': 'test', 'number': '1234'},
  'connected': {'name': 'test', 'number': '1234'},
  'accountcode': '',
  'dialplan': {
    'context': 'foo',
    'exten': '4321',
    'priority': 123,
    'app_name': '',
    'app_data': '',
  },
  'creationtime': DateTime.now().toIso8601String(),
  'language': 'en',
};

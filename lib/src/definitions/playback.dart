import 'package:json_annotation/json_annotation.dart';

import '../event/source.dart';
import 'common.dart';

part '../generated/definitions/playback.g.dart';

enum PlaybackState { queued, playing, continuing, done, failed }

@JsonSerializable()
final class Playback implements EventSource {
  final String id;
  final String mediaUri;
  final String? nextMediaUri;
  final String targetUri;
  final String language;
  final PlaybackState state;

  Playback({
    required this.id,
    required this.mediaUri,
    required this.nextMediaUri,
    required this.targetUri,
    required this.language,
    required this.state,
  });

  factory Playback.fromJson(JsonObject json) => _$PlaybackFromJson(json);

  @override
  EventSourceDescription get description =>
      EventSourceDescription(kind: 'playback', id: id);
}

final class MediaSource {
  final Uri uri;

  MediaSource({required this.uri});

  MediaSource.sound(String id) : uri = Uri(scheme: 'sound', path: id);
  MediaSource.digits(String digits) : uri = Uri(scheme: 'digits', path: digits);
}

import 'package:json_annotation/json_annotation.dart';

import '../event/source.dart';
import 'common.dart';

part '../generated/definitions/recordings.g.dart';

enum RecordingState { queued, recording, paused, done, failed, canceled }

@JsonSerializable()
final class Recording implements EventSource {
  final String name;
  final String format;
  final String targetUri;
  final RecordingState state;
  @JsonKey(fromJson: _durationFromSecs, toJson: _secsFromDuration)
  final Duration? duration;
  @JsonKey(fromJson: _durationFromSecs, toJson: _secsFromDuration)
  final Duration? talkingDuration;
  @JsonKey(fromJson: _durationFromSecs, toJson: _secsFromDuration)
  final Duration? silenceDuration;
  final String? cause;

  Recording({
    required this.name,
    required this.format,
    required this.targetUri,
    required this.state,
    required this.duration,
    required this.talkingDuration,
    required this.silenceDuration,
    required this.cause,
  });

  factory Recording.fromJson(JsonObject json) => _$RecordingFromJson(json);

  @override
  EventSourceDescription get description =>
      EventSourceDescription(kind: 'recording', id: name);

  static Duration? _durationFromSecs(int? secs) {
    return secs != null ? Duration(seconds: secs) : null;
  }

  static int? _secsFromDuration(Duration? duration) {
    return duration?.inSeconds;
  }
}

@JsonSerializable()
final class StoredRecording {
  final String name;
  final String format;

  StoredRecording({required this.name, required this.format});

  factory StoredRecording.fromJson(JsonObject json) =>
      _$StoredRecordingFromJson(json);
}

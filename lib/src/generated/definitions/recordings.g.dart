// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../definitions/recordings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recording _$RecordingFromJson(Map<String, dynamic> json) => Recording(
      name: json['name'] as String,
      format: json['format'] as String,
      targetUri: json['target_uri'] as String,
      state: $enumDecode(_$RecordingStateEnumMap, json['state']),
      duration:
          Recording._durationFromSecs((json['duration'] as num?)?.toInt()),
      talkingDuration: Recording._durationFromSecs(
          (json['talking_duration'] as num?)?.toInt()),
      silenceDuration: Recording._durationFromSecs(
          (json['silence_duration'] as num?)?.toInt()),
      cause: json['cause'] as String?,
    );

const _$RecordingStateEnumMap = {
  RecordingState.queued: 'queued',
  RecordingState.recording: 'recording',
  RecordingState.paused: 'paused',
  RecordingState.done: 'done',
  RecordingState.failed: 'failed',
  RecordingState.canceled: 'canceled',
};

StoredRecording _$StoredRecordingFromJson(Map<String, dynamic> json) =>
    StoredRecording(
      name: json['name'] as String,
      format: json['format'] as String,
    );

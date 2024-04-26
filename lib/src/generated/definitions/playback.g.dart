// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../definitions/playback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playback _$PlaybackFromJson(Map<String, dynamic> json) => Playback(
      id: json['id'] as String,
      mediaUri: json['media_uri'] as String,
      nextMediaUri: json['next_media_uri'] as String?,
      targetUri: json['target_uri'] as String,
      language: json['language'] as String,
      state: $enumDecode(_$PlaybackStateEnumMap, json['state']),
    );

const _$PlaybackStateEnumMap = {
  PlaybackState.queued: 'queued',
  PlaybackState.playing: 'playing',
  PlaybackState.continuing: 'continuing',
  PlaybackState.done: 'done',
  PlaybackState.failed: 'failed',
};

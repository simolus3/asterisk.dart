// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../definitions/ws_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MissingParams _$MissingParamsFromJson(Map<String, dynamic> json) =>
    MissingParams(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      params:
          (json['params'] as List<dynamic>).map((e) => e as String).toList(),
    );

ChannelDestroyed _$ChannelDestroyedFromJson(Map<String, dynamic> json) =>
    ChannelDestroyed(
      cause: (json['cause'] as num).toInt(),
      causeTxt: json['cause_txt'] as String,
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

ChannelStateChange _$ChannelStateChangeFromJson(Map<String, dynamic> json) =>
    ChannelStateChange(
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

ChannelTalkingFinished _$ChannelTalkingFinishedFromJson(
        Map<String, dynamic> json) =>
    ChannelTalkingFinished(
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
      duration: ChannelTalkingFinished._durationFromMillis(
          (json['duration'] as num).toInt()),
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

ChannelTalkingStarted _$ChannelTalkingStartedFromJson(
        Map<String, dynamic> json) =>
    ChannelTalkingStarted(
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

EndpointStateChange _$EndpointStateChangeFromJson(Map<String, dynamic> json) =>
    EndpointStateChange(
      endpoint: Endpoint.fromJson(json['endpoint'] as Map<String, dynamic>),
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

PlaybackContinuing _$PlaybackContinuingFromJson(Map<String, dynamic> json) =>
    PlaybackContinuing(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      playback: Playback.fromJson(json['playback'] as Map<String, dynamic>),
    );

PlaybackFinished _$PlaybackFinishedFromJson(Map<String, dynamic> json) =>
    PlaybackFinished(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      playback: Playback.fromJson(json['playback'] as Map<String, dynamic>),
    );

PlaybackStarted _$PlaybackStartedFromJson(Map<String, dynamic> json) =>
    PlaybackStarted(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      playback: Playback.fromJson(json['playback'] as Map<String, dynamic>),
    );

RecordingFailed _$RecordingFailedFromJson(Map<String, dynamic> json) =>
    RecordingFailed(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recording: Recording.fromJson(json['recording'] as Map<String, dynamic>),
    );

RecordingFinished _$RecordingFinishedFromJson(Map<String, dynamic> json) =>
    RecordingFinished(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recording: Recording.fromJson(json['recording'] as Map<String, dynamic>),
    );

RecordingStarted _$RecordingStartedFromJson(Map<String, dynamic> json) =>
    RecordingStarted(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recording: Recording.fromJson(json['recording'] as Map<String, dynamic>),
    );

StasisEnd _$StasisEndFromJson(Map<String, dynamic> json) => StasisEnd(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
    );

StasisStart _$StasisStartFromJson(Map<String, dynamic> json) => StasisStart(
      type: json['type'] as String,
      asteriskId: json['asterisk_id'] as String,
      application: json['application'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      args: (json['args'] as List<dynamic>).map((e) => e as String).toList(),
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
      replaceChannel: json['replace_channel'] == null
          ? null
          : Channel.fromJson(json['replace_channel'] as Map<String, dynamic>),
    );

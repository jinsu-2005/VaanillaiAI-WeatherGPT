// Stub implementation for mobile platforms (Android / iOS)
import 'dart:typed_data';

Future<bool> implRequestPermission() async => false;

Future<bool> implHasPermission() async => false;

Future<bool> implStartRecording(void Function(Uint8List chunk) onPcmChunk) async => false;

void implStopRecording() {}

void implPlayPcmChunk(Uint8List pcmChunk, [int sampleRate = 24000]) {}

void implFlushPlayback() {}

void implStopPlayback() {}

void implListenPlaybackState(void Function(String state) onStateChanged) {}

Map<String, dynamic> implGetAudioRouteInfo() => {
  'route': 'Built-in Speaker',
  'speakerOn': true,
};

import 'dart:typed_data';
import 'web_audio_helper_stub.dart'
    if (dart.library.js) 'web_audio_helper_web.dart';

class WebAudioHelper {
  static Future<bool> requestPermission() => implRequestPermission();
  static Future<bool> hasPermission() => implHasPermission();
  static Future<bool> startRecording(void Function(Uint8List chunk) onPcmChunk) =>
      implStartRecording(onPcmChunk);
  static void stopRecording() => implStopRecording();
  static void playPcmChunk(Uint8List pcmChunk, [int sampleRate = 24000]) =>
      implPlayPcmChunk(pcmChunk, sampleRate);
  static void flushPlayback() => implFlushPlayback();
  static void stopPlayback() => implStopPlayback();
  static void listenPlaybackState(void Function(String state) onStateChanged) =>
      implListenPlaybackState(onStateChanged);
  static Map<String, dynamic> getAudioRouteInfo() => implGetAudioRouteInfo();
}

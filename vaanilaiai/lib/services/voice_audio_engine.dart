import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'web_audio_helper.dart';

/// Cross-platform Voice Audio Engine:
/// - Android: Native AudioRecord (16kHz PCM Mic) and AudioTrack (24kHz PCM Speaker) bridge.
/// - Web: Web Audio API (16kHz PCM getUserMedia Mic) and Web Audio Buffer playback.
class VoiceAudioEngine {
  static const MethodChannel _control = MethodChannel('com.vaanilaiai.app/voice_control');
  static const EventChannel _micStream = EventChannel('com.vaanilaiai.app/voice_mic');
  static const EventChannel _playbackStateStream = EventChannel('com.vaanilaiai.app/voice_playback_state');

  StreamSubscription? _micSub;
  StreamSubscription? _playbackStateSub;

  Future<bool> requestRecordPermission() async {
    if (kIsWeb) {
      return await WebAudioHelper.requestPermission();
    }
    try {
      final res = await _control.invokeMethod<bool>('requestRecordPermission');
      return res ?? false;
    } catch (e) {
      debugPrint('LIVE_ERROR: Error requesting mic permission: $e');
      return false;
    }
  }

  Future<bool> hasRecordPermission() async {
    if (kIsWeb) {
      return await WebAudioHelper.hasPermission();
    }
    try {
      final res = await _control.invokeMethod<bool>('hasRecordPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> startRecording(void Function(Uint8List chunk) onPcmChunk) async {
    if (kIsWeb) {
      return await WebAudioHelper.startRecording(onPcmChunk);
    }
    try {
      await _micSub?.cancel();
      _micSub = _micStream.receiveBroadcastStream().listen((dynamic event) {
        if (event is Uint8List) {
          onPcmChunk(event);
        } else if (event is List<int>) {
          onPcmChunk(Uint8List.fromList(event));
        }
      }, onError: (e) {
        debugPrint('LIVE_ERROR: Mic stream error: $e');
      });

      final ok = await _control.invokeMethod<bool>('startRecording');
      return ok ?? false;
    } catch (e) {
      debugPrint('LIVE_ERROR: startRecording failed: $e');
      return false;
    }
  }

  Future<void> stopRecording() async {
    if (kIsWeb) {
      WebAudioHelper.stopRecording();
      return;
    }
    try {
      await _micSub?.cancel();
      _micSub = null;
      await _control.invokeMethod('stopRecording');
    } catch (e) {
      debugPrint('LIVE_ERROR: stopRecording failed: $e');
    }
  }

  Future<void> playPcmChunk(Uint8List pcmChunk) async {
    if (kIsWeb) {
      WebAudioHelper.playPcmChunk(pcmChunk);
      return;
    }
    try {
      await _control.invokeMethod('playPcmChunk', pcmChunk);
    } catch (e) {
      debugPrint('LIVE_ERROR: playPcmChunk error: $e');
    }
  }

  Future<void> flushPlayback() async {
    if (kIsWeb) {
      WebAudioHelper.flushPlayback();
      return;
    }
    try {
      await _control.invokeMethod('flushPlayback');
    } catch (e) {
      debugPrint('LIVE_ERROR: flushPlayback error: $e');
    }
  }

  Future<void> stopPlayback() async {
    if (kIsWeb) {
      WebAudioHelper.stopPlayback();
      return;
    }
    try {
      await _control.invokeMethod('stopPlayback');
    } catch (e) {
      debugPrint('LIVE_ERROR: stopPlayback error: $e');
    }
  }

  void listenPlaybackState(void Function(String state) onStateChanged) {
    if (kIsWeb) {
      WebAudioHelper.listenPlaybackState(onStateChanged);
      return;
    }
    _playbackStateSub?.cancel();
    _playbackStateSub = _playbackStateStream.receiveBroadcastStream().listen((dynamic event) {
      if (event is String) {
        onStateChanged(event);
      }
    }, onError: (e) {
      debugPrint('LIVE_ERROR: Playback state stream error: $e');
    });
  }

  Future<Map<String, dynamic>> getAudioRouteInfo() async {
    if (kIsWeb) {
      return WebAudioHelper.getAudioRouteInfo();
    }
    try {
      final res = await _control.invokeMapMethod<String, dynamic>('getAudioRoute');
      return res ?? {};
    } catch (_) {
      return {'route': 'Speaker', 'speakerOn': true};
    }
  }

  void dispose() {
    stopRecording();
    stopPlayback();
    _playbackStateSub?.cancel();
    _playbackStateSub = null;
  }
}

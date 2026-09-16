// Web implementation of audio bridge using modern dart:js_interop
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

JSObject? get _audioBridge {
  if (globalContext.has('VaanilaiWebAudio')) {
    return globalContext.getProperty('VaanilaiWebAudio'.toJS) as JSObject?;
  }
  return null;
}

Future<bool> implRequestPermission() async {
  try {
    final bridge = _audioBridge;
    if (bridge == null) return false;
    final promise = bridge.callMethod('requestPermission'.toJS) as JSPromise;
    final res = await promise.toDart;
    return (res as JSBoolean).toDart;
  } catch (e) {
    return false;
  }
}

Future<bool> implHasPermission() async {
  try {
    final bridge = _audioBridge;
    if (bridge == null) return true;
    final promise = bridge.callMethod('hasPermission'.toJS) as JSPromise;
    final res = await promise.toDart;
    return (res as JSBoolean).toDart;
  } catch (_) {
    return true;
  }
}

Future<bool> implStartRecording(void Function(Uint8List chunk) onPcmChunk) async {
  try {
    final bridge = _audioBridge;
    if (bridge == null) return false;

    final jsCallback = (JSAny? jsData) {
      if (jsData != null) {
        if (jsData.isA<JSUint8Array>()) {
          final u8 = jsData as JSUint8Array;
          onPcmChunk(u8.toDart);
        }
      }
    }.toJS;

    final promise = bridge.callMethod('startRecording'.toJS, jsCallback) as JSPromise;
    final res = await promise.toDart;
    return (res as JSBoolean).toDart;
  } catch (e) {
    return false;
  }
}

void implStopRecording() {
  try {
    final bridge = _audioBridge;
    if (bridge != null) {
      bridge.callMethod('stopRecording'.toJS);
    }
  } catch (_) {}
}

void implPlayPcmChunk(Uint8List pcmChunk, [int sampleRate = 24000]) {
  try {
    final bridge = _audioBridge;
    if (bridge != null) {
      bridge.callMethod('playPcmChunk'.toJS, pcmChunk.toJS, sampleRate.toJS);
    }
  } catch (_) {}
}

void implFlushPlayback() {
  try {
    final bridge = _audioBridge;
    if (bridge != null) {
      bridge.callMethod('flushPlayback'.toJS);
    }
  } catch (_) {}
}

void implStopPlayback() {
  try {
    final bridge = _audioBridge;
    if (bridge != null) {
      bridge.callMethod('stopPlayback'.toJS);
    }
  } catch (_) {}
}

void implListenPlaybackState(void Function(String state) onStateChanged) {
  try {
    final bridge = _audioBridge;
    if (bridge != null) {
      final jsCb = (JSString jsState) {
        onStateChanged(jsState.toDart);
      }.toJS;
      bridge.callMethod('listenPlaybackState'.toJS, jsCb);
    }
  } catch (_) {}
}

Map<String, dynamic> implGetAudioRouteInfo() {
  try {
    final bridge = _audioBridge;
    if (bridge != null) {
      final res = bridge.callMethod('getAudioRouteInfo'.toJS) as JSObject?;
      if (res != null) {
        final routeVal = res.has('route')
            ? (res.getProperty('route'.toJS) as JSString).toDart
            : 'Web Audio';
        final speakerVal = res.has('speakerOn')
            ? (res.getProperty('speakerOn'.toJS) as JSBoolean).toDart
            : true;
        return {
          'route': routeVal,
          'speakerOn': speakerVal,
        };
      }
    }
  } catch (_) {}
  return {
    'route': 'Web Audio (Browser Speakers / Headphones)',
    'speakerOn': true,
  };
}

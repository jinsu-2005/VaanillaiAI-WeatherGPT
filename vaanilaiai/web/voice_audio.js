// VaanilaiAI Web Audio Bridge for Gemini Live Voice
// Captures 16kHz 16-bit PCM microphone audio and plays 24kHz 16-bit PCM model speech.

(function () {
  let inputAudioContext = null;
  let outputAudioContext = null;
  let micStream = null;
  let micSource = null;
  let scriptProcessor = null;
  let isRecording = false;
  let playbackStateCallback = null;
  let activeSources = [];
  let nextPlayTime = 0;

  function ensureOutputContext(sampleRate) {
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!outputAudioContext || outputAudioContext.state === 'closed') {
      outputAudioContext = new AudioCtx({ sampleRate: sampleRate || 24000 });
    }
    if (outputAudioContext.state === 'suspended') {
      outputAudioContext.resume();
    }
    return outputAudioContext;
  }

  function downsampleBuffer(buffer, sourceRate, targetRate) {
    if (sourceRate === targetRate) {
      return buffer;
    }
    if (sourceRate < targetRate) {
      return buffer;
    }
    const ratio = sourceRate / targetRate;
    const newLength = Math.round(buffer.length / ratio);
    const result = new Float32Array(newLength);
    let offsetResult = 0;
    let offsetBuffer = 0;
    while (offsetResult < result.length) {
      const nextOffsetBuffer = Math.round((offsetResult + 1) * ratio);
      let accum = 0, count = 0;
      for (let i = offsetBuffer; i < nextOffsetBuffer && i < buffer.length; i++) {
        accum += buffer[i];
        count++;
      }
      result[offsetResult] = count > 0 ? accum / count : 0;
      offsetResult++;
      offsetBuffer = nextOffsetBuffer;
    }
    return result;
  }

  function floatTo16BitPCM(input) {
    const output = new Int16Array(input.length);
    for (let i = 0; i < input.length; i++) {
      const s = Math.max(-1, Math.min(1, input[i]));
      output[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
    }
    return output;
  }

  window.VaanilaiWebAudio = {
    requestPermission: async function () {
      try {
        console.log('[WebAudio] Requesting browser microphone permission...');
        const stream = await navigator.mediaDevices.getUserMedia({
          audio: {
            channelCount: 1,
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          }
        });
        // Release initial probe stream
        stream.getTracks().forEach(track => track.stop());
        console.log('[WebAudio] Microphone permission granted!');
        return true;
      } catch (err) {
        console.warn('[WebAudio] Microphone permission denied or unavailable:', err);
        return false;
      }
    },

    hasPermission: async function () {
      try {
        if (!navigator.permissions) return true;
        const status = await navigator.permissions.query({ name: 'microphone' });
        return status.state === 'granted';
      } catch (_) {
        return true;
      }
    },

    startRecording: async function (onPcmChunk) {
      try {
        console.log('[WebAudio] Starting 16kHz PCM microphone stream...');
        const AudioCtx = window.AudioContext || window.webkitAudioContext;
        if (!inputAudioContext || inputAudioContext.state === 'closed') {
          inputAudioContext = new AudioCtx();
        }
        if (inputAudioContext.state === 'suspended') {
          await inputAudioContext.resume();
        }

        micStream = await navigator.mediaDevices.getUserMedia({
          audio: {
            channelCount: 1,
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          }
        });

        micSource = inputAudioContext.createMediaStreamSource(micStream);
        const bufferSize = 4096;
        scriptProcessor = inputAudioContext.createScriptProcessor(bufferSize, 1, 1);

        const sourceRate = inputAudioContext.sampleRate;
        const targetRate = 16000;
        console.log(`[WebAudio] Mic connected. Source rate: ${sourceRate}Hz -> Target: ${targetRate}Hz`);

        scriptProcessor.onaudioprocess = function (event) {
          if (!isRecording) return;
          const inputData = event.inputBuffer.getChannelData(0);
          const resampled = downsampleBuffer(inputData, sourceRate, targetRate);
          const pcm16 = floatTo16BitPCM(resampled);
          const uint8 = new Uint8Array(pcm16.buffer);

          if (onPcmChunk) {
            try {
              onPcmChunk(uint8);
            } catch (err) {
              console.error('[WebAudio] Error in onPcmChunk callback:', err);
            }
          }
        };

        micSource.connect(scriptProcessor);
        // Connect to a muted gain node to satisfy Web Audio destination requirement without echo
        const muteNode = inputAudioContext.createGain();
        muteNode.gain.value = 0;
        scriptProcessor.connect(muteNode);
        muteNode.connect(inputAudioContext.destination);

        isRecording = true;
        console.log('[WebAudio] Microphone recording active');
        return true;
      } catch (e) {
        console.error('[WebAudio] Failed to start microphone recording:', e);
        return false;
      }
    },

    stopRecording: function () {
      console.log('[WebAudio] Stopping microphone recording...');
      isRecording = false;
      if (scriptProcessor) {
        try { scriptProcessor.disconnect(); } catch (_) {}
        scriptProcessor = null;
      }
      if (micSource) {
        try { micSource.disconnect(); } catch (_) {}
        micSource = null;
      }
      if (micStream) {
        try {
          micStream.getTracks().forEach(track => track.stop());
        } catch (_) {}
        micStream = null;
      }
      console.log('[WebAudio] Microphone recording stopped');
    },

    playPcmChunk: function (uint8Data, sampleRate) {
      try {
        const targetRate = sampleRate || 24000;
        const ctx = ensureOutputContext(targetRate);

        // Ensure Uint8Array
        let bytes;
        if (uint8Data instanceof Uint8Array) {
          bytes = uint8Data;
        } else if (Array.isArray(uint8Data)) {
          bytes = new Uint8Array(uint8Data);
        } else {
          bytes = new Uint8Array(uint8Data.buffer || uint8Data);
        }

        const numSamples = Math.floor(bytes.byteLength / 2);
        if (numSamples <= 0) return;

        // View as 16-bit signed PCM
        const dataView = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
        const float32 = new Float32Array(numSamples);

        for (let i = 0; i < numSamples; i++) {
          const intVal = dataView.getInt16(i * 2, true); // little-endian
          float32[i] = intVal / (intVal < 0 ? 32768.0 : 32767.0);
        }

        const audioBuffer = ctx.createBuffer(1, numSamples, targetRate);
        audioBuffer.copyToChannel(float32, 0);

        const source = ctx.createBufferSource();
        source.buffer = audioBuffer;
        source.connect(ctx.destination);

        const now = ctx.currentTime;
        if (nextPlayTime < now) {
          nextPlayTime = now + 0.02; // 20ms lead
        }

        source.start(nextPlayTime);
        nextPlayTime += audioBuffer.duration;

        activeSources.push(source);

        if (playbackStateCallback && activeSources.length === 1) {
          playbackStateCallback('PLAYING');
        }

        source.onended = function () {
          const idx = activeSources.indexOf(source);
          if (idx !== -1) activeSources.splice(idx, 1);
          if (activeSources.length === 0 && playbackStateCallback) {
            playbackStateCallback('IDLE');
          }
        };
      } catch (e) {
        console.error('[WebAudio] Error playing audio chunk:', e);
      }
    },

    flushPlayback: function () {
      console.log('[WebAudio] Flushing audio playback queue...');
      for (const src of activeSources) {
        try { src.stop(); } catch (_) {}
      }
      activeSources = [];
      if (outputAudioContext) {
        nextPlayTime = outputAudioContext.currentTime;
      }
      if (playbackStateCallback) {
        playbackStateCallback('INTERRUPTED');
      }
    },

    stopPlayback: function () {
      this.flushPlayback();
    },

    listenPlaybackState: function (cb) {
      playbackStateCallback = cb;
    },

    getAudioRouteInfo: function () {
      return {
        route: 'Web Audio (Browser Speakers / Headphones)',
        speakerOn: true
      };
    }
  };

  // Pre-unlock Web Audio on first user interaction
  function unlockAudio() {
    try {
      ensureOutputContext(24000);
    } catch (_) {}
    window.removeEventListener('click', unlockAudio);
    window.removeEventListener('touchstart', unlockAudio);
    window.removeEventListener('keydown', unlockAudio);
  }
  window.addEventListener('click', unlockAudio);
  window.addEventListener('touchstart', unlockAudio);
  window.addEventListener('keydown', unlockAudio);

  console.log('[WebAudio] VaanilaiAI Web Audio Bridge initialized.');
})();

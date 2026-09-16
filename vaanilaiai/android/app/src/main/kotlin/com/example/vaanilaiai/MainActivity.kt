package com.example.vaanilaiai

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.NoiseSuppressor
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val CONTROL_CHANNEL = "com.vaanilaiai.app/voice_control"
    private val MIC_STREAM_CHANNEL = "com.vaanilaiai.app/voice_mic"
    private val PLAYBACK_STATE_CHANNEL = "com.vaanilaiai.app/voice_playback_state"
    private val PERMISSION_REQUEST_CODE = 44101

    private val mainHandler = Handler(Looper.getMainLooper())

    // Microphone Recording (16kHz 16-bit Mono PCM for Gemini Live)
    private var audioRecord: AudioRecord? = null
    private var isRecording = AtomicBoolean(false)
    private var recordingThread: Thread? = null
    private var micEventSink: EventChannel.EventSink? = null
    private var aec: AcousticEchoCanceler? = null
    private var noiseSuppressor: NoiseSuppressor? = null

    // Speaker Playback (24kHz 16-bit Mono PCM from Gemini Live)
    private var audioTrack: AudioTrack? = null
    private var isPlaying = AtomicBoolean(false)
    private var playbackThread: Thread? = null
    private val playbackQueue = LinkedBlockingQueue<ByteArray>()
    private var playbackStateSink: EventChannel.EventSink? = null
    private var lastPlaybackState: String = "IDLE"

    private var permissionResultCallback: ((Boolean) -> Unit)? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel for commands
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTROL_CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "requestRecordPermission" -> {
                        requestRecordAudioPermission { granted ->
                            result.success(granted)
                        }
                    }
                    "hasRecordPermission" -> {
                        val has = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.RECORD_AUDIO
                        ) == PackageManager.PERMISSION_GRANTED
                        result.success(has)
                    }
                    "startRecording" -> {
                        val started = startMicRecording()
                        result.success(started)
                    }
                    "stopRecording" -> {
                        stopMicRecording()
                        result.success(true)
                    }
                    "playPcmChunk" -> {
                        val bytes = call.arguments as? ByteArray
                        if (bytes != null && bytes.isNotEmpty()) {
                            queuePcmForPlayback(bytes)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGS", "Missing PCM byte payload", null)
                        }
                    }
                    "flushPlayback" -> {
                        flushAudioPlayback()
                        result.success(true)
                    }
                    "stopPlayback" -> {
                        stopAudioPlayback()
                        result.success(true)
                    }
                    "getAudioRoute" -> {
                        val routeInfo = getAudioRouteInfo()
                        result.success(routeInfo)
                    }
                    else -> result.notImplemented()
                }
            }

        // EventChannel for microphone PCM byte streaming
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MIC_STREAM_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    micEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    micEventSink = null
                    stopMicRecording()
                }
            })

        // EventChannel for playback state changes
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PLAYBACK_STATE_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    playbackStateSink = events
                }

                override fun onCancel(arguments: Any?) {
                    playbackStateSink = null
                }
            })
    }

    private fun requestRecordAudioPermission(callback: (Boolean) -> Unit) {
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            callback(true)
            return
        }
        permissionResultCallback = callback
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.RECORD_AUDIO),
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            permissionResultCallback?.invoke(granted)
            permissionResultCallback = null
        }
    }

    // ==================== 1. Microphone Recording (16kHz PCM) ====================

    @Synchronized
    private fun startMicRecording(): Boolean {
        if (isRecording.get()) return true

        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        if (!granted) return false

        val sampleRate = 16000
        val channelConfig = AudioFormat.CHANNEL_IN_MONO
        val audioFormat = AudioFormat.ENCODING_PCM_16BIT
        val minBufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)
        val bufferSize = maxOf(minBufferSize * 2, 4096)

        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_COMMUNICATION,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                audioRecord?.release()
                audioRecord = null
                return false
            }

            if (AcousticEchoCanceler.isAvailable()) {
                try {
                    aec = AcousticEchoCanceler.create(audioRecord!!.audioSessionId)
                    aec?.enabled = true
                } catch (_: Exception) {}
            }
            if (NoiseSuppressor.isAvailable()) {
                try {
                    noiseSuppressor = NoiseSuppressor.create(audioRecord!!.audioSessionId)
                    noiseSuppressor?.enabled = true
                } catch (_: Exception) {}
            }

            audioRecord?.startRecording()
            isRecording.set(true)

            recordingThread = Thread({
                // Send 1024 shorts = 2048 bytes (~64ms chunks at 16kHz)
                val chunkShorts = 1024
                val buffer = ShortArray(chunkShorts)
                val byteBuffer = ByteArray(chunkShorts * 2)

                while (isRecording.get() && audioRecord != null) {
                    val readShorts = audioRecord?.read(buffer, 0, buffer.size) ?: -1
                    if (readShorts > 0) {
                        // Convert shorts to little-endian bytes
                        for (i in 0 until readShorts) {
                            val v = buffer[i].toInt()
                            byteBuffer[i * 2] = (v and 0xFF).toByte()
                            byteBuffer[i * 2 + 1] = ((v shr 8) and 0xFF).toByte()
                        }
                        val finalBytes = if (readShorts == chunkShorts) {
                            byteBuffer.clone()
                        } else {
                            byteBuffer.copyOf(readShorts * 2)
                        }

                        mainHandler.post {
                            micEventSink?.success(finalBytes)
                        }
                    }
                }
            }, "Vaanilai-MicRecordThread")

            recordingThread?.priority = Thread.MAX_PRIORITY
            recordingThread?.start()
            return true
        } catch (e: Exception) {
            audioRecord?.release()
            audioRecord = null
            isRecording.set(false)
            return false
        }
    }

    @Synchronized
    private fun stopMicRecording() {
        isRecording.set(false)
        try {
            aec?.release()
            noiseSuppressor?.release()
        } catch (_: Exception) {}
        aec = null
        noiseSuppressor = null
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (_: Exception) {}
        audioRecord = null
        recordingThread = null
    }

    // ==================== 2. Speaker Playback (24kHz PCM) ====================

    @Synchronized
    private fun initAudioTrack(): Boolean {
        if (audioTrack != null && audioTrack?.state == AudioTrack.STATE_INITIALIZED) {
            return true
        }

        val sampleRate = 24000
        val channelConfig = AudioFormat.CHANNEL_OUT_MONO
        val audioFormat = AudioFormat.ENCODING_PCM_16BIT
        val minBufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, audioFormat)
        val bufferSize = maxOf(minBufferSize * 4, 8192)

        try {
            audioTrack = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(audioFormat)
                        .setSampleRate(sampleRate)
                        .setChannelMask(channelConfig)
                        .build()
                )
                .setBufferSizeInBytes(bufferSize)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()

            audioTrack?.play()
            startPlaybackWorker()
            return true
        } catch (e: Exception) {
            audioTrack = null
            return false
        }
    }

    private fun startPlaybackWorker() {
        if (playbackThread != null && playbackThread?.isAlive == true) return

        isPlaying.set(true)
        playbackThread = Thread({
            while (isPlaying.get()) {
                try {
                    val chunk = playbackQueue.poll(200, java.util.concurrent.TimeUnit.MILLISECONDS)
                    if (chunk != null && chunk.isNotEmpty()) {
                        notifyPlaybackState("PLAYING")
                        audioTrack?.write(chunk, 0, chunk.size, AudioTrack.WRITE_BLOCKING)
                    } else if (playbackQueue.isEmpty()) {
                        notifyPlaybackState("IDLE")
                    }
                } catch (e: InterruptedException) {
                    break
                } catch (e: Exception) {
                    notifyPlaybackState("ERROR")
                }
            }
        }, "Vaanilai-AudioPlaybackThread")

        playbackThread?.priority = Thread.MAX_PRIORITY
        playbackThread?.start()
    }

    private fun queuePcmForPlayback(chunk: ByteArray) {
        if (!initAudioTrack()) return
        playbackQueue.offer(chunk)
    }

    @Synchronized
    private fun flushAudioPlayback() {
        playbackQueue.clear()
        try {
            audioTrack?.pause()
            audioTrack?.flush()
            audioTrack?.play()
        } catch (_: Exception) {}
        notifyPlaybackState("INTERRUPTED")
    }

    @Synchronized
    private fun stopAudioPlayback() {
        playbackQueue.clear()
        isPlaying.set(false)
        playbackThread?.interrupt()
        playbackThread = null
        try {
            audioTrack?.stop()
            audioTrack?.release()
        } catch (_: Exception) {}
        audioTrack = null
        notifyPlaybackState("STOPPED")
    }

    private fun notifyPlaybackState(state: String) {
        if (state == lastPlaybackState) return
        lastPlaybackState = state
        mainHandler.post {
            playbackStateSink?.success(state)
        }
    }

    private fun getAudioRouteInfo(): Map<String, Any> {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val isSpeakerOn = audioManager.isSpeakerphoneOn
        val mode = audioManager.mode
        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)

        return mapOf(
            "speakerOn" to isSpeakerOn,
            "mode" to mode,
            "currentVolume" to currentVolume,
            "maxVolume" to maxVolume,
            "route" to if (audioManager.isBluetoothA2dpOn || audioManager.isBluetoothScoOn) "Bluetooth"
                       else if (audioManager.isWiredHeadsetOn) "Headset"
                       else "Built-in Speaker"
        )
    }

    override fun onDestroy() {
        stopMicRecording()
        stopAudioPlayback()
        super.onDestroy()
    }
}

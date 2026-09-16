import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../services/voice_audio_engine.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_wrapper.dart';

enum LiveVoiceState {
  connecting,
  listening,
  thinking,
  speaking,
  interrupted,
  disconnected,
  error,
}

class VoiceWeatherScreen extends StatefulWidget {
  const VoiceWeatherScreen({super.key});

  @override
  State<VoiceWeatherScreen> createState() => _VoiceWeatherScreenState();
}

class _VoiceWeatherScreenState extends State<VoiceWeatherScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final VoiceAudioEngine _audioEngine = VoiceAudioEngine();

  late AnimationController _pulseController;
  late AnimationController _waveController;
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  WebSocketChannel? _channel;
  StreamSubscription? _webSocketSub;

  LiveVoiceState _liveState = LiveVoiceState.connecting;
  bool _isLiveConnected = false;
  bool _userTerminated = false;
  String? _errorMessage;
  String? _lastQuery;
  String? _voiceResponse;
  String _activeLanguage = 'en';
  List<String> _suggestedPrompts = [];
  bool _showDiagnostic = kDebugMode;

  // Diagnostics counters
  int _inputPcmChunksCount = 0;
  int _outputPcmChunksCount = 0;
  int _outputBytesQueued = 0;
  String _audioRoute = 'Built-in Speaker';
  bool _micActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _audioEngine.listenPlaybackState((state) {
      if (!mounted) return;
      if (state == 'PLAYING') {
        debugPrint('PLAYBACK_CHUNK: Playing chunk through speaker');
        if (_liveState != LiveVoiceState.speaking) {
          setState(() => _liveState = LiveVoiceState.speaking);
        }
      } else if (state == 'IDLE') {
        debugPrint('PLAYBACK_STOPPED: Speaker queue empty');
        if (_liveState == LiveVoiceState.speaking) {
          setState(() => _liveState = LiveVoiceState.listening);
        }
      } else if (state == 'INTERRUPTED') {
        debugPrint('LIVE_INTERRUPTED: Speaker playback flushed');
        setState(() => _liveState = LiveVoiceState.interrupted);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Provider.of<LocaleProvider>(context, listen: false);
      _activeLanguage = locale.currentLanguage;
      _startLiveVoiceSession();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _queryController.dispose();
    _queryFocus.dispose();
    _closeLiveVoiceSession();
    _audioEngine.dispose();
    super.dispose();
  }

  Future<void> _closeLiveVoiceSession() async {
    debugPrint('LIVE_DISCONNECTED: Closing live voice session');
    _micActive = false;
    await _audioEngine.stopRecording();
    await _audioEngine.stopPlayback();
    try {
      if (_channel != null && _isLiveConnected) {
        _channel?.sink.add(jsonEncode({'event': 'DISCONNECT'}));
      }
    } catch (_) {}
    await _webSocketSub?.cancel();
    _webSocketSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  Future<void> _terminateSession() async {
    debugPrint('LIVE_TERMINATE: User terminated session');
    _userTerminated = true;
    await _closeLiveVoiceSession();
    if (mounted) {
      setState(() {
        _isLiveConnected = false;
        _liveState = LiveVoiceState.disconnected;
        _errorMessage = null;
      });
    }
  }

  Future<void> _startLiveVoiceSession({String? overrideLang}) async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    final lang = overrideLang ?? _activeLanguage;

    _userTerminated = false;
    await _closeLiveVoiceSession();

    setState(() {
      _liveState = LiveVoiceState.connecting;
      _isLiveConnected = false;
      _errorMessage = null;
      _voiceResponse = null;
      _lastQuery = null;
      _activeLanguage = lang;
      _inputPcmChunksCount = 0;
      _outputPcmChunksCount = 0;
      _outputBytesQueued = 0;
    });

    // Check / Request microphone permission on Android
    final hasPerm = await _audioEngine.requestRecordPermission();
    if (!hasPerm) {
      debugPrint('LIVE_ERROR: Microphone permission denied');
      if (mounted) {
        setState(() {
          _liveState = LiveVoiceState.error;
          _errorMessage = 'Microphone permission is required for Live Voice.';
        });
      }
      return;
    }

    // Query audio route
    try {
      final routeInfo = await _audioEngine.getAudioRouteInfo();
      _audioRoute = routeInfo['route']?.toString() ?? 'Built-in Speaker';
    } catch (_) {}

    // Derive WebSocket URI from base URL
    final base = _apiService.baseUrl;
    final wsScheme = base.startsWith('https') ? 'wss' : 'ws';
    final hostOnly = base.replaceFirst(RegExp(r'^https?:\/\/'), '');
    final uriStr = '$wsScheme://$hostOnly/api/v1/voice/live?'
        'language=$lang&'
        'latitude=${weather.latitude}&'
        'longitude=${weather.longitude}&'
        'location_name=${Uri.encodeComponent(weather.locationName)}';

    debugPrint('LIVE_CONNECT: Connecting to $uriStr');

    try {
      final channel = WebSocketChannel.connect(Uri.parse(uriStr));
      await channel.ready.timeout(const Duration(seconds: 12));
      _channel = channel;
      debugPrint('LIVE_CONNECTED: WebSocket opened to backend Gemini Live bridge');

      setState(() {
        _isLiveConnected = true;
        _suggestedPrompts = _getDefaultPrompts(weather.locationName);
      });

      // Start streaming microphone audio (16kHz 16-bit mono PCM)
      final micStarted = await _audioEngine.startRecording((Uint8List pcmChunk) {
        _inputPcmChunksCount++;
        if (_inputPcmChunksCount % 20 == 0) {
          debugPrint('MIC_PCM_CHUNK: Received chunk #$_inputPcmChunksCount (${pcmChunk.length} bytes)');
        }
        // Avoid streaming mic frames back while model is speaking aloud to prevent acoustic feedback/self-interruption
        if (_liveState == LiveVoiceState.speaking) {
          return;
        }
        try {
          _channel?.sink.add(pcmChunk);
        } catch (e) {
          debugPrint('LIVE_ERROR: Error sending mic chunk: $e');
        }
      });

      if (micStarted) {
        _micActive = true;
        debugPrint('MIC_STARTED: Real-time 16kHz PCM audio stream active');
        if (mounted) {
          setState(() => _liveState = LiveVoiceState.listening);
        }
      } else {
        if (mounted) {
          setState(() => _liveState = LiveVoiceState.listening);
        }
      }

      // Listen to incoming messages from backend / Gemini Live
      _webSocketSub = channel.stream.listen(
        (dynamic message) {
          if (message is String) {
            _handleLiveServerJson(message);
          } else if (message is Uint8List) {
            _handleLiveServerAudioBytes(message);
          } else if (message is List<int>) {
            _handleLiveServerAudioBytes(Uint8List.fromList(message));
          }
        },
        onError: (dynamic err) {
          debugPrint('LIVE_ERROR: WebSocket error: $err');
          if (mounted) {
            setState(() {
              _liveState = LiveVoiceState.error;
              _isLiveConnected = false;
              _errorMessage = 'Live Voice error: $err';
            });
          }
        },
        onDone: () {
          debugPrint('LIVE_DISCONNECTED: WebSocket connection closed');
          if (mounted) {
            setState(() {
              _isLiveConnected = false;
              if (_userTerminated) {
                _liveState = LiveVoiceState.disconnected;
                _errorMessage = null;
              } else if (_liveState != LiveVoiceState.error) {
                _liveState = LiveVoiceState.disconnected;
                _errorMessage = 'Live session ended. Tap mic or call button to reconnect.';
              }
            });
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('LIVE_ERROR: Failed to connect to Live API: $e');
      if (mounted) {
        setState(() {
          _liveState = LiveVoiceState.error;
          _isLiveConnected = false;
          _errorMessage = 'Could not connect to Gemini Live: $e';
        });
      }
    }
  }

  void _handleLiveServerJson(String rawJson) {
    try {
      final payload = jsonDecode(rawJson) as Map<String, dynamic>;
      final event = payload['event'] as String?;

      if (event == 'LIVE_CONNECTED') {
        debugPrint('LIVE_CONNECTED: Gemini Live session initialized successfully');
        if (mounted) {
          setState(() {
            _liveState = LiveVoiceState.listening;
            _isLiveConnected = true;
          });
        }
      } else if (event == 'TURN_START') {
        debugPrint('TURN_START: Model started response turn');
        if (mounted) {
          setState(() {
            _voiceResponse = '';
            _liveState = LiveVoiceState.speaking;
          });
        }
      } else if (event == 'USER_TRANSCRIPTION') {
        final userText = payload['text'] as String?;
        if (userText != null && userText.isNotEmpty) {
          // Suppress mismatched Hindi Devanagari script when speaking Tamil or English
          final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(userText);
          if ((_activeLanguage == 'ta' || _activeLanguage == 'en') && hasDevanagari) {
            debugPrint('FILTERED_SCRIPT: Ignored Devanagari transcription in $_activeLanguage mode');
            return;
          }
          if (mounted) {
            setState(() {
              if (_liveState == LiveVoiceState.listening && _voiceResponse != null && _voiceResponse!.isNotEmpty) {
                // New user query after previous answer: reset transcript for new turn
                _lastQuery = userText;
                _voiceResponse = null;
              } else {
                _lastQuery = (_lastQuery == null || _lastQuery!.isEmpty)
                    ? userText
                    : '$_lastQuery$userText';
              }
            });
          }
        }
      } else if (event == 'AUDIO_CHUNK') {
        final b64 = payload['data'] as String?;
        if (b64 != null && b64.isNotEmpty) {
          final audioBytes = base64Decode(b64);
          _handleLiveServerAudioBytes(audioBytes);
        }
      } else if (event == 'TRANSCRIPTION') {
        final transcript = payload['text'] as String?;
        if (transcript != null && transcript.isNotEmpty) {
          if (mounted) {
            setState(() {
              _voiceResponse = (_voiceResponse == null || _voiceResponse!.isEmpty)
                  ? transcript
                  : '$_voiceResponse$transcript';
            });
          }
        }
      } else if (event == 'LIVE_INTERRUPTED') {
        debugPrint('LIVE_INTERRUPTED: Barge-in signal received. Flushing speaker buffer.');
        _audioEngine.flushPlayback();
        if (mounted) {
          setState(() => _liveState = LiveVoiceState.interrupted);
        }
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && _liveState == LiveVoiceState.interrupted) {
            setState(() => _liveState = LiveVoiceState.listening);
          }
        });
      } else if (event == 'TURN_COMPLETE') {
        debugPrint('PLAYBACK_STOPPED: Model turn complete');
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _liveState == LiveVoiceState.speaking) {
            debugPrint('PLAYBACK_SAFETY: Returning to listening state');
            setState(() => _liveState = LiveVoiceState.listening);
          }
        });
      } else if (event == 'LIVE_ERROR') {
        final err = payload['error']?.toString() ?? 'Live API Error';
        debugPrint('LIVE_ERROR: $err');
        if (mounted) {
          setState(() {
            _liveState = LiveVoiceState.error;
            _errorMessage = err;
          });
        }
      }
    } catch (e) {
      debugPrint('LIVE_ERROR: Error parsing server JSON: $e');
    }
  }

  void _handleLiveServerAudioBytes(Uint8List audioBytes) {
    _outputPcmChunksCount++;
    _outputBytesQueued += audioBytes.length;
    debugPrint('LIVE_AUDIO_RECEIVED: Chunk #$_outputPcmChunksCount (${audioBytes.length} bytes)');
    debugPrint('GEMINI_AUDIO_BYTES=${audioBytes.length}');

    if (_liveState != LiveVoiceState.speaking) {
      debugPrint('PLAYBACK_STARTED: Writing audio to Android speaker');
      if (mounted) {
        setState(() => _liveState = LiveVoiceState.speaking);
      }
    }

    _audioEngine.playPcmChunk(audioBytes);
  }

  void _sendTextPrompt(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    if (_channel != null && _isLiveConnected) {
      debugPrint('TEXT_INPUT: Sending query to Gemini Live: "$clean"');
      setState(() {
        _lastQuery = clean;
        _voiceResponse = '';
        _liveState = LiveVoiceState.thinking;
      });

      _channel?.sink.add(jsonEncode({
        'event': 'TEXT_INPUT',
        'text': clean,
      }));
    } else {
      _startLiveVoiceSession().then((_) {
        _sendTextPrompt(clean);
      });
    }
  }

  List<String> _getDefaultPrompts(String locationName) {
    if (_activeLanguage == 'ta') {
      return [
        'நாகர்கோவிலில் நாளை மழை பெய்யுமா?',
        'இன்று பயிர்களுக்கு மருந்து தெளிக்க உகந்த நாளா?',
        'புயல் அல்லது கனமழை எச்சரிக்கை உள்ளதா?',
        'இன்று கடலுக்கு மீன்பிடிக்க செல்லலாமா?',
        'இன்றைய வெயில் மற்றும் புறஊதா கதிர்வீச்சு அளவு என்ன?',
      ];
    } else if (_activeLanguage == 'hi') {
      return [
        'क्या कल $locationName में बारिश होगी?',
        'क्या आज फसलों पर कीटनाशक छिड़काव के लिए मौसम सही है?',
        'क्या कोई चक्रवात या भारी वर्षा की चेतावनी है?',
        'क्या आज तटीय समुद्र में मछली पकड़ना सुरक्षित है?',
        'आज अधिकतम तापमान और यूवी स्तर क्या रहेगा?',
      ];
    }
    return [
      'Will it rain tomorrow in $locationName?',
      'Is it safe for pesticide crop spraying today?',
      'Check active cyclone and disaster warnings',
      'Is coastal sea safe for fishing today?',
      'What will be the peak heat index and UV level today in $locationName?',
    ];
  }

  String _getStateTitle() {
    switch (_liveState) {
      case LiveVoiceState.connecting:
        return 'Connecting to Gemini Live...';
      case LiveVoiceState.listening:
        return 'Listening (Speak to Gemini Live)';
      case LiveVoiceState.thinking:
        return 'Thinking...';
      case LiveVoiceState.speaking:
        return 'Speaking (Live Audio Aloud)';
      case LiveVoiceState.interrupted:
        return 'Interrupted';
      case LiveVoiceState.disconnected:
        return _activeLanguage == 'ta'
            ? 'அமர்வு முடிந்தது (Session Ended)'
            : _activeLanguage == 'hi'
                ? 'सत्र समाप्त (Session Ended)'
                : 'Live Session Ended';
      case LiveVoiceState.error:
        return 'Connection Error';
    }
  }

  Color _getStateColor(Color accentBlue) {
    switch (_liveState) {
      case LiveVoiceState.connecting:
        return accentBlue;
      case LiveVoiceState.listening:
        return AppColors.alertGreen;
      case LiveVoiceState.thinking:
        return AppColors.alertOrange;
      case LiveVoiceState.speaking:
        return const Color(0xFF00E676);
      case LiveVoiceState.interrupted:
        return Colors.orangeAccent;
      case LiveVoiceState.disconnected:
        return Colors.grey;
      case LiveVoiceState.error:
        return AppColors.alertRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weather = Provider.of<WeatherProvider>(context);

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;
    final stateColor = _getStateColor(accentBlue);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini Live Voice Intelligence',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${weather.locationName} • Native Bidirectional Audio',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Diagnostic toggle
          IconButton(
            icon: Icon(
              _showDiagnostic ? Icons.bug_report_rounded : Icons.bug_report_outlined,
              color: _showDiagnostic ? AppColors.alertGreen : textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _showDiagnostic = !_showDiagnostic),
            tooltip: 'Toggle Developer Audio Diagnostics',
          ),
          // End Call button in AppBar when active
          if (_isLiveConnected && _liveState != LiveVoiceState.disconnected)
            IconButton(
              icon: const Icon(Icons.call_end_rounded, color: AppColors.alertRed, size: 22),
              tooltip: 'End Live Voice Conversation',
              onPressed: _terminateSession,
            ),
          // Live Connection Status Badge
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: stateColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: stateColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _liveState.name.toUpperCase(),
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ResponsiveContentWrapper(
        maxWidth: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Language Switcher Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLanguageButton('English', 'en', isDark),
                  const SizedBox(width: 8),
                  _buildLanguageButton('தமிழ்', 'ta', isDark),
                  const SizedBox(width: 8),
                  _buildLanguageButton('हिन्दी', 'hi', isDark),
                ],
              ),

              const SizedBox(height: 16),

              // Developer Diagnostic Overlay (when enabled)
              if (_showDiagnostic) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1527) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('LIVE AUDIO DIAGNOSTICS',
                              style: TextStyle(
                                  color: accentBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                          Text('Model: gemini-3.1-flash-live-preview',
                              style: TextStyle(color: textSecondary, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _diagText('Microphone', _micActive ? 'ACTIVE (16kHz)' : 'INACTIVE', _micActive),
                          _diagText('Live Session', _isLiveConnected ? 'CONNECTED' : 'DISCONNECTED', _isLiveConnected),
                          _diagText('Gemini Audio Received', _outputBytesQueued > 0 ? 'YES' : 'NO', _outputBytesQueued > 0),
                          _diagText('Audio Bytes Queued', '$_outputBytesQueued B', true),
                          _diagText('Audio Player', 'READY (24kHz)', true),
                          _diagText('Speaker Playback', _liveState == LiveVoiceState.speaking ? 'PLAYING' : 'STOPPED', _liveState == LiveVoiceState.speaking),
                          _diagText('Audio Route', _audioRoute, true),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Central Interactive Orb
              SizedBox(
                width: 210,
                height: 210,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_liveState == LiveVoiceState.error ||
                          _liveState == LiveVoiceState.disconnected ||
                          !_isLiveConnected) {
                        _startLiveVoiceSession();
                      } else if (_liveState == LiveVoiceState.speaking) {
                        debugPrint('LIVE_INTERRUPTED: User tapped orb to barge in');
                        _audioEngine.flushPlayback();
                        setState(() => _liveState = LiveVoiceState.listening);
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final pulseVal = _pulseController.value;
                        final isLiveActive = _liveState == LiveVoiceState.listening ||
                            _liveState == LiveVoiceState.speaking;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isLiveActive)
                              Container(
                                width: 140 + (pulseVal * 44),
                                height: 140 + (pulseVal * 44),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: stateColor.withValues(alpha: (1.0 - pulseVal) * 0.22),
                                ),
                              ),
                            Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    stateColor,
                                    stateColor.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: stateColor.withValues(alpha: 0.45),
                                    blurRadius: 26,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: _liveState == LiveVoiceState.connecting ||
                                      _liveState == LiveVoiceState.thinking
                                  ? const SpinKitThreeBounce(
                                      color: Colors.white, size: 24)
                                  : Icon(
                                      _liveState == LiveVoiceState.speaking
                                          ? Icons.volume_up_rounded
                                          : (_liveState == LiveVoiceState.error ||
                                                  _liveState == LiveVoiceState.disconnected)
                                              ? Icons.refresh_rounded
                                              : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 46,
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Status Description Title
              Text(
                _getStateTitle(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (_lastQuery != null) ...[
                const SizedBox(height: 4),
                Text(
                  '"$_lastQuery"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.alertRed, fontSize: 12),
                ),
              ],

              // Session Termination / Reconnect Control Button
              const SizedBox(height: 10),
              if (_isLiveConnected && _liveState != LiveVoiceState.disconnected)
                OutlinedButton.icon(
                  onPressed: _terminateSession,
                  icon: const Icon(Icons.call_end_rounded, color: AppColors.alertRed, size: 18),
                  label: Text(
                    _activeLanguage == 'ta'
                        ? 'அமர்வை முடிக்கவும் (End Session)'
                        : _activeLanguage == 'hi'
                            ? 'सत्र समाप्त करें (End Session)'
                            : 'End Live Conversation',
                    style: const TextStyle(
                      color: AppColors.alertRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.alertRed.withValues(alpha: 0.5), width: 1.2),
                    backgroundColor: AppColors.alertRed.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _startLiveVoiceSession(),
                  icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                  label: Text(
                    _activeLanguage == 'ta'
                        ? 'புதிய உரையாடலைத் தொடங்கவும் (Start Live Voice)'
                        : _activeLanguage == 'hi'
                            ? 'नया सत्र प्रारंभ करें (Start Live Voice)'
                            : 'Start Live Conversation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),

              const SizedBox(height: 10),

              // Dynamic Waveform Indicator
              SizedBox(
                height: 36,
                child: Center(
                  child: (_liveState == LiveVoiceState.speaking ||
                          _liveState == LiveVoiceState.listening)
                      ? AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(14, (index) {
                                final isSpeaking = _liveState == LiveVoiceState.speaking;
                                final val = (_waveController.value + (index * 0.08)) % 1.0;
                                final h = isSpeaking ? (8.0 + (val * 24.0)) : (4.0 + (val * 8.0));
                                return Container(
                                  width: 3.5,
                                  height: h,
                                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                  decoration: BoxDecoration(
                                    color: stateColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          },
                        )
                      : Text(
                          _liveState == LiveVoiceState.connecting
                              ? 'Establishing persistent WebSocket session...'
                              : 'Tap mic or say a question',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Interactive Text Query Input Bar
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.mic_rounded, color: accentBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        focusNode: _queryFocus,
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: _activeLanguage == 'ta'
                              ? 'வானிலை கேள்வியை பேசவும் அல்லது தட்டச்சு செய்யவும்...'
                              : _activeLanguage == 'hi'
                                  ? 'मौसम से संबंधित सवाल बोलें या लिखें...'
                                  : 'Speak into mic or type question...',
                          hintStyle: TextStyle(color: textSecondary, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (val) {
                          _sendTextPrompt(val);
                          _queryController.clear();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_rounded, color: accentBlue, size: 20),
                      onPressed: () {
                        if (_queryController.text.trim().isNotEmpty) {
                          _sendTextPrompt(_queryController.text);
                          _queryController.clear();
                        }
                      },
                      tooltip: 'Send to Live Voice',
                    ),
                  ],
                ),
              ),

              // Spoken Transcript Output Card
              if (_voiceResponse != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentBlue.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  color: accentBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Gemini Live Spoken Response',
                                style: TextStyle(
                                  color: accentBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brandBlueContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Native 24kHz Audio',
                              style: TextStyle(
                                color: AppColors.brandBlueDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _voiceResponse!,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Dynamic Suggested Spoken Inquiries Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_rounded,
                            color: accentBlue, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Suggested Spoken Inquiries (One-Tap Live Audio)',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._buildSuggestedPromptsList(
                        textPrimary, borderColor, weather.locationName),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _diagText(String label, String value, bool isOk) {
    return Text(
      '$label: $value',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: isOk ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _buildLanguageButton(String label, String code, bool isDark) {
    final isSelected = _activeLanguage == code;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _startLiveVoiceSession(overrideLang: code);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.brandBlueLight : AppColors.brandBlue)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.brandBlueLight : AppColors.brandBlue)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSuggestedPromptsList(
      Color textPrimary, Color borderColor, String loc) {
    final items = _suggestedPrompts.isNotEmpty
        ? _suggestedPrompts
        : _getDefaultPrompts(loc);

    return List.generate(items.length, (i) {
      final prompt = items[i];
      final isLast = i == items.length - 1;
      return _buildPromptTile(
        prompt,
        () => _sendTextPrompt(prompt),
        textPrimary,
        borderColor,
        isLast: isLast,
      );
    });
  }

  Widget _buildPromptTile(
    String title,
    VoidCallback onTap,
    Color textPrimary,
    Color borderColor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.mic_none_rounded,
              color: AppColors.brandBlue, size: 18),
          title: Text(
            title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.lightTextTertiary, size: 12),
          onTap: onTap,
        ),
        if (!isLast) Divider(color: borderColor, height: 6),
      ],
    );
  }
}

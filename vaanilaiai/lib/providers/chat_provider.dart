import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<ChatMessageModel> _messages = [];
  bool _isSending = false;
  String? _sessionId;
  bool _isListening = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isSending => _isSending;
  bool get isListening => _isListening;
  String? get sessionId => _sessionId;

  ChatProvider() {
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    _messages.add(
      ChatMessageModel(
        role: 'assistant',
        content: 'Namaste & Vanakkam! 🙏 I am **VaanilaiAI (WeatherGPT)**, your conversational meteorological assistant for India.\n\nAsk me anything about current weather, rain predictions, cyclone warnings, farm spraying suitability, or travel safety!',
        language: 'en',
        intent: 'greeting',
        citations: ['India Meteorological Department (IMD)', 'High-Resolution NWP ECMWF Grid'],
        toolsUsed: [],
      ),
    );
  }

  void ensurePersonalizedGreeting({
    required String locationName,
    required String language,
  }) {
    if (_messages.isEmpty || (_messages.length == 1 && _messages.first.intent == 'greeting')) {
      _messages.clear();
      final greeting = language == 'ta'
          ? 'வணக்கம்! 🙏 நான் **வானிலைAI (WeatherGPT)**, உங்கள் நேரலை வானிலை உதவியாளர்.\n\n**$locationName** பகுதியில் இன்றைய வானிலை, மழை முன்னறிவிப்பு, புயல் எச்சரிக்கை, அல்லது பயிர் தெளிப்பு ஆலோசனைகள் குறித்து என்ன கேட்க விரும்புகிறீர்கள்?'
          : language == 'hi'
              ? 'नमस्ते! 🙏 मैं **VaanilaiAI (WeatherGPT)** हूँ, आपका मौसम सहायक।\n\n**$locationName** में आज के मौसम, वर्षा, चक्रवात चेतावनी या खेती संबंधी क्या जानकारी चाहिए?'
              : 'Namaste & Vanakkam! 🙏 I am **VaanilaiAI (WeatherGPT)**, your real-time conversational meteorological assistant for India.\n\nAsk me anything about current weather in **$locationName**, rain predictions, cyclone warnings, farm spraying suitability, or travel safety!';

      _messages.add(
        ChatMessageModel(
          role: 'assistant',
          content: greeting,
          language: language,
          intent: 'greeting',
          citations: ['India Meteorological Department (IMD)', 'High-Resolution NWP ECMWF Grid'],
          toolsUsed: [],
        ),
      );
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String text, {
    required String language,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    // Add user message
    _messages.add(
      ChatMessageModel(
        role: 'user',
        content: cleanText,
        language: language,
      ),
    );
    _isSending = true;
    notifyListeners();

    try {
      final response = await _apiService.sendChatMessage(
        query: cleanText,
        sessionId: _sessionId,
        language: language,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      );

      if (response.sessionId != null && response.sessionId!.isNotEmpty) {
        _sessionId = response.sessionId;
      }

      _messages.add(response);
      _isSending = false;
      notifyListeners();
    } catch (e) {
      _messages.add(
        ChatMessageModel(
          role: 'assistant',
          content: 'Sorry, I encountered an issue connecting to the meteorological services. Please verify your connection.',
          language: language,
        ),
      );
      _isSending = false;
      notifyListeners();
    }
  }

  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _sessionId = null;
    _addInitialGreeting();
    notifyListeners();
  }
}

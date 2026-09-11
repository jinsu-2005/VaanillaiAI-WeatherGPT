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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  String _currentLanguage = 'en'; // 'en', 'ta', 'hi'

  String get currentLanguage => _currentLanguage;

  LocaleProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (['en', 'ta', 'hi'].contains(lang)) {
      _currentLanguage = lang;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', lang);
      notifyListeners();
    }
  }

  // Localized string dictionary
  String t(String key) {
    return _translations[_currentLanguage]?[key] ?? _translations['en']?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'VaanilaiAI',
      'tagline': 'WeatherGPT & Disaster Intelligence',
      'home': 'Dashboard',
      'alerts': 'Alerts',
      'chat': 'WeatherGPT',
      'advisories': 'Advisories',
      'climate': 'Climate',
      'search_placeholder': 'Search Indian city, town, or village...',
      'current_weather': 'Current Weather',
      'hourly_forecast': '48-Hour Forecast',
      'daily_forecast': '7-Day Outlook',
      'air_quality': 'Air Quality Index',
      'uv_index': 'UV Index',
      'humidity': 'Humidity',
      'wind': 'Wind Speed',
      'pressure': 'Pressure',
      'feels_like': 'Feels Like',
      'rain_chance': 'Precipitation Prob.',
      'spraying_advisory': 'Agro Spraying Suitability',
      'travel_safety': 'Travel Safety Score',
      'listening': 'Listening to your voice...',
      'speak_hint': 'Tap and ask: "Will it rain tomorrow in Nagercoil?"',
      'moes_title': 'Ministry of Earth Sciences (MoES) / IMD',
      'no_active_warnings': 'No active severe weather warnings for this area.',
      'view_all_alerts': 'View Active Warnings',
      'favorable': 'Favorable',
      'risky': 'Risky',
      'unfavorable': 'Unfavorable',
      'online': 'Online',
      'offline': 'Offline',
      'offline_notice': 'You are offline. Showing cached weather data.',
      'back_online': 'Back online',
      'check_connection': 'Check Connection',
      'connection_status': 'Connection Status',
    },
    'ta': {
      'app_name': 'வானிலை AI',
      'tagline': 'வானிலைGPT & பேரிடர் மேலாண்மை',
      'home': 'முகப்பு',
      'alerts': 'எச்சரிக்கைகள்',
      'chat': 'வானிலைGPT',
      'advisories': 'ஆலோசனைகள்',
      'climate': 'காலநிலை',
      'search_placeholder': 'ஊர், நகரம் அல்லது கிராமத்தைத் தேடுக...',
      'current_weather': 'தற்போதைய வானிலை',
      'hourly_forecast': '48 மணிநேர முன்னறிவிப்பு',
      'daily_forecast': '7 நாட்கள் வானிலை',
      'air_quality': 'காற்றுத் தரம் (AQI)',
      'uv_index': 'புற ஊதா குறியீடு (UV)',
      'humidity': 'ஈரப்பதம்',
      'wind': 'காற்றின் வேகம்',
      'pressure': 'காற்றழுத்தம்',
      'feels_like': 'உணரும் வெப்பம்',
      'rain_chance': 'மழை வாய்ப்பு',
      'spraying_advisory': 'மருந்து தெளிக்கும் நிலை',
      'travel_safety': 'பயணப் பாதுகாப்பு மதிப்பீடு',
      'listening': 'பேசுங்கள், கேட்கிறது...',
      'speak_hint': 'கேளுங்கள்: "நாகர்கோவிலில் நாளை மழை பெய்யுமா?"',
      'moes_title': 'இந்திய புவி அறிவியல் அமைச்சகம் / IMD',
      'no_active_warnings': 'இப்பகுதியில் தீவிர வானிலை எச்சரிக்கைகள் இல்லை.',
      'view_all_alerts': 'அனைத்து எச்சரிக்கைகளையும் காண்க',
      'favorable': 'ஏற்றது',
      'risky': 'கவனமுடன்',
      'unfavorable': 'தவிர்க்கவும்',
      'online': 'ஆன்லைன்',
      'offline': 'ஆஃப்லைன்',
      'offline_notice': 'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள். சேமிக்கப்பட்ட வானிலை தரவு காட்டப்படுகிறது.',
      'back_online': 'இணைப்பு மீண்டும் கிடைத்தது',
      'check_connection': 'இணைப்பைச் சரிபார்க்கவும்',
      'connection_status': 'இணைப்பு நிலை',
    },
    'hi': {
      'app_name': 'वानिलाई AI',
      'tagline': 'वेदरGPT एवं आपदा प्रबंधन',
      'home': 'डैशबोर्ड',
      'alerts': 'चेतावनी',
      'chat': 'वेदरGPT',
      'advisories': 'सलाह',
      'climate': 'जलवायु',
      'search_placeholder': 'शहर, कस्बा या गांव खोजें...',
      'current_weather': 'वर्तमान मौसम',
      'hourly_forecast': '48-घंटे का पूर्वानुमान',
      'daily_forecast': '7-दिवसीय पूर्वानुमान',
      'air_quality': 'वायु गुणवत्ता सूचकांक (AQI)',
      'uv_index': 'यूवी इंडेक्स',
      'humidity': 'आर्द्रता (नमी)',
      'wind': 'हवा की गति',
      'pressure': 'वायुमंडलीय दबाव',
      'feels_like': 'महसूस तापमान',
      'rain_chance': 'बारिश की संभावना',
      'spraying_advisory': 'कीटनाशक छिड़काव उपयुक्तता',
      'travel_safety': 'यात्रा सुरक्षा स्कोर',
      'listening': 'सुन रहे हैं, बोलिए...',
      'speak_hint': 'पूछें: "क्या कल वाराणसी में बारिश होगी?"',
      'moes_title': 'पृथ्वी विज्ञान मंत्रालय (MoES) / IMD',
      'no_active_warnings': 'वर्तमान में इस क्षेत्र के लिए कोई गंभीर चेतावनी नहीं है।',
      'view_all_alerts': 'सभी चेतावनियां देखें',
      'favorable': 'अनुकूल',
      'risky': 'जोखिमपूर्ण',
      'unfavorable': 'प्रतिकूल',
      'online': 'ऑनलाइन',
      'offline': 'ऑफलाइन',
      'offline_notice': 'आप ऑफलाइन हैं। सुरक्षित मौसम डेटा दिखाया जा रहा है।',
      'back_online': 'पुनः ऑनलाइन',
      'check_connection': 'कनेक्शन जांचें',
      'connection_status': 'कनेक्शन स्थिति',
    },
  };
}

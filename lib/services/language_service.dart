import 'dart:ui';  
import 'dart:convert';  
import 'package:flutter/material.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
  
/// خدمة إدارة اللغات - اكتشاف لغة الجهاز وحفظ اللغة المختارة  
class LanguageService extends ChangeNotifier {  
  static final LanguageService _instance = LanguageService._internal();  
    
  factory LanguageService() => _instance;  
  LanguageService._internal();  
    
  late SharedPreferences _prefs;  
  String _currentLanguage = 'auto';  
  Map<String, String> _savedLanguages = {};  
    
  // قائمة اللغات المدعومة  
  static const Map<String, String> supportedLanguages = {  
    'auto': 'تلقائي',  
    'ar': 'العربية',  
    'en': 'English',  
    'fr': 'Français',  
    'de': 'Deutsch',  
    'es': 'Español',  
    'it': 'Italiano',  
    'pt': 'Português',  
    'ru': 'Русский',  
    'zh': '中文',  
    'ja': '日本語',  
    'ko': '한국어',  
    'hi': 'हिन्दी',  
    'tr': 'Türkçe',  
    'fa': 'فارسی',  
    'ur': 'اردو',  
  };  
    
  /// تهيئة الخدمة  
  Future<void> initialize() async {  
    _prefs = await SharedPreferences.getInstance();  
      
    // تحميل اللغة الحالية  
    _currentLanguage = _prefs.getString('current_language') ?? 'auto';  
      
    // تحميل اللغات المحفوظة لكل شاشة  
    try {  
      String? savedLanguagesJson = _prefs.getString('saved_languages');  
      if (savedLanguagesJson != null && savedLanguagesJson.isNotEmpty) {  
        _savedLanguages = Map<String, String>.from(jsonDecode(savedLanguagesJson));  
      }  
    } catch (e) {  
      _savedLanguages = {};  
    }  
      
    notifyListeners();  
  }  
    
  /// الحصول على لغة الجهاز  
  String getDeviceLanguage() {  
    return ui.window.locale.languageCode;  
  }  
    
  /// تعيين اللغة الحالية  
  Future<void> setCurrentLanguage(String languageCode) async {  
    _currentLanguage = languageCode;  
    await _prefs.setString('current_language', languageCode);  
    notifyListeners();  
  }  
    
  /// الحصول على اللغة الحالية  
  String getCurrentLanguage() {  
    return _currentLanguage;  
  }  
    
  /// حفظ لغة لشاشة معينة  
  Future<void> saveLanguageForScreen(String screenName, String languageCode) async {  
    _savedLanguages[screenName] = languageCode;  
    await _prefs.setString('saved_languages', jsonEncode(_savedLanguages));  
    notifyListeners();  
  }  
    
  /// الحصول على لغة محفوظة لشاشة معينة  
  String getLanguageForScreen(String screenName) {  
    return _savedLanguages[screenName] ?? 'auto';  
  }  
    
  // الحصول على اسم اللغة  
  String getLanguageName(String code) {  
    return supportedLanguages[code] ?? code.toUpperCase();  
  }  
    
  // الحصول على قائمة اللغات  
  List<String> getLanguageCodes() {  
    return supportedLanguages.keys.toList();  
  }  
}  

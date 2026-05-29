import 'dart:ui';  
import 'package:flutter/material.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
  
class LanguageService extends ChangeNotifier {  
  static final LanguageService _instance = LanguageService._internal();  
    
  factory LanguageService() => _instance;  
  LanguageService._internal();  
    
  late SharedPreferences _prefs;  
  String _deviceLanguage = 'en';  
  String _lastTranslationLanguage = 'en';  
  String _lastDialogueSourceLanguage = 'ar';  
  String _lastDialogueTargetLanguage = 'en';  
  String _lastDocumentLanguage = 'ar';  
    
  // Getters  
  String get deviceLanguage => _deviceLanguage;  
  String get lastTranslationLanguage => _lastTranslationLanguage;  
  String get lastDialogueSourceLanguage => _lastDialogueSourceLanguage;  
  String get lastDialogueTargetLanguage => _lastDialogueTargetLanguage;  
  String get lastDocumentLanguage => _lastDocumentLanguage;  
    
  /// Initialize the service  
  Future<void> initialize() async {  
    _prefs = await SharedPreferences.getInstance();  
    _deviceLanguage = _getDeviceLanguage();  
    _loadSavedLanguages();  
    notifyListeners();  
  }  
    
  /// Get device language  
  String _getDeviceLanguage() {  
    final locale = PlatformDispatcher.instance.locale;  
    return locale.languageCode;  
  }  
    
  /// Load saved languages from SharedPreferences  
  void _loadSavedLanguages() {  
    _lastTranslationLanguage = _prefs.getString('last_translation_lang') ?? _deviceLanguage;  
    _lastDialogueSourceLanguage = _prefs.getString('last_dialogue_source_lang') ?? 'ar';  
    _lastDialogueTargetLanguage = _prefs.getString('last_dialogue_target_lang') ?? 'en';  
    _lastDocumentLanguage = _prefs.getString('last_document_lang') ?? 'ar';  
  }  
    
  /// Save translation language  
  Future<void> saveTranslationLanguage(String language) async {  
    _lastTranslationLanguage = language;  
    await _prefs.setString('last_translation_lang', language);  
    notifyListeners();  
  }  
    
  /// Save dialogue source language  
  Future<void> saveDialogueSourceLanguage(String language) async {  
    _lastDialogueSourceLanguage = language;  
    await _prefs.setString('last_dialogue_source_lang', language);  
    notifyListeners();  
  }  
    
  /// Save dialogue target language  
  Future<void> saveDialogueTargetLanguage(String language) async {  
    _lastDialogueTargetLanguage = language;  
    await _prefs.setString('last_dialogue_target_lang', language);  
    notifyListeners();  
  }  
    
  /// Save document language  
  Future<void> saveDocumentLanguage(String language) async {  
    _lastDocumentLanguage = language;  
    await _prefs.setString('last_document_lang', language);  
    notifyListeners();  
  }  
    
  /// Get language name from code  
  String getLanguageName(String code) {  
    final names = {  
      'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',  
      'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',  
      'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'tr': 'Türkçe',  
      'ur': 'اردو', 'fa': 'فارسی', 'hi': 'हिन्दी', 'bn': 'বাংলা',  
      'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu', 'auto': 'لغة الجهاز',  
    };  
    return names[code] ?? code;  
  }  
}  

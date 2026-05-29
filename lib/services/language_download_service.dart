import 'dart:convert';  
import 'dart:io';  
import 'package:flutter/material.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:path_provider/path_provider.dart';  
  
/// خدمة إدارة تنزيل اللغات أوفلاين للنسخة البرو  
class LanguageDownloadService extends ChangeNotifier {  
  static final LanguageDownloadService _instance = LanguageDownloadService._internal();  
    
  factory LanguageDownloadService() => _instance;  
  LanguageDownloadService._internal();  
    
  late SharedPreferences _prefs;  
  Set<String> _downloadedLanguages = {};  
  Map<String, int> _languageUsageCount = {};  
    
  // اللغات المتاحة للتنزيل  
  static const Map<String, String> availableLanguages = {  
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
    'tr': 'Türkçe',  
    'ur': 'اردو',  
    'fa': 'فارسی',  
    'hi': 'हिन्दी',  
    'bn': 'বাংলা',  
  };  
    
  // الحصول على اللغات المحملة  
  Set<String> get downloadedLanguages => _downloadedLanguages;  
    
  // الحصول على عدد استخدامات كل لغة  
  Map<String, int> get languageUsageCount => _languageUsageCount;  
    
  // التحقق من أن اللغة محملة  
  bool isLanguageDownloaded(String languageCode) {  
    return _downloadedLanguages.contains(languageCode);  
  }  
    
  // تهيئة الخدمة  
  Future<void> initialize() async {  
    _prefs = await SharedPreferences.getInstance();  
      
    // تحميل اللغات المحملة  
    final downloadedJson = _prefs.getString('downloaded_languages');  
    if (downloadedJson != null) {  
      try {  
        final List<dynamic> downloadedList = jsonDecode(downloadedJson);  
        _downloadedLanguages = downloadedList.cast<String>().toSet();  
      } catch (e) {  
        debugPrint('Error loading downloaded languages: $e');  
      }  
    }  
      
    // تحميل عدد استخدامات اللغات  
    final usageJson = _prefs.getString('language_usage_count');  
    if (usageJson != null) {  
      try {  
        final Map<String, dynamic> usageMap = jsonDecode(usageJson);  
        _languageUsageCount = usageMap.map((key, value) => MapEntry(key, value as int));  
      } catch (e) {  
        debugPrint('Error loading language usage count: $e');  
      }  
    }  
      
    notifyListeners();  
  }  
    
  // تسجيل استخدام لغة  
  Future<void> recordLanguageUsage(String languageCode) async {  
    _languageUsageCount[languageCode] = (_languageUsageCount[languageCode] ?? 0) + 1;  
    await _prefs.setString('language_usage_count', jsonEncode(_languageUsageCount));  
    notifyListeners();  
  }  
    
  // تنزيل لغة (محاكاة - في الواقع سيتم تنزيل ملفات الترجمة)  
  Future<bool> downloadLanguage(String languageCode) async {  
    try {  
      // محاكاة التنزيل - في الواقع سيتم تنزيل ملفات الترجمة من السيرفر  
      await Future.delayed(const Duration(seconds: 2));  
        
      _downloadedLanguages.add(languageCode);  
      await _prefs.setString('downloaded_languages', jsonEncode(_downloadedLanguages.toList()));  
      notifyListeners();  
        
      return true;  
    } catch (e) {  
      debugPrint('Error downloading language: $e');  
      return false;  
    }  
  }  
    
  // حذف لغة  
  Future<bool> removeLanguage(String languageCode) async {  
    try {  
      _downloadedLanguages.remove(languageCode);  
      await _prefs.setString('downloaded_languages', jsonEncode(_downloadedLanguages.toList()));  
      notifyListeners();  
        
      return true;  
    } catch (e) {  
      debugPrint('Error removing language: $e');  
      return false;  
    }  
  }  
    
  // تنزيل اللغات الأكثر استخداماً تلقائياً عند تفعيل النسخة البرو  
  Future<void> downloadMostUsedLanguages() async {  
    // ترتيب اللغات حسب الاستخدام  
    final sortedLanguages = _languageUsageCount.entries.toList()  
      ..sort((a, b) => b.value.compareTo(a.value));  
      
    // تنزيل أفضل 5 لغات  
    for (var i = 0; i < sortedLanguages.length && i < 5; i++) {  
      final languageCode = sortedLanguages[i].key;  
      if (!_downloadedLanguages.contains(languageCode)) {  
        await downloadLanguage(languageCode);  
      }  
    }  
  }  
    
  // الحصول على حجم اللغة (محاكاة)  
  int getLanguageSize(String languageCode) {  
    // أحجام تقريبية بالـ MB  
    final sizes = {  
      'ar': 15,  
      'en': 12,  
      'fr': 11,  
      'de': 10,  
      'es': 11,  
      'it': 10,  
      'pt': 10,  
      'ru': 14,  
      'zh': 18,  
      'ja': 16,  
      'ko': 15,  
      'tr': 9,  
      'ur': 8,  
      'fa': 9,  
      'hi': 13,  
      'bn': 12,  
    };  
    return sizes[languageCode] ?? 10;  
  }  
}  

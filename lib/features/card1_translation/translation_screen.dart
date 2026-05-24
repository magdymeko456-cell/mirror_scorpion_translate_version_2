import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  
  String _selectedLanguage = 'ar'; // Default: Arabic
  bool _isTranslating = false;
  bool _isListening = false;

  // 100 languages support
  final Map<String, String> _languages = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': 'Japanese',
    'zh': '中文',
    'ko': '한국어',
    'tr': 'Türkçe',
    'pl': 'Polski',
    'nl': 'Nederlands',
    'sv': 'Svenska',
    'no': 'Norsk',
    'da': 'Dansk',
    'fi': 'Suomi',
    'el': 'Ελληνικά',
    'cs': 'Čeština',
    'hu': 'Magyar',
    'ro': 'Română',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'id': 'Bahasa Indonesia',
    'ms': 'Bahasa Melayu',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'ur': 'اردو',
    'fa': 'فارسی',
    'he': 'עברית',
    'af': 'Afrikaans',
    'sq': 'Shqip',
    'am': 'አማርኛ',
    'hy': 'Հայերեն',
    'az': 'Azərbaycanca',
    'eu': 'Euskera',
    'be': 'Беларусь',
    'bs': 'Bosanski',
    'bg': 'Български',
    'ca': 'Català',
    'ceb': 'Cebuano',
    'ny': 'Chichewa',
    'co': 'Corsu',
    'hr': 'Hrvatski',
    'et': 'Eesti',
    'tl': 'Filipino',
    'fy': 'Frisian',
    'gl': 'Galego',
    'ka': 'Georgian',
    'gu': 'Gujarati',
    'ht': 'Haitian Creole',
    'ha': 'Hausa',
    'haw': 'Hawaiian',
    'is': 'Íslenska',
    'ig': 'Igbo',
    'ga': 'Irish',
    'jw': 'Javanese',
    'kk': 'Kazakh',
    'km': 'Khmer',
    'rw': 'Kinyarwanda',
    'ku': 'Kurdish',
    'ky': 'Kyrgyz',
    'lo': 'Lao',
    'la': 'Latin',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'lb': 'Luxembourgish',
    'mk': 'Macedonian',
    'mg': 'Malagasy',
    'mt': 'Maltese',
    'mi': 'Maori',
    'mr': 'Marathi',
    'mn': 'Mongolian',
    'my': 'Myanmar',
    'ne': 'Nepali',
    'pa': 'Punjabi',
    'sm': 'Samoan',
    'gd': 'Scottish Gaelic',
    'sr': 'Serbian',
    'st': 'Sesotho',
    'sn': 'Shona',
    'sd': 'Sindhi',
    'si': 'Sinhala',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'so': 'Somali',
    'su': 'Sundanese',
    'sw': 'Swahili',
    'tg': 'Tajik',
    'ta': 'Tamil',
    'te': 'Telugu',
    'uk': 'Ukrainian',
    'uz': 'Uzbek',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'zu': 'Zulu',
  };

  @override
  void initState() {
    super.initState();
    _initializeSpeechAndTTS();
  }

  Future<void> _initializeSpeechAndTTS() async {
    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
    
    await _speechToText.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );

    await _flutterTts.setLanguage(_selectedLanguage);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    _scrollController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!_isListening && await _speechToText.initialize()) {
      setState(() {
        _isListening = true;
        _sourceController.clear();
      });
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _sourceController.text = result.recognizedWords;
          });
        },
        localeId: 'en',
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _translateText() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(text)}'
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() {
          _translatedController.text = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      setState(() => _isTranslating = false);
    }
  }

  Future<void> _speakTranslation() async {
    try {
      await _flutterTts.setLanguage(_selectedLanguage);
      await _flutterTts.speak(_translatedController.text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  Future<void> _shareAudio() async {
    final text = _translatedController.text;
    if (text.isEmpty) return;
    
    // Create a message with the translated text and app signature
    final message = '''$text

ترجمة بواسطة ميرور سكربيون
Mirror Scorpion - حيث تُصنع البدايات''';
    
    // Copy to clipboard and show message
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ الرسالة مع التوقيع')),
      );
    }
  }

  Future<void> _copyTranslation() async {
    final text = _translatedController.text;
    if (text.isEmpty) return;
    
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ الترجمة')),
      );
    }
  }

  void _clearAll() {
    setState(() {
      _sourceController.clear();
      _translatedController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة نصوص', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)]
          )
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Language Selector (100 languages)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1B2838),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _languages.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Source Text Editor
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النص الأصلي',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sourceController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'اكتب أو انطق النص هنا...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Microphone button
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isListening ? Colors.red : Colors.blue,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              color: _isListening ? Colors.red : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isListening ? 'إيقاف الاستماع' : 'اضغط للتحدث',
                              style: TextStyle(
                                color: _isListening ? Colors.red : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Translate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTranslating ? null : _translateText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isTranslating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'ترجمة',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // Translated Text Editor
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النص المترجم',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _translatedController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'الترجمة ستظهر هنا...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Speaker button
                        GestureDetector(
                          onTap: _translatedController.text.isEmpty ? null : _speakTranslation,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Icon(Icons.volume_up, color: Colors.green, size: 20),
                          ),
                        ),
                        // Share button
                        GestureDetector(
                          onTap: _translatedController.text.isEmpty ? null : _shareAudio,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Icon(Icons.share, color: Colors.orange, size: 20),
                          ),
                        ),
                        // Copy button
                        GestureDetector(
                          onTap: _translatedController.text.isEmpty ? null : _copyTranslation,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purple),
                            ),
                            child: const Icon(Icons.content_copy, color: Colors.purple, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Clear button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _clearAll,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'مسح الكل',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

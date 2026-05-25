import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  late stt.SpeechToText _speechToText;
  
  String _selectedLanguage = 'ar';
  bool _isTranslating = false;
  bool _isListening = false;

  final Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'ja': 'Japanese', 'zh': '中文', 'ko': '한국어', 'tr': 'Türkçe',
    // ... more languages can be added
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _speechToText.initialize();
  }

  Future<void> _handleMic() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
    } else {
      _sourceController.clear();
      _translatedController.clear();
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() => _sourceController.text = result.recognizedWords);
          },
        );
      }
    }
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(_sourceController.text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() => _translatedController.text = translated);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _shareAudio() {
    // Simulate sharing audio file message
    final message = "${_translatedController.text}\n\nتمت الترجمة بواسطة ميرور سكربيون";
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النص مع التوقيع للمشاركة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Language Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1B2838),
                  underline: const SizedBox(),
                  items: _languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (v) => setState(() => _selectedLanguage = v!),
                ),
              ),
              const SizedBox(height: 20),
              // Source Editor
              _buildEditor(_sourceController, 'اكتب أو انطق النص...', Icons.mic, _handleMic, _isListening),
              const SizedBox(height: 20),
              // Translate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTranslating ? null : _translate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: _isTranslating ? const CircularProgressIndicator(color: Colors.white) : const Text('ترجمة'),
                ),
              ),
              const SizedBox(height: 20),
              // Translated Editor
              _buildTranslatedEditor(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(TextEditingController controller, String hint, IconData icon, VoidCallback onIconTap, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none),
            onChanged: (v) {
              if (v.isNotEmpty) {
                // Future enhancement: Auto-clear on new input if needed
              }
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              icon: Icon(icon, color: isActive ? Colors.red : Colors.blue),
              onPressed: onIconTap,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTranslatedEditor() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _translatedController,
            maxLines: 5,
            readOnly: true,
            style: const TextStyle(color: Colors.amber),
            decoration: const InputDecoration(hintText: 'الترجمة تظهر هنا...', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blue),
                onPressed: () => Provider.of<TTSService>(context, listen: false).speak(_translatedController.text),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.green),
                onPressed: _shareAudio,
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white70),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _translatedController.text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ النص')));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

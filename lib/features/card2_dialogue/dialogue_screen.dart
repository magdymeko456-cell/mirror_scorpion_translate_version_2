import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> {
  final List<Map<String, dynamic>> _chatHistory = [];
  late stt.SpeechToText _speechToText;
  
  String _leftLang = 'ar'; // User 1
  String _rightLang = 'en'; // User 2
  bool _isListeningLeft = false;
  bool _isListeningRight = false;
  bool _isListeningAuto = false;

  final Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'tr': 'Türkçe', 'ru': 'Русский',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  Future<void> _listen(String langCode, bool isLeft) async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        if (isLeft) _isListeningLeft = true;
        else _isListeningRight = true;
      });
      
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _handleTranslation(result.recognizedWords, langCode, isLeft ? _rightLang : _leftLang);
            setState(() {
              _isListeningLeft = false;
              _isListeningRight = false;
            });
          }
        },
        localeId: langCode,
      );
    }
  }

  Future<void> _handleTranslation(String text, String from, String to) async {
    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$from&tl=$to&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        
        setState(() {
          _chatHistory.add({
            'original': text,
            'translated': translated,
            'from': from,
            'to': to,
            'isLeft': from == _leftLang,
          });
        });
        
        // Auto speak
        Provider.of<TTSService>(context, listen: false).speak(translated);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('محادثة', style: TextStyle(color: Colors.black, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline, color: Colors.black54), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Language Selectors (Google Style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLangDropdown(_leftLang, (v) => setState(() => _leftLang = v!)),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.blueAccent),
                  onPressed: () {
                    setState(() {
                      final temp = _leftLang;
                      _leftLang = _rightLang;
                      _rightLang = temp;
                    });
                  },
                ),
                _buildLangDropdown(_rightLang, (v) => setState(() => _rightLang = v!)),
              ],
            ),
          ),
          
          // Chat Area
          Expanded(
            child: _chatHistory.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('ابدأ التحدث بالضغط على الميكروفون', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final item = _chatHistory[index];
                    return _buildChatItem(item);
                  },
                ),
          ),
          
          // Mic Controls (Google Translate Clone)
          Container(
            padding: const EdgeInsets.only(bottom: 30, top: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left Mic
                _buildMicBtn(_languages[_leftLang]!, _isListeningLeft, () => _listen(_leftLang, true)),
                
                // Auto Mic (Middle)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {}, // Auto logic
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.blue, size: 28),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('تلقائي', style: TextStyle(fontSize: 10, color: Colors.blue)),
                  ],
                ),
                
                // Right Mic
                _buildMicBtn(_languages[_rightLang]!, _isListeningRight, () => _listen(_rightLang, false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        items: _languages.entries.map((e) => DropdownMenuItem(
          value: e.key,
          child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMicBtn(String label, bool isActive, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.redAccent : Colors.blueAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isActive ? Colors.red : Colors.blue).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(isActive ? Icons.stop : Icons.mic, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildChatItem(Map<String, dynamic> item) {
    bool isLeft = item['isLeft'];
    return Align(
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(item['original'], style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLeft ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: isLeft ? null : Border.all(color: Colors.grey.shade300),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Text(
                item['translated'],
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: isLeft ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

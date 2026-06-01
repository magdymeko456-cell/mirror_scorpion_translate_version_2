import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  
  String _sourceLanguage = 'ar';
  String _targetLanguage = 'en';
  bool _isTranslating = false;

  final List<Map<String, String>> languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'},
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _performTranslation() async {
    if (_sourceController.text.isEmpty) {
      _showSnackBar('أدخل رسالتك أولاً');
      return;
    }

    setState(() => _isTranslating = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _targetController.text = 'الترجمة: ${_sourceController.text}';
      
      final ttsService = Provider.of<TTSService>(context, listen: false);
      await ttsService.speak(_targetController.text, _targetLanguage);
      
    } catch (e) {
      _showSnackBar('خطأ: $e');
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حوار مترجم'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildControlBar(),
            const SizedBox(height: 24),
            _buildSourceBox(),
            const SizedBox(height: 16),
            _buildTranslateButton(),
            const SizedBox(height: 16),
            _buildTargetBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _sourceLanguage,
              onChanged: (lang) => setState(() => _sourceLanguage = lang ?? _sourceLanguage),
              isExpanded: true,
              items: languages.map((l) => DropdownMenuItem(
                value: l['code'],
                child: Text(l['name'] ?? ''),
              )).toList(),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => setState(() {
              final temp = _sourceLanguage;
              _sourceLanguage = _targetLanguage;
              _targetLanguage = temp;
            }),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () => _sourceController.text = 'محادثة',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButton<String>(
              value: _targetLanguage,
              onChanged: (lang) => setState(() => _targetLanguage = lang ?? _targetLanguage),
              isExpanded: true,
              items: languages.map((l) => DropdownMenuItem(
                value: l['code'],
                child: Text(l['name'] ?? ''),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('رسالتك ($_sourceLanguage)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _sourceController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'أكتب أو التقط رسالتك',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton() {
    return ElevatedButton.icon(
      onPressed: _isTranslating ? null : _performTranslation,
      icon: _isTranslating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.translate),
      label: Text(_isTranslating ? 'جاري...' : 'ترجمة'),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
    );
  }

  Widget _buildTargetBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(12),
        color: Colors.green.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الترجمة ($_targetLanguage)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _targetController,
            maxLines: 3,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'الترجمة ستظهر هنا',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 8),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.speaker_notes),
                onPressed: _targetController.text.isEmpty ? null : () {
                  Provider.of<TTSService>(context, listen: false)
                      .speak(_targetController.text, _targetLanguage);
                },
              ),
              IconButton(
                icon: const Icon(Icons.content_copy),
                onPressed: _targetController.text.isEmpty ? null : () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';  
import 'package:flutter/services.dart';  
  
class FloatingBubbleService {  
  static const MethodChannel _channel = MethodChannel('floating_bubble');  
    
  bool _isBubbleVisible = false;  
  String _sourceText = '';  
  String _translatedText = '';  
  String _sourceLanguage = 'auto';  
  String _targetLanguage = 'ar';  
    
  bool get isBubbleVisible => _isBubbleVisible;  
  String get sourceText => _sourceText;  
  String get translatedText => _translatedText;  
  String get sourceLanguage => _sourceLanguage;  
  String get targetLanguage => _targetLanguage;  
    
  Future<void> showBubble() async {  
    try {  
      await _channel.invokeMethod('showBubble');  
      _isBubbleVisible = true;  
    } catch (e) {  
      print('Error showing bubble: $e');  
    }  
  }  
    
  Future<void> hideBubble() async {  
    try {  
      await _channel.invokeMethod('hideBubble');  
      _isBubbleVisible = false;  
    } catch (e) {  
      print('Error hiding bubble: $e');  
    }  
  }  
    
  Future<void> toggleBubble() async {  
    if (_isBubbleVisible) {  
      await hideBubble();  
    } else {  
      await showBubble();  
    }  
  }  
    
  void updateSourceText(String text) {  
    _sourceText = text;  
  }  
    
  void updateTranslatedText(String text) {  
    _translatedText = text;  
  }  
    
  void setSourceLanguage(String language) {  
    _sourceLanguage = language;  
  }  
    
  void setTargetLanguage(String language) {  
    _targetLanguage = language;  
  }  
    
  Future<void> translateText() async {  
    // هنا سيتم استدعاء خدمة الترجمة الفعلية  
    // مؤقتاً سنضع نص تجريبي  
    _translatedText = 'ترجمة: $_sourceText';  
  }  
    
  Future<void> copyToClipboard(String text) async {  
    await Clipboard.setData(ClipboardData(text: text));  
  }  
    
  Future<String> pasteFromClipboard() async {  
    final clipboardData = await Clipboard.getData('text/plain');  
    return clipboardData?.text ?? '';  
  }  
}  
  
class BubbleContentWidget extends StatefulWidget {  
  final FloatingBubbleService bubbleService;  
    
  const BubbleContentWidget({  
    super.key,  
    required this.bubbleService,  
  });  
    
  @override  
  State<BubbleContentWidget> createState() => _BubbleContentWidgetState();  
}  
  
class _BubbleContentWidgetState extends State<BubbleContentWidget> {  
  final TextEditingController _sourceController = TextEditingController();  
  final TextEditingController _targetController = TextEditingController();  
    
  @override  
  void initState() {  
    super.initState();  
    _sourceController.text = widget.bubbleService.sourceText;  
    _targetController.text = widget.bubbleService.translatedText;  
  }  
    
  @override  
  void dispose() {  
    _sourceController.dispose();  
    _targetController.dispose();  
    super.dispose();  
  }  
    
  @override  
  Widget build(BuildContext context) {  
    return Container(  
      width: 300,  
      height: 400,  
      decoration: BoxDecoration(  
        color: Colors.white,  
        borderRadius: BorderRadius.circular(16),  
        boxShadow: [  
          BoxShadow(  
            color: Colors.black.withOpacity(0.2),  
            blurRadius: 10,  
            offset: const Offset(0, 5),  
          ),  
        ],  
      ),  
      child: Column(  
        children: [  
          // Header  
          Container(  
            padding: const EdgeInsets.all(12),  
            decoration: BoxDecoration(  
              color: Colors.blue.shade700,  
              borderRadius: const BorderRadius.only(  
                topLeft: Radius.circular(16),  
                topRight: Radius.circular(16),  
              ),  
            ),  
            child: Row(  
              mainAxisAlignment: MainAxisAlignment.spaceBetween,  
              children: [  
                const Text(  
                  'الترجمة السريعة',  
                  style: TextStyle(  
                    color: Colors.white,  
                    fontWeight: FontWeight.bold,  
                    fontSize: 16,  
                  ),  
                ),  
                IconButton(  
                  icon: const Icon(Icons.close, color: Colors.white),  
                  onPressed: () {  
                    widget.bubbleService.hideBubble();  
                  },  
                ),  
              ],  
            ),  
          ),  
            
          // Language Selection  
          Padding(  
            padding: const EdgeInsets.all(8.0),  
            child: Row(  
              children: [  
                Expanded(  
                  child: _buildLanguageDropdown(  
                    value: widget.bubbleService.sourceLanguage,  
                    items: ['auto', 'en', 'ar', 'fr', 'de', 'es', 'it'],  
                    onChanged: (value) {  
                      if (value != null) {  
                        widget.bubbleService.setSourceLanguage(value);  
                        setState(() {});  
                      }  
                    },  
                  ),  
                ),  
                const Icon(Icons.arrow_forward, size: 20),  
                Expanded(  
                  child: _buildLanguageDropdown(  
                    value: widget.bubbleService.targetLanguage,  
                    items: ['ar', 'en', 'fr', 'de', 'es', 'it', 'zh', 'ja'],  
                    onChanged: (value) {  
                      if (value != null) {  
                        widget.bubbleService.setTargetLanguage(value);  
                        setState(() {});  
                      }  
                    },  
                  ),  
                ),  
              ],  
            ),  
          ),  
            
          // Source Text Field  
          Padding(  
            padding: const EdgeInsets.symmetric(horizontal: 8.0),  
            child: TextField(  
              controller: _sourceController,  
              maxLines: 4,  
              decoration: InputDecoration(  
                hintText: 'أدخل النص للترجمة...',  
                border: OutlineInputBorder(  
                  borderRadius: BorderRadius.circular(8),  
                ),  
                suffixIcon: IconButton(  
                  icon: const Icon(Icons.paste),  
                  onPressed: () async {  
                    final text = await widget.bubbleService.pasteFromClipboard();  
                    _sourceController.text = text;  
                    widget.bubbleService.updateSourceText(text);  
                  },  
                ),  
              ),  
              onChanged: (text) {  
                widget.bubbleService.updateSourceText(text);  
              },  
            ),  
          ),  
            
          const SizedBox(height: 8),  
            
          // Translate Button  
          Padding(  
            padding: const EdgeInsets.symmetric(horizontal: 8.0),  
            child: ElevatedButton(  
              onPressed: () async {  
                await widget.bubbleService.translateText();  
                _targetController.text = widget.bubbleService.translatedText;  
              },  
              style: ElevatedButton.styleFrom(  
                backgroundColor: Colors.blue.shade700,  
                foregroundColor: Colors.white,  
                minimumSize: const Size(double.infinity, 45),  
              ),  
              child: const Text('ترجمة'),  
            ),  
          ),  
            
          const SizedBox(height: 8),  
            
          // Target Text Field  
          Padding(  
            padding: const EdgeInsets.symmetric(horizontal: 8.0),  
            child: TextField(  
              controller: _targetController,  
              maxLines: 4,  
              decoration: InputDecoration(  
                hintText: 'الترجمة ستظهر هنا...',  
                border: OutlineInputBorder(  
                  borderRadius: BorderRadius.circular(8),  
                ),  
                suffixIcon: IconButton(  
                  icon: const Icon(Icons.copy),  
                  onPressed: () {  
                    widget.bubbleService.copyToClipboard(_targetController.text);  
                  },  
                ),  
              ),  
              readOnly: true,  
            ),  
          ),  
            
          const Spacer(),  
            
          // Footer  
          Container(  
            padding: const EdgeInsets.all(8),  
            decoration: BoxDecoration(  
              color: Colors.grey.shade100,  
              borderRadius: const BorderRadius.only(  
                bottomLeft: Radius.circular(16),  
                bottomRight: Radius.circular(16),  
              ),  
            ),  
            child: Row(  
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,  
              children: [  
                TextButton.icon(  
                  onPressed: () {  
                    widget.bubbleService.hideBubble();  
                  },  
                  icon: const Icon(Icons.close, size: 16),  
                  label: const Text('إغلاق'),  
                ),  
                TextButton.icon(  
                  onPressed: () {  
                    _sourceController.clear();  
                    _targetController.clear();  
                    widget.bubbleService.updateSourceText('');  
                    widget.bubbleService.updateTranslatedText('');  
                  },  
                  icon: const Icon(Icons.clear, size: 16),  
                  label: const Text('مسح'),  
                ),  
              ],  
            ),  
          ),  
        ],  
      ),  
    );  
  }  
    
  Widget _buildLanguageDropdown({  
    required String value,  
    required List<String> items,  
    required Function(String?) onChanged,  
  }) {  
    return DropdownButtonFormField<String>(  
      value: value,  
      decoration: InputDecoration(  
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),  
        border: OutlineInputBorder(  
          borderRadius: BorderRadius.circular(8),  
        ),  
      ),  
      items: items.map((String item) {  
        return DropdownMenuItem<String>(  
          value: item,  
          child: Text(  
            item == 'auto' ? 'تلقائي' : item.toUpperCase(),  
            style: const TextStyle(fontSize: 12),  
          ),  
        );  
      }).toList(),  
      onChanged: onChanged,  
    );  
  }  
}  

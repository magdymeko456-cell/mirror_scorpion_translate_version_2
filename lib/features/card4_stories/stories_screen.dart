import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import '../../services/ai_service.dart';  
import '../../services/tts_service.dart';  
import '../../services/database_service.dart';  
  
class StoriesScreen extends StatefulWidget {  
  const StoriesScreen({super.key});  
  
  @override  
  State<StoriesScreen> createState() => _StoriesScreenState();  
}  
  
class _StoriesScreenState extends State<StoriesScreen> with TickerProviderStateMixin {  
  late TabController _tabController;  
  List<Map<String, dynamic>> _hadiths = [];  
  List<Map<String, dynamic>> _stories = [];  
  bool _dataLoaded = false;  
  String _storyFilter = 'الكل';  
  final TextEditingController _inspirationController = TextEditingController();  
  String _inspirationResult = '';  
  bool _isGenerating = false;  
  bool _autoInspirationEnabled = false;  
  
  static const List<String> _storyCategories = [  
    'الكل', 'قصص قرآنية', 'قصص الأنبياء', 'نساء مؤمنات',  
    'قصص الحيوان', 'قصص البشر', 'الأمم السابقة',  
  ];  
  
  @override  
  void initState() {  
    super.initState();  
    _tabController = TabController(length: 4, vsync: this);  
    _loadData();  
  }  
  
  @override  
  void dispose() {  
    _tabController.dispose();  
    _inspirationController.dispose();  
    super.dispose();  
  }  
  
  Future<void> _loadData() async {  
    final db = Provider.of<DatabaseService>(context, listen: false);  
    await db.loadAllData();  
    setState(() {  
      _hadiths = List.from(db.hadiths)..shuffle();  
      _stories = [  
        ...db.quranStories.map((e) => {...e, 'category': 'قصص قرآنية'}),  
        ...db.prophetStories.map((e) => {...e, 'category': 'قصص الأنبياء'}),  
        ...db.womenStories.map((e) => {...e, 'category': 'نساء مؤمنات'}),  
        ...db.animalStories.map((e) => {...e, 'category': 'قصص الحيوان'}),  
        ...db.humanStories.map((e) => {...e, 'category': 'قصص البشر'}),  
        ...db.nationsStories.map((e) => {...e, 'category': 'الأمم السابقة'}),  
      ];  
      _dataLoaded = true;  
    });  
  }  
  
  void _showStoryDialog(Map<String, dynamic> story) {  
    showDialog(  
      context: context,  
      builder: (context) => Dialog.fullscreen(  
        child: Container(  
          decoration: const BoxDecoration(  
            gradient: LinearGradient(  
              begin: Alignment.topCenter,  
              end: Alignment.bottomCenter,  
              colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],  
            ),  
          ),  
          child: Scaffold(  
            backgroundColor: Colors.transparent,  
            appBar: AppBar(  
              backgroundColor: Colors.transparent,  
              elevation: 0,  
              title: Text(story['title'] ?? 'قصة', style: const TextStyle(color: Colors.white)),  
              leading: IconButton(  
                icon: const Icon(Icons.close, color: Colors.white),  
                onPressed: () => Navigator.pop(context),  
              ),  
            ),  
            body: SingleChildScrollView(  
              padding: const EdgeInsets.all(24),  
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [  
                  Row(  
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                    children: [  
                      _buildActionBtn(  
                        icon: Icons.volume_up,  
                        label: 'سماع القصة',  
                        color: Colors.blueAccent,  
                        onTap: () => Provider.of<TTSService>(context, listen: false).speak(story['text_ar'] ?? story['text'] ?? ''),  
                      ),  
                      _buildActionBtn(  
                        icon: Icons.video_library,  
                        label: 'مشاهدة القصة',  
                        color: Colors.redAccent,  
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(  
                          const SnackBar(content: Text('سيتم توليد فيديو ذكاء اصطناعي مذهل مدته 10-15 دقيقة (نسخة برو)')),  
                        ),  
                      ),  
                    ],  
                  ),  
                  const SizedBox(height: 30),  
                  Text(  
                    story['text_ar'] ?? story['text'] ?? '',  
                    style: const TextStyle(  
                      color: Colors.white,  
                      fontSize: 20,  
                      height: 1.8,  
                      fontWeight: FontWeight.w400,  
                    ),  
                    textDirection: TextDirection.rtl,  
                  ),  
                  const SizedBox(height: 50),  
                ],  
              ),  
            ),  
          ),  
        ),  
      ),  
    );  
  }  
  
  Widget _buildActionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {  
    return InkWell(  
      onTap: onTap,  
      child: Column(  
        children: [  
          Container(  
            padding: const EdgeInsets.all(12),  
            decoration: BoxDecoration(  
              color: color.withOpacity(0.1),  
              shape: BoxShape.circle,  
              border: Border.all(color: color.withOpacity(0.5)),  
            ),  
            child: Icon(icon, color: color, size: 28),  
          ),  
          const SizedBox(height: 8),  
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),  
        ],  
      ),  
    );  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: const Text('أحاديث وقصص وإلهام', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),  
        backgroundColor: const Color(0xFF0D1B2A),  
        centerTitle: true,  
        bottom: TabBar(  
          controller: _tabController,  
          indicatorColor: Colors.amber,  
          labelColor: Colors.amber,  
          unselectedLabelColor: Colors.white70,  
          tabs: const [  
            Tab(text: 'أحاديث'),  
            Tab(text: 'قصص'),  
            Tab(text: 'أسباب النزول'),  
            Tab(text: 'إلهام AI'),  
          ],  
        ),  
      ),  
      body: Container(  
        decoration: const BoxDecoration(  
          gradient: LinearGradient(  
            begin: Alignment.topCenter,  
            end: Alignment.bottomCenter,  
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)]  
          )  
        ),  
        child: _dataLoaded  
            ? TabBarView(  
                controller: _tabController,  
                children: [  
                  _buildHadithsTab(),  
                  _buildStoriesTab(),  
                  _buildRevelationTab(),  
                  _buildInspirationTab(),  
                ],  
              )  
            : const Center(child: CircularProgressIndicator(color: Colors.amber)),  
      ),  
    );  
  }  
  
  Widget _buildHadithsTab() {  
    return ListView.builder(  
      padding: const EdgeInsets.all(16),  
      itemCount: _hadiths.length,  
      itemBuilder: (context, index) {  
        final hadith = _hadiths[index];  
        return _buildContentCard(  
          title: hadith['narrator'] ?? 'حديث قدسي',  
          content: hadith['text'] ?? '',  
          subtitle: "${hadith['source'] ?? ''}\n${hadith['explanation'] ?? ''}",  
          icon: Icons.auto_stories,  
          color: Colors.amber,  
          isHadith: true,  
        );  
      },  
    );  
  }  
  
  Widget _buildStoriesTab() {  
    final filtered = _storyFilter == 'الكل'  
        ? _stories  
        : _stories.where((s) => s['category'] == _storyFilter).toList();  
  
    return Column(  
      children: [  
        Container(  
          height: 60,  
          padding: const EdgeInsets.symmetric(vertical: 8),  
          child: ListView(  
            scrollDirection: Axis.horizontal,  
            padding: const EdgeInsets.symmetric(horizontal: 16),  
            children: _storyCategories.map((cat) {  
              final isSelected = _storyFilter == cat;  
              return Padding(  
                padding: const EdgeInsets.only(left: 8),  
                child: FilterChip(  
                  label: Text(cat, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),  
                  selected: isSelected,  
                  onSelected: (_) => setState(() => _storyFilter = cat),  
                  selectedColor: Colors.amber,  
                  backgroundColor: Colors.white.withOpacity(0.1),  
                ),  
              );  
            }).toList(),  
          ),  
        ),  
        Expanded(  
          child: ListView.builder(  
            padding: const EdgeInsets.all(16),  
            itemCount: filtered.length,  
            itemBuilder: (context, index) {  
              final story = filtered[index];  
              return _buildContentCard(  
                title: story['title'] ?? '',  
                content: story['text_ar'] ?? story['text'] ?? '',  
                subtitle: story['category'] ?? '',  
                icon: Icons.history_edu,  
                color: Colors.blueAccent,  
                showVideoBtn: true,  
                showListenBtn: true,  
                onTap: () => _showStoryDialog(story),  
              );  
            },  
          ),  
        ),  
      ],  
    );  
  }  
  
  Widget _buildRevelationTab() {  
    return ListView.builder(  
      padding: const EdgeInsets.all(16),  
      itemCount: _stories.length,  
      itemBuilder: (context, index) {  
        final story = _stories[index];  
        return _buildRevelationCard(  
          title: story['title'] ?? '',  
          beforeRevelation: _getBeforeRevelation(story),  
          afterRevelation: _getAfterRevelation(story),  
          icon: Icons.menu_book,  
          color: Colors.greenAccent,  
        );  
      },  
    );  
  }  
  
  String _getBeforeRevelation(Map<String, dynamic> story) {  
    // محتوى افتراضي قبل النزول - يمكن توسيعه لاحقاً  
    final title = story['title'] ?? '';  
    if (title.contains('يوسف')) {  
      return 'قبل نزول قصة يوسف عليه السلام، كان المجتمع في مصر يعاني من الفساد والظلم، وكان يوسف عليه السلام يعيش في محنة السجن بعد أن اتهم ظلماً.';  
    } else if (title.contains('موسى')) {  
      return 'قبل نزول قصة موسى عليه السلام، كان بنو إسرائيل يعانون من ظلم فرعون واستعباده لهم، وكانوا يبحثون عن المخلص.';  
    } else if (title.contains('عيسى')) {  
      return 'قبل نزول قصة عيسى عليه السلام، كان بنو إسرائيل قد انحرفوا عن الشريعة، وكانوا بحاجة إلى رسالة جديدة تذكرهم بالتوحيد.';  
    } else {  
      return 'قبل نزول هذه القصة، كان الناس يعيشون في جاهلية وضلال، وكانوا بحاجة إلى هداية ربانية.';  
    }  
  }  
  
  String _getAfterRevelation(Map<String, dynamic> story) {  
    // محتوى افتراضي بعد النزول - يمكن توسيعه لاحقاً  
    final title = story['title'] ?? '';  
    if (title.contains('يوسف')) {  
      return 'بعد نزول قصة يوسف عليه السلام، أصبح يوسف وزيراً على خزائن مصر، وعفى عن إخوته، وتحققت وعد الله في نصرته للمؤمنين الصابرين.';  
    } else if (title.contains('موسى')) {  
      return 'بعد نزول قصة موسى عليه السلام، نجى الله بني إسرائيل من فرعون، وأغرق فرعون وجنوده، وأعطى موسى التوراة هداية للبشر.';  
    } else if (title.contains('عيسى')) {  
      return 'بعد نزول قصة عيسى عليه السلام، جاء بالمعجزات والهدى، ودعا إلى التوحيد، وأعطى الإنجيل هداية لأتباعه.';  
    } else {  
      return 'بعد نزول هذه القصة، اهتدى الناس بالحق، وتعلموا الدروس والعبر، وأصبحت القصة مصدر إلهام للأجيال.';  
    }  
  }  
  
  Widget _buildRevelationCard({  
    required String title,  
    required String beforeRevelation,  
    required String afterRevelation,  
    required IconData icon,  
    required Color color,  
  }) {  
    return Card(  
      margin: const EdgeInsets.only(bottom: 16),  
      color: Colors.white.withOpacity(0.05),  
      shape: RoundedRectangleBorder(  
        borderRadius: BorderRadius.circular(16),  
        side: BorderSide(color: color.withOpacity(0.3)),  
      ),  
      child: Padding(  
        padding: const EdgeInsets.all(16),  
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.start,  
          children: [  
            Row(  
              children: [  
                Container(  
                  padding: const EdgeInsets.all(8),  
                  decoration: BoxDecoration(  
                    color: color.withOpacity(0.2),  
                    shape: BoxShape.circle,  
                  ),  
                  child: Icon(icon, color: color, size: 24),  
                ),  
                const SizedBox(width: 12),  
                Expanded(  
                  child: Text(  
                    title,  
                    style: const TextStyle(  
                      color: Colors.white,  
                      fontSize: 18,  
                      fontWeight: FontWeight.bold,  
                    ),  
                  ),  
                ),  
              ],  
            ),  
            const SizedBox(height: 16),  
            _buildRevelationSection('قبل النزول', beforeRevelation, Colors.redAccent),  
            const SizedBox(height: 12),  
            _buildRevelationSection('بعد النزول', afterRevelation, Colors.greenAccent),  
          ],  
        ),  
      ),  
    );  
  }  
  
  Widget _buildRevelationSection(String title, String content, Color color) {  
    return Container(  
      padding: const EdgeInsets.all(12),  
      decoration: BoxDecoration(  
        color: color.withOpacity(0.1),  
        borderRadius: BorderRadius.circular(12),  
        border: Border.all(color: color.withOpacity(0.3)),  
      ),  
      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,  
        children: [  
          Text(  
            title,  
            style: TextStyle(  
              color: color,  
              fontSize: 14,  
              fontWeight: FontWeight.bold,  
            ),  
          ),  
          const SizedBox(height: 8),  
          Text(  
            content,  
            style: const TextStyle(  
              color: Colors.white70,  
              fontSize: 14,  
              height: 1.6,  
            ),  
            textDirection: TextDirection.rtl,  
          ),  
        ],  
      ),  
    );  
  }  
  
  Widget _buildInspirationTab() {  
    return SingleChildScrollView(  
      padding: const EdgeInsets.all(16),  
      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,  
        children: [  
          Row(  
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  
            children: [  
              const Text(  
                'إلهام ذكاء اصطناعي',  
                style: TextStyle(  
                  color: Colors.white,  
                  fontSize: 20,  
                  fontWeight: FontWeight.bold,  
                ),  
              ),  
              Switch(  
                value: _autoInspirationEnabled,  
                onChanged: (value) {  
                  setState(() {  
                    _autoInspirationEnabled = value;  
                  });  
                },  
                activeColor: Colors.amber,  
              ),  
            ],  
          ),  
          const SizedBox(height: 16),  
          TextField(  
            controller: _inspirationController,  
            maxLines: 3,  
            decoration: InputDecoration(  
              hintText: 'اكتب موضوعاً للحصول على إلهام...',  
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),  
              filled: true,  
              fillColor: Colors.white.withOpacity(0.1),  
              border: OutlineInputBorder(  
                borderRadius: BorderRadius.circular(12),  
                borderSide: BorderSide.none,  
              ),  
            ),  
            style: const TextStyle(color: Colors.white),  
          ),  
          const SizedBox(height: 16),  
          SizedBox(  
            width: double.infinity,  
            child: ElevatedButton(  
              onPressed: _isGenerating  
                  ? null  
                  : () async {  
                      setState(() {  
                        _isGenerating = true;  
                      });  
                      final aiService = Provider.of<AIService>(context, listen: false);  
                        _inspirationController.text,  
                      );  
                      setState(() {  
                        _inspirationResult = result;  
                        _isGenerating = false;  
                      });  
                    },  
              style: ElevatedButton.styleFrom(  
                backgroundColor: Colors.amber,  
                foregroundColor: Colors.black,  
                padding: const EdgeInsets.symmetric(vertical: 16),  
                shape: RoundedRectangleBorder(  
                  borderRadius: BorderRadius.circular(12),  
                ),  
              ),  
              child: _isGenerating  
                  ? const CircularProgressIndicator(color: Colors.black)  
                  : const Text(  
                      'توليد إلهام',  
                      style: TextStyle(  
                        fontSize: 16,  
                        fontWeight: FontWeight.bold,  
                      ),  
                    ),  
            ),  
          ),  
          const SizedBox(height: 24),  
          if (_inspirationResult.isNotEmpty)  
            Container(  
              padding: const EdgeInsets.all(16),  
              decoration: BoxDecoration(  
                color: Colors.white.withOpacity(0.1),  
                borderRadius: BorderRadius.circular(12),  
                border: Border.all(color: Colors.amber.withOpacity(0.3)),  
              ),  
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [  
                  const Text(  
                    'الإلهام المولد:',  
                    style: TextStyle(  
                      color: Colors.amber,  
                      fontSize: 16,  
                      fontWeight: FontWeight.bold,  
                    ),  
                  ),  
                  const SizedBox(height: 12),  
                  Text(  
                    _inspirationResult,  
                    style: const TextStyle(  
                      color: Colors.white,  
                      fontSize: 14,  
                      height: 1.6,  
                    ),  
                    textDirection: TextDirection.rtl,  
                  ),  
                ],  
              ),  
            ),  
        ],  
      ),  
    );  
  }  
  
  Widget _buildContentCard({  
    required String title,  
    required String content,  
    required String subtitle,  
    required IconData icon,  
    required Color color,  
    bool showVideoBtn = false,  
    bool showListenBtn = false,  
    bool isHadith = false,  
    VoidCallback? onTap,  
  }) {  
    return Card(  
      margin: const EdgeInsets.only(bottom: 16),  
      color: Colors.white.withOpacity(0.05),  
      shape: RoundedRectangleBorder(  
        borderRadius: BorderRadius.circular(16),  
        side: BorderSide(color: color.withOpacity(0.3)),  
      ),  
      child: InkWell(  
        onTap: onTap,  
        borderRadius: BorderRadius.circular(16),  
        child: Padding(  
          padding: const EdgeInsets.all(16),  
          child: Column(  
            crossAxisAlignment: CrossAxisAlignment.start,  
            children: [  
              Row(  
                children: [  
                  Container(  
                    padding: const EdgeInsets.all(8),  
                    decoration: BoxDecoration(  
                      color: color.withOpacity(0.2),  
                      shape: BoxShape.circle,  
                    ),  
                    child: Icon(icon, color: color, size: 24),  
                  ),  
                  const SizedBox(width: 12),  
                  Expanded(  
                    child: Text(  
                      title,  
                      style: const TextStyle(  
                        color: Colors.white,  
                        fontSize: 18,  
                        fontWeight: FontWeight.bold,  
                      ),  
                    ),  
                  ),  
                ],  
              ),  
              const SizedBox(height: 12),  
              Text(  
                content,  
                style: const TextStyle(  
                  color: Colors.white70,  
                  fontSize: 14,  
                  height: 1.6,  
                ),  
                maxLines: 3,  
                overflow: TextOverflow.ellipsis,  
                textDirection: TextDirection.rtl,  
              ),  
              const SizedBox(height: 8),  
              Text(  
                subtitle,  
                style: TextStyle(  
                  color: color.withOpacity(0.7),  
                  fontSize: 12,  
                ),  
                maxLines: 2,  
                overflow: TextOverflow.ellipsis,  
              ),  
              if (showVideoBtn || showListenBtn)  
                Padding(  
                  padding: const EdgeInsets.only(top: 12),  
                  child: Row(  
                    children: [  
                      if (showListenBtn)  
                        _buildMiniActionBtn(  
                          icon: Icons.volume_up,  
                          color: Colors.blueAccent,  
                          onTap: () => Provider.of<TTSService>(context, listen: false).speak(content),  
                        ),  
                      if (showVideoBtn)  
                        _buildMiniActionBtn(  
                          icon: Icons.video_library,  
                          color: Colors.redAccent,  
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(  
                            const SnackBar(content: Text('سيتم توليد فيديو ذكاء اصطناعي مذهل مدته 10-15 دقيقة (نسخة برو)')),  
                          ),  
                        ),  
                    ],  
                  ),  
                ),  
            ],  
          ),  
        ),  
      ),  
    );  
  }  
  
  Widget _buildMiniActionBtn({  
    required IconData icon,  
    required Color color,  
    required VoidCallback onTap,  
  }) {  
    return InkWell(  
      onTap: onTap,  
      child: Container(  
        padding: const EdgeInsets.all(8),  
        decoration: BoxDecoration(  
          color: color.withOpacity(0.1),  
          shape: BoxShape.circle,  
          border: Border.all(color: color.withOpacity(0.5)),  
        ),  
        child: Icon(icon, color: color, size: 20),  
      ),  
    );  
  }  
}  

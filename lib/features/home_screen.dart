import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/shared_widgets.dart';
import '../services/floating_bubble_service.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleBubble() async {
    final service = Provider.of<FloatingBubbleService>(context, listen: false);
    if (service.isStarted) {
      await service.stopBubble();
    } else {
      await service.startBubble(context);
    }
  }

  void _showAIInspiration() async {
    final inspiration = await AIService.generateInspiration(
      userMood: '', 
      context: 'Home Screen visit',
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلهام ميرور سكربيون ✨', style: TextStyle(color: Colors.amber)),
        backgroundColor: const Color(0xFF1B2838),
        content: Text(inspiration, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('شكراً', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleService = Provider.of<FloatingBubbleService>(context);
    final isBubbleActive = bubbleService.isStarted;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header Section ──
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/scorpion_bg.jpeg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Animated scorpion image logo
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/images/scorpion_icon.jpeg'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ميرور سكربيون',
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.5,
                        color: Color(0xFF00B0FF),
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ترجمة بنّاءة • بناءً مستمر',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 15),
                    // AI Inspiration Button
                    GestureDetector(
                      onTap: _showAIInspiration,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'احصل على إلهام اليوم',
                              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Floating Bubble Toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isBubbleActive ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: isBubbleActive ? Colors.blue : Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isBubbleActive ? Icons.bubble_chart : Icons.bubble_chart_outlined,
                            color: isBubbleActive ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBubbleActive ? 'الفقاعة نشطة' : 'تفعيل الفقاعة العائمة',
                            style: TextStyle(
                              color: isBubbleActive ? Colors.blue : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: isBubbleActive,
                            onChanged: (_) => _toggleBubble(),
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    WatermarkText(text: "Mirror Scription"),
                  ],
                ),
              ),
            ),

            // ── 6 Cards Grid ──
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _buildCard(
                    icon: Icons.translate,
                    title: 'ترجمة نصوص',
                    subtitle: 'ترجمة فورية بين 100 لغة',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => Navigator.pushNamed(context, '/translate'),
                  ),
                  _buildCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'حوار مترجم',
                    subtitle: 'محادثة ثنائية مع ترجمة فورية',
                    color: Theme.of(context).colorScheme.tertiary,
                    onTap: () => Navigator.pushNamed(context, '/dialogue'),
                  ),
                  _buildCard(
                    icon: Icons.document_scanner,
                    title: 'مستندات وكاميرا',
                    subtitle: 'OCR + ترجمة من الصور والمستندات',
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, '/document'),
                  ),
                  _buildCard(
                    icon: Icons.auto_stories,
                    title: 'أحاديث وقصص',
                    subtitle: 'مكتبة إسلامية مع ترجمة ذكية',
                    color: Colors.deepOrange,
                    onTap: () => Navigator.pushNamed(context, '/stories'),
                  ),
                  _buildCard(
                    icon: Icons.sports_esports,
                    title: 'ألعاب',
                    subtitle: 'شطرنج ثلاثي الأبعاد + مكعب روبيك',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _buildCard(
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    subtitle: 'تحكم كامل بالتطبيق',
                    color: Colors.blueGrey,
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
            ),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

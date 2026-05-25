import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/hadith_stories/hadith_stories_screen.dart';
import 'features/games/rubik_cube/rubik_cube_screen.dart';
import 'features/games/chess/chess_screen.dart';
import 'features/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MirrorScriptionApp());
}

class MirrorScriptionApp extends StatelessWidget {
  const MirrorScriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()..initialize()),
        ChangeNotifierProvider(create: (_) => TTSService()),
      ],
      child: MaterialApp(
        title: 'Mirror Scription',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

// ── Custom Painter: Scorpion + Mirror ──
class _ScorpionMirrorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Mirror frame (circle)
    canvas.drawCircle(center, radius, paint);

    // Mirror handle
    final handlePaint = Paint()
      ..color = const Color(0xFF1A237E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx, center.dy + radius),
      Offset(center.dx, center.dy + radius + 20),
      handlePaint,
    );

    // Scorpion silhouette inside mirror
    final scorpionPaint = Paint()
      ..color = const Color(0xFF1A237E).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Body (oval)
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 22, height: 14),
      scorpionPaint,
    );

    // Tail (curved line)
    final tailPaint = Paint()
      ..color = const Color(0xFF1A237E).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final tailPath = Path()
      ..moveTo(center.dx + 11, center.dy)
      ..quadraticBezierTo(center.dx + 18, center.dy - 12, center.dx + 8, center.dy - 18)
      ..quadraticBezierTo(center.dx + 2, center.dy - 22, center.dx - 2, center.dy - 16);
    canvas.drawPath(tailPath, tailPaint);

    // Stinger dot
    canvas.drawCircle(Offset(center.dx - 2, center.dy - 16), 2.5, scorpionPaint);

    // Claws
    final clawPath = Path()
      ..moveTo(center.dx - 11, center.dy - 2)
      ..quadraticBezierTo(center.dx - 18, center.dy - 8, center.dx - 22, center.dy - 4)
      ..moveTo(center.dx - 11, center.dy + 2)
      ..quadraticBezierTo(center.dx - 18, center.dy + 8, center.dx - 22, center.dy + 4);
    canvas.drawPath(clawPath, tailPaint);

    // Legs
    for (int i = 0; i < 4; i++) {
      final yOffset = -4 + (i * 3);
      canvas.drawLine(
        Offset(center.dx - 8, center.dy + yOffset),
        Offset(center.dx - 16, center.dy + yOffset + 4),
        tailPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 8, center.dy + yOffset),
        Offset(center.dx + 16, center.dy + yOffset + 4),
        tailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

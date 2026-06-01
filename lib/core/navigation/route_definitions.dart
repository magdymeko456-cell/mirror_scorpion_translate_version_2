import 'package:flutter/material.dart';

class TranslationNavigator {
  static void registerRoutes(RouteSettings settings) {
    // يتم تسجيل المسارات الجديدة هنا
  }
}

// إضافة المسارات الجديدة إلى main.dart routes
final Map<String, WidgetBuilder> translationRoutes = {
  '/translate': (context) => const TranslateScreen(),
  '/dialogue': (context) => const DialogueScreen(),
  '/document': (context) => const DocumentScreen(),
  '/stories': (context) => const StoriesScreen(),
  '/rubik': (context) => const RubikScreen(),
  '/chess': (context) => const ChessScreen(),
};

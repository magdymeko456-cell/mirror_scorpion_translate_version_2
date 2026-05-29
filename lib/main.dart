import 'package:flutter/material.dart';  
import 'package:flutter_localizations/flutter_localizations.dart';  
import 'package:provider/provider.dart';  
import 'services/language_service.dart';  
import 'services/background_service.dart';  
import 'services/language_download_service.dart';  
import 'services/premium_verification_service.dart';  
import 'services/tts_service.dart';  
import 'services/floating_bubble_service.dart';  
import 'services/ai_service.dart';  
import 'features/home_screen.dart';  
import 'features/settings/settings_screen.dart';  
import 'features/about/about_app_screen.dart';  
import 'features/admin/key_generator_screen.dart';  
  
void main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
    
  // تهيئة الخدمات  
  await LanguageService().initialize();  
  await BackgroundService().initialize();  
  await LanguageDownloadService().initialize();  
  await PremiumVerificationService().initialize();  
    
  runApp(const MirrorScorpionApp());  
}  
  
class MirrorScorpionApp extends StatelessWidget {  
  const MirrorScorpionApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    return MultiProvider(  
      providers: [  
        ChangeNotifierProvider(create: (_) => LanguageService()),  
        ChangeNotifierProvider(create: (_) => BackgroundService()),  
        ChangeNotifierProvider(create: (_) => LanguageDownloadService()),  
        ChangeNotifierProvider(create: (_) => PremiumVerificationService()),  
        ChangeNotifierProvider(create: (_) => TTSService()),  
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()),  
        ChangeNotifierProvider(create: (_) => AIService()),  
      ],  
      child: MaterialApp(  
        title: 'Mirror Scorpion Translate',  
        debugShowCheckedModeBanner: false,  
        theme: ThemeData(  
          primarySwatch: Colors.deepPurple,  
          useMaterial3: true,  
        ),  
        localizationsDelegates: const [  
          GlobalMaterialLocalizations.delegate,  
          GlobalWidgetsLocalizations.delegate,  
          GlobalCupertinoLocalizations.delegate,  
        ],  
        supportedLocales: const [  
          Locale('ar'),  
          Locale('en'),  
        ],  
        locale: const Locale('ar'),  
        initialRoute: '/',  
        routes: {  
          '/': (context) => const HomeScreen(),  
          '/settings': (context) => const SettingsScreen(),  
          '/about': (context) => const AboutAppScreen(),  
          '/admin_gen': (context) => const KeyGeneratorScreen(),  
        },  
      ),  
    );  
  }  
}  

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/recognition_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation for the intended layout.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make the status bar transparent so the background bleeds through.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => RecognitionProvider(),
      child: const TrackSnapApp(),
    ),
  );
}

class TrackSnapApp extends StatelessWidget {
  const TrackSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackSnap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

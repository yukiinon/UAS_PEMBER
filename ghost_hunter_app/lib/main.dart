import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi notifikasi
  await NotificationService.initialize();
  
  // Set orientasi yang diinginkan
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Set status bar menjadi transparan dan gelap
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(GhostHunterApp());
}

class GhostHunterApp extends StatelessWidget {
  const GhostHunterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemburu Hantu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Hitam pekat
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A0000), // Merah gelap
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1A1A1A), // Abu gelap
          elevation: 8,
          shadowColor: Colors.red.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.red.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B0000), // Dark red
            foregroundColor: Colors.white,
            elevation: 5,
            shadowColor: Colors.red.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Creepster'),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                color: Colors.red,
                offset: Offset(0, 0),
                blurRadius: 10,
              ),
            ],
          ),
          titleMedium: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.red,
                offset: Offset(0, 0),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.red,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.orange,
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF0A0A0A),
          error: Colors.red,
        ),
      ),
      home: HomeScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
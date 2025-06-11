import 'package:datting/controllers/initializer.dart';
import 'package:flutter/material.dart';
import 'views/dating/page_dating_home.dart';
import 'services/notification_service.dart'; // <-- Import service notifikasi

// Definisikan warna utama
const int primaryColorHex = 0xFF5c5c54;
const MaterialColor primarySwatch = MaterialColor(
  primaryColorHex,
  <int, Color>{
    50: Color(0xFFe0e0e0), // 10%
    100: Color(0xFFb3b3b3), // 20%
    200: Color(0xFF808080), // 30%
    300: Color(0xFF4d4d4d), // 40%
    400: Color(0xFF262626), // 50%
    500: Color(primaryColorHex), // 60%
    600: Color(0xFF1f1f1f), // 70%
    700: Color(0xFF1a1a1a), // 80%
    800: Color(0xFF141414), // 90%
    900: Color(0xFF0d0d0d), // 100%
  },
);

void main() async {
  // <-- Ubah menjadi async
  // Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi service notifikasi
  await NotificationService.init();

  runApp(const EconomeDatingApp());
}

class EconomeDatingApp extends StatelessWidget {
  const EconomeDatingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: primarySwatch,
        primaryColor: const Color(primaryColorHex),
        scaffoldBackgroundColor: const Color(0xFF424242),
        splashColor: Colors.white,
        highlightColor: Colors.white,
        brightness: Brightness.dark,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(primaryColorHex),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFa7a597),
          elevation: 4,
          margin: EdgeInsets.all(8),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Initializer(),
    );
  }
}

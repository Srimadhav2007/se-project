import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:happiness_hub/services/ai_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:happiness_hub/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the MaterialApp with a ChangeNotifierProvider.
    // This makes the AIService available to all widgets below it in the tree.
    return ChangeNotifierProvider(
      create: (context) => AIService(),
      child: MaterialApp(
        title: 'Wellness Hub',
        debugShowCheckedModeBanner: false,
        theme: _buildThemeData(),
        home: const AuthGate(),
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primaryColor: const Color(0xFF2E8B57),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xFF2E8B57),
        secondary: const Color(0xFF3CB371),
        background: const Color(0xFFFFFFFF),
        surface: const Color(0xFFF0FFF0),
        onPrimary: Colors.white,
        onSecondary: const Color(0xFF333333),
        onBackground: const Color(0xFF333333),
        onSurface: const Color(0xFF333333),
        error: const Color(0xFFD32F2F),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333)),
        titleLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333)),
        bodyMedium: TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
        labelLarge: TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF2E8B57),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFFF0FFF0),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      cardTheme: CardThemeData(
        elevation: 1.0,
        color: const Color(0xFFF0FFF0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF3CB371),
        foregroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Color(0xFF333333)),
        titleTextStyle: TextStyle(
          color: Color(0xFF333333),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E8B57),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            )),
      ),
    );
  }
}


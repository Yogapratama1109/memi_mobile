import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter sudah diinisialisasi
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('X-USER-MEMO');

  runApp(MyApp(initialScreen: userId != null ? HomeScreen() : LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}

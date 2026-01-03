import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://utfhzcnaxzpachrtrbdn.supabase.co',
    anonKey: 'sb_publishable_CCC_uHQtJxnFI6zWtafzSQ_-mEjxaNg',
  );
  runApp(const ScalpTamizhanApp());
}

class ScalpTamizhanApp extends StatelessWidget {
  const ScalpTamizhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scalp.Tamizhan - Build Real Trading Skill',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: const Color(0xFFF0F0F0),
            displayColor: const Color(0xFFF0F0F0),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

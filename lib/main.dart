import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'pages/settings.dart';
import 'pages/medicalrecord.dart';
import 'pages/qr.dart';
import 'pages/medicaldocs.dart';
import 'pages/login_page.dart';
import 'pages/profile.dart';
import 'pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical App',
      theme: ThemeData(
        primaryColor: const Color(0xFF4F46E5),
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/medical_record': (context) => const MedicalRecordScreen(),
        '/qr_code': (context) => const QRScreen(data: "{}"),
        '/documents': (context) => const MedicalDocumentsApp(),
        '/profile': (context) => const MyProfileScreen(),
        '/signup': (context) => const CreateAccountModernScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/req_blood_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/find_donor_screen.dart';
// import 'screens/request_blood_screen.dart';
// import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  runApp(const LifeLinkApp());
}

class LifeLinkApp extends StatelessWidget {
  const LifeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLink',
      theme: ThemeData(
        primaryColor: const Color(0xFFE53935), // Red for blood app
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE53935),
        ),
      ),
      debugShowCheckedModeBanner: false,

      // 🏁 Starting screen
      home: const SplashScreen(),

      // 🧭 Routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/find-donor': (context) => const FindDonorScreen(),
        '/Splash': (context) => const SplashScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profil': (context) => const EditProfileScreen(),
        '/req-blood': (context) {
  final donorData =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  return RequestBloodScreen(donorData: donorData);
},

        // '/request-blood': (context) => const RequestBloodScreen(), // uncomment if you have it
        // '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

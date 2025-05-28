import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibeme/screens/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vibeme/screens/splash.dart';
import 'package:vibeme/screens/tabs.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Me',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 13, 207, 145),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: const Color.fromARGB(255, 189, 204, 199),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          if (snapshot.hasData) {
            return Tabs();
          }
          return AuthScreen();
        },
      ),
    );
  }
}

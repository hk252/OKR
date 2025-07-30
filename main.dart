import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/QuarterScreen.dart';
import 'package:project/firebase_options.dart';
import 'package:project/login.dart';
import 'package:project/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/test.dart';

import 'Forgotpassword.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent duplicate Firebase initialization
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("✅ Firebase Initialized Successfully!");
    } catch (e) {
      print("🔥 Firebase Init Error: $e");
    }
  } else {
    print("⚠️ Firebase already initialized.");
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('🚪 User is signed out!');
      } else {
        print('🔓 User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/', // Make sure you have this!
          routes: {
            '/': (context) => Splash(),
            '/login': (context) => Login(),
            '/ForgotPassword': (context) => ForgotPassword(),
            '/QuarterScreen': (context) => QuartersScreen(),

          },
        );
      },
    );
  }
}

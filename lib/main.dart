import 'package:balanceballers/Register.dart';
import 'package:balanceballers/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:balanceballers/Start.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAyVr2EH0_kaJIs5p_M0iQZsly-q_YK1Y8",
            authDomain: "balance-baller.firebaseapp.com",
            projectId: "balance-baller",
            storageBucket: "balance-baller.appspot.com",
            messagingSenderId: "519364797751",
            appId: "1:519364797751:web:f95f5d61be547da56566b2"));
  } else {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isLightTheme = true;

  void toggleTheme() {
    setState(() {
      _isLightTheme = !_isLightTheme!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isLightTheme! ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: 'start',
      routes: {
        'start': (context) => Start(toggleTheme: toggleTheme),
        'Register': (context) => const Register(),
      },
    );
  }
}

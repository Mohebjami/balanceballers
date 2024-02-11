import 'package:balanceballers/Register.dart';
import 'package:balanceballers/Start.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: 'start',
        routes: {
          'start': (context) => const Start(),
          'Register': (context) => const Register(),
        },
      ));
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:we_chat/screens/splash_screen.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(home: SplashScreen()));
}

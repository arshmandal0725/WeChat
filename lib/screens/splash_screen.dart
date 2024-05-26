import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_chat/screens/homescreen.dart';
import 'package:we_chat/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

final FirebaseAuth firebaseauth = FirebaseAuth.instance;

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if (firebaseauth.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: height * 0.35,
                width: width * 0.45,
                child: Image.asset(
                  'images/icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: height * 0.4),
              Container(
                  child: Center(
                      child: Text(
                'Made with love by Arsh ❤️',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
              ))),
            ],
          ),
        ),
      ),
    );
  }
}

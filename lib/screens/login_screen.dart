import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/screens/homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

bool _islogin = false;

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    Future<void> signInWithGoogle(BuildContext context) async {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;

          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);
          if (await API().userExists()) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (ctx) => HomeScreen()),
            );
            _islogin = false;
          } else {
            await API().createUser().then((value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (ctx) => HomeScreen()),
                ));
            _islogin = false;
          }
        } else {
          _islogin = false;
          setState(() {});
          // Handle sign-in failure
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sign-in failed. Please try again.'),
            duration: Duration(seconds: 3),
          ));
        }
      } catch (e) {
        // Handle exceptions
        print('Error signing in with Google: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 3),
        ));
      }
    }

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: (_islogin)
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.3,
                      width: width * 0.5,
                      child: Image.asset(
                        'images/icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: height * 0.4),
                    Container(
                      width: width * 0.85,
                      height: height * 0.060,
                      child: ElevatedButton(
                        onPressed: () {
                          signInWithGoogle(context);
                          _islogin = true;
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 177, 244, 179),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: height * 0.04,
                              child: Image.asset('images/google.png'),
                            ),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

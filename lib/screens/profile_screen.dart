import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/screens/login_screen.dart';
import 'package:we_chat/screens/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.currentUser});
  final ChatUser currentUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final GoogleSignIn _googleSignIn = GoogleSignIn();
final _formkey = GlobalKey<FormState>();
String? _image;

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    void _handleSignOut() async {
      try {
        await firebaseauth.signOut();
        await _googleSignIn.signOut();
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => LoginScreen()));
      } catch (e) {
        print('Error signing out: $e');
      }
    }

    void updateImage() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return Container(
            padding: EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Pick a Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), padding: EdgeInsets.all(20)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.gallery,imageQuality: 70);
                        if (photo != Null) {
                          setState(() {
                            _image = photo!.path;
                            Navigator.pop(context);
                            API().updateProfilePicture(
                                File(_image!), widget.currentUser);
                          });
                        }
                      },
                      child: Icon(
                        Icons.photo,
                        size: 50,
                        color: Color.fromARGB(255, 45, 123, 47),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), padding: EdgeInsets.all(20)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                        if (photo != Null) {
                          setState(() {
                            _image = photo!.path;
                            Navigator.pop(context);
                            API().updateProfilePicture(
                                File(_image!), widget.currentUser);
                          });
                        }
                      },
                      child: Icon(
                        Icons.camera,
                        size: 50,
                        color: Color.fromARGB(255, 45, 123, 47),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Screen'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(150),
                          child: Container(
                            height: 150,
                            width: 150,
                            child: _image == null
                                ? CachedNetworkImage(
                                    imageUrl: widget.currentUser.Image,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_image!),
                                    fit: BoxFit.cover,
                                  ),
                          )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          shape: CircleBorder(),
                          color: Color.fromARGB(255, 207, 250, 229),
                          onPressed: () {
                            updateImage();
                          },
                          child: Icon(Icons.edit),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.currentUser.Email,
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          TextFormField(
                            onSaved: (value) {
                              widget.currentUser.Name = value!;
                            },
                            validator: (value) {
                              if (value != Null && value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'Field Required';
                              }
                            },
                            initialValue: widget.currentUser.Name,
                            decoration: InputDecoration(
                                label: Text('Name'),
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                                hintText: 'eg. Honey Singh'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              widget.currentUser.About = value!;
                            },
                            validator: (value) {
                              if (value != Null && value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'Field Required';
                              }
                            },
                            initialValue: widget.currentUser.About,
                            decoration: InputDecoration(
                                label: Text('About'),
                                prefixIcon: Icon(Icons.error_outline_rounded),
                                border: OutlineInputBorder(),
                                hintText: 'eg. Feeling Happy'),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            height: 50,
                            width: 200,
                            child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 207, 250, 229)),
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    _formkey.currentState!.save();
                                    API().updateUserData(widget.currentUser);
                                  }
                                },
                                label: Text(
                                  'UPDATE',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                )),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 50,
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 207, 250, 229)),
                                    onPressed: () {
                                      _handleSignOut();
                                    },
                                    icon: Icon(
                                      Icons.logout,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.black),
                                    )),
                              )
                            ],
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

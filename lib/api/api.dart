import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message_model.dart';

class API {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage firestorage = FirebaseStorage.instance;

  Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .get())
        .exists;
  }

  Future createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        Id: firebaseAuth.currentUser!.uid,
        Name: firebaseAuth.currentUser!.displayName.toString(),
        Email: firebaseAuth.currentUser!.email.toString(),
        About: "Hey, I'm using We Chat!",
        Image: firebaseAuth.currentUser!.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastLogin: time,
        pushToken: "");
    return await firestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .set(chatUser.toJson());
  }

  Future<void> updateUserData(ChatUser currentUser) async {
    await firestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({'Name': currentUser.Name, 'About': currentUser.About});
  }

  Future<void> updateProfilePicture(File file, ChatUser currentUser) async {
    try {
      // Ensure user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      // Check file size
      final fileLength = await file.length();
      if (fileLength > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception('File size exceeds the 10MB limit.');
      }

      // Extract the file extension from the file path
      final ext = file.path.split('.').last;
      final contentType = 'image/$ext';

      // Create a reference to the location in Firebase Storage where the profile picture will be saved
      final ref = FirebaseStorage.instance
          .ref()
          .child('profilepictures/${currentUser.Email}.$ext');

      // Create a metadata object
      final metadata = SettableMetadata(contentType: contentType);

      // Upload the file to Firebase Storage with appropriate metadata
      final uploadTask = ref.putFile(file, metadata);

      // Monitor the upload task
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        switch (snapshot.state) {
          case TaskState.running:
            print('Upload is running');
            break;
          case TaskState.paused:
            print('Upload is paused');
            break;
          case TaskState.success:
            print('Upload was successful');
            break;
          case TaskState.canceled:
            print('Upload was canceled');
            break;
          case TaskState.error:
            print('Upload encountered an error');
            break;
        }
      });

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Retrieve the download URL of the uploaded profile picture
        final downloadURL = await ref.getDownloadURL();

        // Update the current user's image URL
        currentUser.Image = downloadURL;

        // Update the Firestore document for the current user with the new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'Image': currentUser.Image});

        print('Profile picture updated successfully.');
      } else {
        throw Exception('Upload task failed with state: ${snapshot.state}');
      }
    } catch (e) {
      print('Failed to update profile picture: $e');
      if (e is FirebaseException) {
        print('FirebaseException: ${e.code} - ${e.message}');
      }
      throw e;
    }
  }

  String getConversationID(String id) =>
      firebaseAuth.currentUser!.uid.hashCode <= id.hashCode
          ? '${firebaseAuth.currentUser!.uid}_$id'
          : '${id}_${firebaseAuth.currentUser!.uid}';

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.Id)}/messages')
        .snapshots();
  }

  Future<void> sendMessage(ChatUser user, String msj) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    final Message message = Message(
        toId: user.Id,
        type: 'text',
        msg: msj,
        read: '',
        fromId: firebaseAuth.currentUser!.uid,
        sent: time.toString());
    final ref = await firestore
        .collection('chats/${getConversationID(user.Id)}/messages');

    await ref.doc('${time}').set(message.toJson());
  }

  Future<void> updateMessageReadStatus(Message message) async {
    print('${getConversationID(message.fromId)}');
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.Id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserinfo(ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.Id)
        .snapshots();
  }

  Future<void> updateUserInfo(bool _isOnline) async {
    await firestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({
        'is_online': _isOnline,
        'last_login': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }
  
}

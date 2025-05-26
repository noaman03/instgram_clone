import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/service/storage.dart';
import 'package:instgram_clone/util/functions/exeptions.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // login function
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ExeptionMessage('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ExeptionMessage('Wrong password provided for that user.');
      }
    }
  }

  // sign up function
  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String bio,
    required File profile,
  }) async {
    String URL = "";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          name.isNotEmpty &&
          bio.isNotEmpty) {
        if (password == confirmPassword) {
          await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          // save pp in storage
          if (profile != File('')) {
            URL =
                await storagemethod().uploadImageToStorage('profile', profile);
          }

          // create collection in firestore
          await Firestore()
              .createuser(email: email, name: name, bio: bio, profile: URL);
          print("User created successfully.");
        } else {
          ExeptionMessage("Passwords do not match.");
        }
      } else {
        ExeptionMessage("Please fill in all fields.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ExeptionMessage('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ExeptionMessage('The account already exists for that email.');
      }
    } catch (e) {
      ExeptionMessage(e.toString());
    }
  }
}

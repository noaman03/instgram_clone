// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// ignore: camel_case_types
class storagemethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var uid = const Uuid().v4();
  Future<String> uploadImageToStorage(String name, File file) async {
    Reference ref =
        _storage.ref().child(name).child(_auth.currentUser!.uid).child(uid);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }
}

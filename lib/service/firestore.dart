import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instgram_clone/models/message_model.dart';
import 'package:instgram_clone/models/user_model.dart';
import 'package:instgram_clone/util/functions/exeptions.dart';
import 'package:uuid/uuid.dart';

class Firestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createuser({
    required String name,
    required String email,
    required String bio,
    required String profile,
  }) {
    return _firestore.collection('users').doc(_auth.currentUser!.uid).set({
      'email': email,
      'username': name,
      'bio': bio,
      'profile': profile,
      'followers': [],
      'following': [],
    });
  }

  Future<UserModel> getuser({String? uidd}) async {
    try {
      final user = await _firestore
          .collection('users')
          .doc(uidd ?? _auth.currentUser!.uid)
          .get();
      final snapuser = user.data()!;
      return UserModel(
          snapuser['bio'],
          snapuser['email'],
          snapuser['followers'],
          snapuser['following'],
          snapuser['profile'],
          snapuser['username']);
    } on FirebaseAuthException catch (e) {
      throw ExeptionMessage(e.message.toString());
    }
  }

  Future<void> creatpost(
      {required String postimage, required String caption}) async {
    var uid = const Uuid().v4();
    DateTime data = DateTime.now();
    UserModel user = await getuser();
    return _firestore.collection('post').doc(uid).set({
      'postImage': postimage,
      'username': user.name,
      'profileImage': user.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
  }

  Future<void> creatreel(
      {required String video, required String caption}) async {
    var uid = const Uuid().v4();
    DateTime data = DateTime.now();
    UserModel user = await getuser();
    return _firestore.collection('reel').doc(uid).set({
      'reelvideo': video,
      'username': user.name,
      'profileImage': user.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
  }

  Future<void> createStory({
    required String mediaUrl,
  }) async {
    try {
      var storyId = const Uuid().v4();
      DateTime timestamp = DateTime.now();
      UserModel user = await getuser();

      await _firestore.collection('stories').doc(storyId).set({
        'mediaUrl': mediaUrl,
        'username': user.name,
        'profileImage': user.profile,
        'uid': _auth.currentUser!.uid,
        'storyId': storyId,
        'time': timestamp,
      });

      print("Story added successfully!");
    } catch (e) {
      print("Error creating story: $e");
      throw Exception("Failed to create story: $e");
    }
  }

  Future<Map<String, dynamic>> fetchStories() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> currentUserStorySnapshot =
        await FirebaseFirestore.instance
            .collection('stories')
            .doc(userId)
            .get();

    QuerySnapshot<Map<String, dynamic>> otherUsersStoriesSnapshot =
        await FirebaseFirestore.instance.collection('stories').get();

    return {
      'currentUser': currentUserStorySnapshot.exists
          ? currentUserStorySnapshot.data()
          : {'username': 'You', 'profileImage': '', 'stories': []},
      'others': otherUsersStoriesSnapshot.docs
          .where((doc) => doc.id != userId)
          .map((doc) => doc.data())
          .toList(),
    };
  }

  Future<void> comments(
      {required String comment,
      required String type,
      required String uidd}) async {
    var uid = const Uuid().v4();
    UserModel user = await getuser();
    return _firestore
        .collection(type)
        .doc(uidd)
        .collection('comment')
        .doc(uid)
        .set({
      'comment': comment,
      'username': user.name,
      'profileImage': user.profile,
      'commentuid': uid,
    });
  }

  Future<String> like({
    required List like,
    required String type,
    required String uid,
    required String postId,
  }) async {
    String res = 'some error';
    try {
      if (like.contains(uid)) {
        _firestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayRemove([uid])
        });
      } else {
        _firestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayUnion([uid])
        });
      }
      res = 'seccess';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> follow({
    required String uid,
  }) async {
    String res = 'some error';
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    List follow = (snap.data()! as dynamic)['following'];
    try {
      if (follow.contains(uid)) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'following': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([_auth.currentUser!.uid])
        });
      } else {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'following': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([_auth.currentUser!.uid])
        });
      }
      res = 'seccess';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> sendmessage(String receiverid, String message) async {
    Timestamp timestamp = Timestamp.now();
    String currentuserid = _auth.currentUser!.uid;
    MessageModel newmessage = MessageModel(
        message: message,
        receiverid: receiverid,
        senderid: currentuserid,
        timestamp: timestamp);
    List<String> ids = [currentuserid, receiverid];
    ids.sort();
    String chatroomid = ids.join("_");
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomid)
        .collection("message")
        .add(newmessage.tomap());
  }

  Stream<QuerySnapshot> getmessage(String userid, otheruserid) {
    List<String> ids = [userid, otheruserid];
    ids.sort();
    String chatroomid = ids.join("_");
    return _firestore
        .collection("chat_rooms")
        .doc(chatroomid)
        .collection("message")
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}

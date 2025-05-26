import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instgram_clone/models/message_model.dart';
import 'package:instgram_clone/models/user_model.dart';
import 'package:instgram_clone/util/functions/exeptions.dart';
import 'package:uuid/uuid.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  // User Repository methods
  Future<void> createUser({
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

  Future<UserModel> getUser({String? userId}) async {
    try {
      final user = await _firestore
          .collection('users')
          .doc(userId ?? _auth.currentUser!.uid)
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

  // Posts methods
  Future<void> createPost({
    required String postImage,
    required String caption,
  }) async {
    var postId = const Uuid().v4();
    DateTime timestamp = DateTime.now();
    UserModel user = await getUser();

    return _firestore.collection('post').doc(postId).set({
      'postImage': postImage,
      'username': user.name,
      'profileImage': user.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': postId,
      'like': [],
      'time': timestamp
    });
  }

  Stream<QuerySnapshot> getPosts() {
    return _firestore
        .collection('post')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Reels methods
  Future<void> createReel({
    required String video,
    required String caption,
  }) async {
    var reelId = const Uuid().v4();
    DateTime timestamp = DateTime.now();
    UserModel user = await getUser();

    return _firestore.collection('reel').doc(reelId).set({
      'reelvideo': video,
      'username': user.name,
      'profileImage': user.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': reelId,
      'like': [],
      'time': timestamp
    });
  }

  Stream<QuerySnapshot> getReels() {
    return _firestore
        .collection('reel')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Story methods
  Future<void> createStory({
    required String mediaUrl,
  }) async {
    var storyId = const Uuid().v4();
    DateTime timestamp = DateTime.now();
    UserModel user = await getUser();

    return _firestore.collection('stories').doc(storyId).set({
      'mediaUrl': mediaUrl,
      'username': user.name,
      'profileImage': user.profile,
      'uid': _auth.currentUser!.uid,
      'storyId': storyId,
      'time': timestamp,
    });
  }

  Future<Map<String, dynamic>> fetchStories() async {
    String userId = _auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> currentUserStorySnapshot =
        await _firestore.collection('stories').doc(userId).get();

    QuerySnapshot<Map<String, dynamic>> otherUsersStoriesSnapshot =
        await _firestore.collection('stories').get();

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

  // Comment and like methods
  Future<void> addComment({
    required String comment,
    required String type, // 'post' or 'reel'
    required String contentId,
  }) async {
    var commentId = const Uuid().v4();
    UserModel user = await getUser();

    // Get content owner ID
    DocumentSnapshot contentDoc =
        await _firestore.collection(type).doc(contentId).get();
    String contentOwnerId = (contentDoc.data() as Map<String, dynamic>)['uid'];
    String? postImage = type == 'post'
        ? (contentDoc.data() as Map<String, dynamic>)['postImage']
        : null;

    // Add comment
    await _firestore
        .collection(type)
        .doc(contentId)
        .collection('comment')
        .doc(commentId)
        .set({
      'comment': comment,
      'username': user.name,
      'profileImage': user.profile,
      'commentuid': commentId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Create notification for the content owner
    await createNotification(
      receiverId: contentOwnerId,
      type: 'comment',
      postId: contentId,
      postImg: postImage,
      commentText: comment,
    );
  }

  Stream<QuerySnapshot> getComments(String type, String contentId) {
    return _firestore
        .collection(type)
        .doc(contentId)
        .collection('comment')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String> toggleLike({
    required String type, // 'post' or 'reel'
    required String contentId,
  }) async {
    String res = 'some error';
    try {
      DocumentSnapshot doc =
          await _firestore.collection(type).doc(contentId).get();
      List likes = (doc.data() as Map<String, dynamic>)['like'];

      if (likes.contains(currentUserId)) {
        // Remove like
        await _firestore.collection(type).doc(contentId).update({
          'like': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        // Add like and create notification
        await _firestore.collection(type).doc(contentId).update({
          'like': FieldValue.arrayUnion([currentUserId])
        });

        // Get post owner ID to send notification
        String postOwnerId = (doc.data() as Map<String, dynamic>)['uid'];
        String? postImage = type == 'post'
            ? (doc.data() as Map<String, dynamic>)['postImage']
            : null;

        // Create notification for the post owner
        await createNotification(
          receiverId: postOwnerId,
          type: 'like',
          postId: contentId,
          postImg: postImage,
        );
      }
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Follow methods
  Future<String> toggleFollow(String targetUserId) async {
    String res = 'some error';
    try {
      DocumentSnapshot myUserDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      List following = (myUserDoc.data() as Map<String, dynamic>)['following'];

      if (following.contains(targetUserId)) {
        // Unfollow
        await _firestore.collection('users').doc(currentUserId).update({
          'following': FieldValue.arrayRemove([targetUserId])
        });
        await _firestore.collection('users').doc(targetUserId).update({
          'followers': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        // Follow and create notification
        await _firestore.collection('users').doc(currentUserId).update({
          'following': FieldValue.arrayUnion([targetUserId])
        });
        await _firestore.collection('users').doc(targetUserId).update({
          'followers': FieldValue.arrayUnion([currentUserId])
        });

        // Create notification
        await createNotification(
          receiverId: targetUserId,
          type: 'follow',
        );
      }
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Chat methods - for reference, already implemented in ChatBloc
  Future<void> sendMessage(String receiverId, String message) async {
    Timestamp timestamp = Timestamp.now();
    MessageModel newMessage = MessageModel(
        message: message,
        receiverid: receiverId,
        senderid: currentUserId,
        timestamp: timestamp);

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .add(newMessage.tomap());
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Notification methods
  Future<void> createNotification({
    required String receiverId,
    required String type,
    String? postId,
    String? postImg,
    String? commentText,
  }) async {
    try {
      // Don't notify yourself
      if (receiverId == currentUserId) return;

      final String notificationId = const Uuid().v4();

      // Get sender data
      final userData = await getUser();

      final notificationData = {
        'id': notificationId,
        'senderId': currentUserId,
        'receiverId': receiverId,
        'senderUsername': userData.name,
        'senderProfileImg': userData.profile,
        'type': type,
        'postId': postId,
        'postImg': postImg,
        'commentText': commentText,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notificationData);
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  Stream<QuerySnapshot> getNotifications() {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead() async {
    final notifications = await _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Stream<int> getUnreadNotificationCount() {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

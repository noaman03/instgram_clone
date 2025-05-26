import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderUsername;
  final String senderProfileImg;
  final String type; // 'like', 'comment', 'follow'
  final String? postId;
  final String? postImg;
  final String? commentText;
  final Timestamp timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderUsername,
    required this.senderProfileImg,
    required this.type,
    this.postId,
    this.postImg,
    this.commentText,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderUsername': senderUsername,
      'senderProfileImg': senderProfileImg,
      'type': type,
      'postId': postId,
      'postImg': postImg,
      'commentText': commentText,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  static NotificationModel fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      senderUsername: map['senderUsername'],
      senderProfileImg: map['senderProfileImg'],
      type: map['type'],
      postId: map['postId'],
      postImg: map['postImg'],
      commentText: map['commentText'],
      timestamp: map['timestamp'],
      isRead: map['isRead'],
    );
  }
}

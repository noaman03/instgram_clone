import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String senderid;
  String receiverid;
  String message;
  Timestamp timestamp;

  MessageModel(
      {required this.message,
      required this.receiverid,
      required this.senderid,
      required this.timestamp});
  Map<String, dynamic> tomap() {
    return {
      'sender id': senderid,
      'receiver id': receiverid,
      'message': message,
      'timestamp': timestamp,
    };
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/chat/chat_event.dart';
import 'package:instgram_clone/blocs/chat/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<SearchUsers>(_onSearchUsers);
    on<SendMessage>(_onSendMessage);
    on<LoadMessages>(_onLoadMessages);
  }

  String get currentUserId => _auth.currentUser!.uid;

  void _onLoadChats(LoadChats event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    try {
      final stream = _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserId)
          .snapshots();
      emit(ChatRoomsLoaded(stream));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    try {
      final stream = _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: event.query)
          .where('username', isLessThan: event.query + 'z')
          .snapshots();
      emit(UsersLoaded(stream));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    try {
      String chatRoomId = getChatRoomId(currentUserId, event.receiverId);
      final stream = _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
      emit(MessagesLoaded(stream));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      if (event.message.trim().isEmpty) return;

      final timestamp = Timestamp.now();
      String chatRoomId = getChatRoomId(currentUserId, event.receiverId);

      // Get receiver data to display in chat list
      DocumentSnapshot receiverData =
          await _firestore.collection('users').doc(event.receiverId).get();

      DocumentSnapshot senderData =
          await _firestore.collection('users').doc(currentUserId).get();

      // Create chat room if it doesn't exist or update its last message
      await _firestore.collection('chat_rooms').doc(chatRoomId).set({
        'lastMessage': event.message,
        'lastMessageTime': timestamp,
        'participants': [currentUserId, event.receiverId],
        'unreadCount': FieldValue.increment(1),
        // Store information about both participants for easy access
        'users': {
          currentUserId: {
            'username': senderData['username'],
            'profile': senderData['profile'],
          },
          event.receiverId: {
            'username': receiverData['username'],
            'profile': receiverData['profile'],
          }
        }
      }, SetOptions(merge: true));

      // Add message to chat room
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': event.message,
        'senderId': currentUserId,
        'timestamp': timestamp,
      });

      emit(MessageSent());
      add(LoadMessages(event.receiverId)); // Reload messages
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Create a consistent chat room ID regardless of who started the chat
  String getChatRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }
}

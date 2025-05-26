import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final Stream<QuerySnapshot> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object> get props => [chatRooms];
}

class MessagesLoaded extends ChatState {
  final Stream<QuerySnapshot> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class UsersLoaded extends ChatState {
  final Stream<QuerySnapshot> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSent extends ChatState {}

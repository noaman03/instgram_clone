import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadChats extends ChatEvent {}

class SearchUsers extends ChatEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  final String message;

  const SendMessage({required this.receiverId, required this.message});

  @override
  List<Object> get props => [receiverId, message];
}

class LoadMessages extends ChatEvent {
  final String receiverId;

  const LoadMessages(this.receiverId);

  @override
  List<Object> get props => [receiverId];
}

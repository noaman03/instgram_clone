import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final Stream<QuerySnapshot> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationMarkedAsRead extends NotificationState {}

class AllNotificationsMarkedAsRead extends NotificationState {}

class UnreadCountLoaded extends NotificationState {
  final Stream<int> unreadCount;

  const UnreadCountLoaded(this.unreadCount);

  @override
  List<Object> get props => [unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}

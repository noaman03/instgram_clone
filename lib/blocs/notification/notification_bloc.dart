import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_event.dart';
import 'package:instgram_clone/blocs/notification/notification_state.dart';
import 'package:instgram_clone/service/firestore_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirestoreRepository _repository = FirestoreRepository();

  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<GetUnreadCount>(_onGetUnreadCount);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationLoading());
    try {
      final notificationsStream = _repository.getNotifications();
      emit(NotificationsLoaded(notificationsStream));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      await _repository.markNotificationAsRead(event.notificationId);
      emit(NotificationMarkedAsRead());
      add(LoadNotifications()); // Reload notifications
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      await _repository.markAllNotificationsAsRead();
      emit(AllNotificationsMarkedAsRead());
      add(LoadNotifications()); // Reload notifications
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _onGetUnreadCount(
    GetUnreadCount event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationLoading());
    try {
      final unreadCount = _repository.getUnreadNotificationCount();
      emit(UnreadCountLoaded(unreadCount));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}

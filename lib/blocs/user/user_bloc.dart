import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/user/user_event.dart';
import 'package:instgram_clone/blocs/user/user_state.dart';
import 'package:instgram_clone/service/firestore_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirestoreRepository _repository = FirestoreRepository();

  UserBloc() : super(UserInitial()) {
    on<CreateUser>(_onCreateUser);
    on<GetUser>(_onGetUser);
    on<FollowUser>(_onFollowUser);
  }

  Future<void> _onCreateUser(
    CreateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await _repository.createUser(
        name: event.name,
        email: event.email,
        bio: event.bio,
        profile: event.profile,
      );
      emit(UserCreated());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onGetUser(
    GetUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await _repository.getUser(userId: event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final result = await _repository.toggleFollow(event.userId);
      emit(UserFollowed(result));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

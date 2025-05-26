import 'package:equatable/equatable.dart';
import 'package:instgram_clone/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserCreated extends UserState {}

class UserFollowed extends UserState {
  final String result;

  const UserFollowed(this.result);

  @override
  List<Object> get props => [result];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

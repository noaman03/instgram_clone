import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class CreateUser extends UserEvent {
  final String name;
  final String email;
  final String bio;
  final String profile;

  const CreateUser({
    required this.name,
    required this.email,
    required this.bio,
    required this.profile,
  });

  @override
  List<Object> get props => [name, email, bio, profile];
}

class GetUser extends UserEvent {
  final String? userId;

  const GetUser({this.userId});

  @override
  List<Object> get props => userId != null ? [userId!] : [];
}

class FollowUser extends UserEvent {
  final String userId;

  const FollowUser(this.userId);

  @override
  List<Object> get props => [userId];
}

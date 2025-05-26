import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class InteractionState extends Equatable {
  const InteractionState();

  @override
  List<Object> get props => [];
}

class InteractionInitial extends InteractionState {}

class InteractionLoading extends InteractionState {}

class CommentAdded extends InteractionState {}

class CommentsLoaded extends InteractionState {
  final Stream<QuerySnapshot> comments;

  const CommentsLoaded(this.comments);

  @override
  List<Object> get props => [comments];
}

class LikeToggled extends InteractionState {
  final String result;

  const LikeToggled(this.result);

  @override
  List<Object> get props => [result];
}

class InteractionError extends InteractionState {
  final String message;

  const InteractionError(this.message);

  @override
  List<Object> get props => [message];
}

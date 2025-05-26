import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ReelState extends Equatable {
  const ReelState();

  @override
  List<Object> get props => [];
}

class ReelInitial extends ReelState {}

class ReelLoading extends ReelState {}

class ReelCreated extends ReelState {}

class ReelsLoaded extends ReelState {
  final Stream<QuerySnapshot> reels;

  const ReelsLoaded(this.reels);

  @override
  List<Object> get props => [reels];
}

class ReelError extends ReelState {
  final String message;

  const ReelError(this.message);

  @override
  List<Object> get props => [message];
}

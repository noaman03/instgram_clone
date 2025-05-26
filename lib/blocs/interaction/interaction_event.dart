import 'package:equatable/equatable.dart';

abstract class InteractionEvent extends Equatable {
  const InteractionEvent();

  @override
  List<Object> get props => [];
}

class AddComment extends InteractionEvent {
  final String comment;
  final String type;
  final String contentId;

  const AddComment({
    required this.comment,
    required this.type,
    required this.contentId,
  });

  @override
  List<Object> get props => [comment, type, contentId];
}

class LoadComments extends InteractionEvent {
  final String type;
  final String contentId;

  const LoadComments({
    required this.type,
    required this.contentId,
  });

  @override
  List<Object> get props => [type, contentId];
}

class ToggleLike extends InteractionEvent {
  final String type;
  final String contentId;

  const ToggleLike({
    required this.type,
    required this.contentId,
  });

  @override
  List<Object> get props => [type, contentId];
}

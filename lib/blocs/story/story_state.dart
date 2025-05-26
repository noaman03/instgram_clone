import 'package:equatable/equatable.dart';

abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryCreated extends StoryState {}

class StoriesLoaded extends StoryState {
  final Map<String, dynamic> stories;

  const StoriesLoaded(this.stories);

  @override
  List<Object> get props => [stories];
}

class StoryError extends StoryState {
  final String message;

  const StoryError(this.message);

  @override
  List<Object> get props => [message];
}

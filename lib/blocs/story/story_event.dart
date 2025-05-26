import 'package:equatable/equatable.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object> get props => [];
}

class CreateStory extends StoryEvent {
  final String mediaUrl;

  const CreateStory(this.mediaUrl);

  @override
  List<Object> get props => [mediaUrl];
}

class FetchStories extends StoryEvent {}

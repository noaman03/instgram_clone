import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/story/story_event.dart';
import 'package:instgram_clone/blocs/story/story_state.dart';
import 'package:instgram_clone/service/firestore_repository.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final FirestoreRepository _repository = FirestoreRepository();

  StoryBloc() : super(StoryInitial()) {
    on<CreateStory>(_onCreateStory);
    on<FetchStories>(_onFetchStories);
  }

  Future<void> _onCreateStory(
    CreateStory event,
    Emitter<StoryState> emit,
  ) async {
    emit(StoryLoading());
    try {
      await _repository.createStory(mediaUrl: event.mediaUrl);
      emit(StoryCreated());
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onFetchStories(
    FetchStories event,
    Emitter<StoryState> emit,
  ) async {
    emit(StoryLoading());
    try {
      final stories = await _repository.fetchStories();
      emit(StoriesLoaded(stories));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }
}

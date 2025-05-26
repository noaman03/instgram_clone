import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/post/post_event.dart';
import 'package:instgram_clone/blocs/post/post_state.dart';
import 'package:instgram_clone/service/firestore_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirestoreRepository _repository = FirestoreRepository();

  PostBloc() : super(PostInitial()) {
    on<CreatePost>(_onCreatePost);
    on<LoadPosts>(_onLoadPosts);
  }

  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      await _repository.createPost(
        postImage: event.postImage,
        caption: event.caption,
      );
      emit(PostCreated());
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  void _onLoadPosts(
    LoadPosts event,
    Emitter<PostState> emit,
  ) {
    emit(PostLoading());
    try {
      final postsStream = _repository.getPosts();
      emit(PostsLoaded(postsStream));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}

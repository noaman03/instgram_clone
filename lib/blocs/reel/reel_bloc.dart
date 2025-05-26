import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/reel/reel_event.dart';
import 'package:instgram_clone/blocs/reel/reel_state.dart';
import 'package:instgram_clone/service/firestore_repository.dart';

class ReelBloc extends Bloc<ReelEvent, ReelState> {
  final FirestoreRepository _repository = FirestoreRepository();

  ReelBloc() : super(ReelInitial()) {
    on<CreateReel>(_onCreateReel);
    on<LoadReels>(_onLoadReels);
  }

  Future<void> _onCreateReel(
    CreateReel event,
    Emitter<ReelState> emit,
  ) async {
    emit(ReelLoading());
    try {
      await _repository.createReel(
        video: event.video,
        caption: event.caption,
      );
      emit(ReelCreated());
    } catch (e) {
      emit(ReelError(e.toString()));
    }
  }

  void _onLoadReels(
    LoadReels event,
    Emitter<ReelState> emit,
  ) {
    emit(ReelLoading());
    try {
      final reelsStream = _repository.getReels();
      emit(ReelsLoaded(reelsStream));
    } catch (e) {
      emit(ReelError(e.toString()));
    }
  }
}

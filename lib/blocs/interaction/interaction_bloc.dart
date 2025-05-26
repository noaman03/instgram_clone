import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/interaction/interaction_event.dart';
import 'package:instgram_clone/blocs/interaction/interaction_state.dart';
import 'package:instgram_clone/service/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:instgram_clone/blocs/user/user_bloc.dart';
import 'package:instgram_clone/blocs/user/user_event.dart';
import 'package:instgram_clone/blocs/user/user_state.dart';

class InteractionBloc extends Bloc<InteractionEvent, InteractionState> {
  final FirestoreRepository _repository = FirestoreRepository();

  InteractionBloc() : super(InteractionInitial()) {
    on<AddComment>(_onAddComment);
    on<LoadComments>(_onLoadComments);
    on<ToggleLike>(_onToggleLike);
  }

  Future<void> _onAddComment(
    AddComment event,
    Emitter<InteractionState> emit,
  ) async {
    emit(InteractionLoading());
    try {
      await _repository.addComment(
        comment: event.comment,
        type: event.type,
        contentId: event.contentId,
      );
      emit(CommentAdded());
    } catch (e) {
      emit(InteractionError(e.toString()));
    }
  }

  void _onLoadComments(
    LoadComments event,
    Emitter<InteractionState> emit,
  ) {
    emit(InteractionLoading());
    try {
      final commentsStream =
          _repository.getComments(event.type, event.contentId);
      emit(CommentsLoaded(commentsStream));
    } catch (e) {
      emit(InteractionError(e.toString()));
    }
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<InteractionState> emit,
  ) async {
    emit(InteractionLoading());
    try {
      final result = await _repository.toggleLike(
        type: event.type,
        contentId: event.contentId,
      );
      emit(LikeToggled(result));
    } catch (e) {
      emit(InteractionError(e.toString()));
    }
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when screen initializes
    context.read<UserBloc>().add(const GetUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is UserLoaded) {
            final user = state.user;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.profile),
                ),
                const SizedBox(height: 20),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.bio),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatColumn(user.followers.length, 'Followers'),
                    const SizedBox(width: 20),
                    _buildStatColumn(user.following.length, 'Following'),
                  ],
                ),
              ],
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }
}

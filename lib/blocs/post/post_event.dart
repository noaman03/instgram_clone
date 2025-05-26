import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class CreatePost extends PostEvent {
  final String postImage;
  final String caption;

  const CreatePost({
    required this.postImage,
    required this.caption,
  });

  @override
  List<Object> get props => [postImage, caption];
}

class LoadPosts extends PostEvent {}

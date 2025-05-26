import 'package:equatable/equatable.dart';

abstract class ReelEvent extends Equatable {
  const ReelEvent();

  @override
  List<Object> get props => [];
}

class CreateReel extends ReelEvent {
  final String video;
  final String caption;

  const CreateReel({
    required this.video,
    required this.caption,
  });

  @override
  List<Object> get props => [video, caption];
}

class LoadReels extends ReelEvent {}

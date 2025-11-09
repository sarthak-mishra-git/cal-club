import 'package:equatable/equatable.dart';
import '../../models/screens/progress_screen_model.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final ProgressScreenModel progressScreenModel;

  const ProgressLoaded({required this.progressScreenModel});

  @override
  List<Object?> get props => [progressScreenModel];
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError({required this.message});

  @override
  List<Object?> get props => [message];
}


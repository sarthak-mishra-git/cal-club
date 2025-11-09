import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/progress_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository repository;

  ProgressBloc({required this.repository}) : super(ProgressInitial()) {
    on<FetchProgressData>(_onFetchProgressData);
    on<RefreshProgressData>(_onRefreshProgressData);
  }

  Future<void> _onFetchProgressData(
    FetchProgressData event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    try {
      final response = await repository.fetchProgressData(date: event.date);
      if (response.success) {
        emit(ProgressLoaded(progressScreenModel: response.data));
      } else {
        emit(ProgressError(message: response.message ?? 'Failed to fetch progress data'));
      }
    } catch (e) {
      emit(ProgressError(message: 'Error fetching progress data: $e'));
    }
  }

  Future<void> _onRefreshProgressData(
    RefreshProgressData event,
    Emitter<ProgressState> emit,
  ) async {
    if (state is! ProgressLoaded) {
      add(FetchProgressData(date: event.date));
      return;
    }

    try {
      final response = await repository.fetchProgressData(date: event.date);
      if (response.success) {
        emit(ProgressLoaded(progressScreenModel: response.data));
      } else {
        emit(ProgressError(message: response.message ?? 'Failed to refresh progress data'));
      }
    } catch (e) {
      emit(ProgressError(message: 'Error refreshing progress data: $e'));
    }
  }
}


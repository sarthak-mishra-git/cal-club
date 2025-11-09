import 'package:equatable/equatable.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class FetchProgressData extends ProgressEvent {
  final String? date;

  const FetchProgressData({this.date});

  @override
  List<Object?> get props => [date];
}

class RefreshProgressData extends ProgressEvent {
  final String? date;

  const RefreshProgressData({this.date});

  @override
  List<Object?> get props => [date];
}


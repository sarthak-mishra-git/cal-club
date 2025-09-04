import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardData extends DashboardEvent {
  final String? date;
  
  const FetchDashboardData({this.date});
  
  @override
  List<Object?> get props => [date];
}

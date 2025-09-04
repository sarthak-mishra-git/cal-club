import 'package:equatable/equatable.dart';
import '../../models/screens/dashboard_screen_model.dart';
import '../../models/widgets/app_bar_data.dart';
import '../../models/widgets/week_view_data.dart';
import '../../models/widgets/footer_data.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final AppBarData appBarData;
  final WeekViewData weekViewData;
  final List<DashboardWidgetConfig> widgets;
  final List<FooterItemData> footerData;
  final bool showFloatingActionButton;
  const DashboardLoaded(this.appBarData, this.weekViewData, this.widgets, this.footerData, this.showFloatingActionButton);

  @override
  List<Object?> get props => [appBarData, weekViewData, widgets, footerData, showFloatingActionButton];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

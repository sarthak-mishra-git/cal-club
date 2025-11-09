import 'package:equatable/equatable.dart';
import '../../models/screens/dashboard_screen_model.dart';
import '../../models/widgets/app_bar_data.dart';
import '../../models/widgets/week_view_data.dart';
import '../../models/widgets/day_selector_data.dart';
import '../../models/widgets/footer_data.dart';
import '../../services/health_service.dart';

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
  final DaySelectorData daySelectorData;
  final List<DashboardWidgetConfig> widgets;
  final List<FooterItemData> footerData;
  final bool showFloatingActionButton;
  final HealthData? healthData;
  final HealthConnectionStatus healthConnectionStatus;
  
  const DashboardLoaded(
    this.appBarData, 
    this.weekViewData, 
    this.daySelectorData,
    this.widgets, 
    this.footerData, 
    this.showFloatingActionButton,
    {this.healthData, this.healthConnectionStatus = HealthConnectionStatus.notAvailable}
  );

  @override
  List<Object?> get props => [
    appBarData, 
    weekViewData, 
    daySelectorData,
    widgets, 
    footerData, 
    showFloatingActionButton,
    healthData,
    healthConnectionStatus
  ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

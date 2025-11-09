import '../widgets/footer_data.dart';
import '../widgets/app_bar_data.dart';
import '../widgets/week_view_data.dart';
import '../widgets/day_selector_data.dart';

class DashboardWidgetConfig {
  final String widgetType;
  final Map<String, dynamic> widgetData;

  DashboardWidgetConfig({required this.widgetType, required this.widgetData});

  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) => DashboardWidgetConfig(
        widgetType: json['widgetType'] ?? '',
        widgetData: Map<String, dynamic>.from(json['widgetData'] ?? {}),
      );
}

class DashboardScreenModel {
  final AppBarData appBarData;
  final WeekViewData weekViewData;
  final DaySelectorData daySelectorData;
  final List<DashboardWidgetConfig> widgets;
  final List<FooterItemData> footerData;
  final bool showFloatingActionButton;
  
  DashboardScreenModel({
    required this.appBarData,
    required this.weekViewData,
    required this.daySelectorData,
    required this.widgets,
    required this.footerData,
    this.showFloatingActionButton = false,
  });

  factory DashboardScreenModel.fromJson(Map<String, dynamic> json) => DashboardScreenModel(
        appBarData: AppBarData.fromJson(json['appBarData'] ?? {}),
        weekViewData: WeekViewData.fromJson(json['weekViewData'] ?? {}),
        daySelectorData: DaySelectorData.fromJson(json['daySelectorData'] ?? {}),
        widgets: (json['widgets'] as List? ?? []).map((e) => DashboardWidgetConfig.fromJson(e)).toList(),
        footerData: (json['footerData'] as List? ?? []).map((e) => FooterItemData.fromJson(e)).toList(),
        showFloatingActionButton: json['showFloatingActionButton'] ?? false,
      );
}

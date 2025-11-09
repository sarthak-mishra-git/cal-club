import 'package:flutter/material.dart';
import '../../models/screens/dashboard_screen_model.dart';
import '../../models/widgets/metric_card_data.dart';
import '../../models/widgets/macro_widget_data.dart';
import '../../models/widgets/logged_widget_data.dart';
import 'widgets/metric_carousel_widget.dart';
import 'widgets/metric_card.dart';
import 'widgets/macro_widget.dart';
import 'widgets/logged_widget.dart';

class DashboardWidgetBuilder extends StatelessWidget {
  final String widgetType;
  final Map<String, dynamic> widgetData;
  final Map<String, dynamic>? healthData;
  final VoidCallback? onCalorieTap;

  const DashboardWidgetBuilder({
    super.key,
    required this.widgetType,
    required this.widgetData,
    this.healthData,
    this.onCalorieTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (widgetType) {
      case 'summary_carousel':
        final cards = (widgetData['cards'] as List).cast<Map<String, dynamic>>();
        return MetricCarouselWidget(cards: cards);
      case 'metric_card':
        final card = MetricCardData.fromJson(widgetData);
        return MetricCard(card: card);
      case 'macro_widget':
        final macroData = MacroWidgetData.fromJson(widgetData);
        return MacroWidget(
          macroData: macroData,
          onCalorieTap: onCalorieTap,
          healthData: healthData,
        );
      case 'logged_widget':
        final loggedData = LoggedWidgetData.fromJson(widgetData);
        return LoggedWidget(loggedData: loggedData);
      default:
        return const SizedBox.shrink();
    }
  }
}

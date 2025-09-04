import 'log_entry_data.dart';
import 'zero_state_data.dart';

class LoggedWidgetData {
  final String title;
  final String subtitle;
  final List<LogEntryData> logs;
  final ZeroStateData zeroState;

  LoggedWidgetData({
    required this.title,
    required this.subtitle,
    required this.logs,
    required this.zeroState,
  });

  factory LoggedWidgetData.fromJson(Map<String, dynamic> json) => LoggedWidgetData(
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        logs: (json['logs'] as List<dynamic>?)
                ?.map((log) => LogEntryData.fromJson(log as Map<String, dynamic>))
                .toList() ??
            [],
        zeroState: ZeroStateData.fromJson(json['zero_state'] ?? {}),
      );
} 
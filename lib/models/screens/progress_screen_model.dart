import '../widgets/footer_data.dart';
import '../progress/weight_progress_model.dart';
import '../progress/daily_goal_model.dart';

class ProgressScreenModel {
  final String? header;
  final WeightProgress? weightProgress;
  final DailyGoal? dailyGoal;
  final String? lastCheckedIn;
  final String? nextCheckIn;
  final List<FooterItemData> footerData;

  ProgressScreenModel({
    this.header,
    this.weightProgress,
    this.dailyGoal,
    this.lastCheckedIn,
    this.nextCheckIn,
    required this.footerData,
  });

  factory ProgressScreenModel.fromJson(Map<String, dynamic> json) => ProgressScreenModel(
        header: json['header'] as String?,
        weightProgress: json['weightProgress'] != null 
            ? WeightProgress.fromJson(json['weightProgress'] as Map<String, dynamic>)
            : null,
        dailyGoal: json['dailyGoal'] != null
            ? DailyGoal.fromJson(json['dailyGoal'] as Map<String, dynamic>)
            : null,
        lastCheckedIn: json['lastCheckedIn'] as String?,
        nextCheckIn: json['nextCheckIn'] as String?,
        footerData: (json['footerData'] as List? ?? [])
            .map((e) => FooterItemData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
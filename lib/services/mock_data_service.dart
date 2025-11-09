import '../models/screens/dashboard_screen_model.dart';
import '../models/widgets/app_bar_data.dart';
import '../models/widgets/week_view_data.dart';
import '../models/widgets/day_selector_data.dart';
import '../models/widgets/footer_data.dart';

class MockDataService {
  static DashboardScreenModel getGuestDashboardData({String? date}) {
    return DashboardScreenModel(
      appBarData: AppBarData(
        title: "Cal Club",
        icon: "fire",
        streak: 0, // Guest has no calories burnt
      ),
      weekViewData: _getCurrentWeekData(selectedDate: date),
      daySelectorData: _getDaySelectorData(selectedDate: date),
      widgets: _getGuestWidgets(),
      footerData: _getFooterData(),
      showFloatingActionButton: true, // Still show FAB but with restriction
    );
  }

  static DaySelectorData _getDaySelectorData({String? selectedDate}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime targetDate;
    if (selectedDate != null) {
      try {
        final parsed = DateTime.parse(selectedDate);
        targetDate = DateTime(parsed.year, parsed.month, parsed.day);
      } catch (e) {
        targetDate = today;
      }
    } else {
      targetDate = today;
    }
    
    final difference = targetDate.difference(today).inDays;
    
    String dayText;
    if (difference == 0) {
      dayText = 'TODAY';
    } else if (difference == -1) {
      dayText = 'YESTERDAY';
    } else if (difference == 1) {
      dayText = 'TOMORROW';
    } else {
      // Format as "Jan 15" or similar
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dayText = '${months[targetDate.month - 1]} ${targetDate.day}';
    }
    
    // Allow navigation to previous days (no limit)
    // Allow navigation to next day (up to 7 days ahead)
    final canGoNext = difference <= 7;
    
    return DaySelectorData(
      dayText: dayText,
      prev: true, // Always allow going back
      next: canGoNext,
      date: '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
    );
  }

  static WeekViewData _getCurrentWeekData({String? selectedDate}) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Parse selected date if provided, otherwise use today
    DateTime targetDate = now;
    if (selectedDate != null) {
      try {
        targetDate = DateTime.parse(selectedDate);
      } catch (e) {
        targetDate = now;
      }
    }
    
    final days = <DayData>[];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      days.add(DayData(
        dayLetter: _getDayLetter(date.weekday),
        date: date.day,
        isSelected: date.day == targetDate.day && date.month == targetDate.month && date.year == targetDate.year, // Select target date
      ));
    }
    
    return WeekViewData(days: days);
  }

  static String _getDayLetter(int weekday) {
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return dayLetters[weekday - 1];
  }

  static List<DashboardWidgetConfig> _getGuestWidgets() {
    return [
      DashboardWidgetConfig(
        widgetType: 'macro_widget',
        widgetData: _getGuestMacroWidgetData(),
      ),
      DashboardWidgetConfig(
        widgetType: 'logged_widget',
        widgetData: _getGuestLoggedWidgetData(),
      ),
    ];
  }

  static Map<String, dynamic> _getGuestMacroWidgetData() {
    return {
      'primary_card': {
        'icon': 'fire',
        'color': 'black',
        'text': 'Calories left',
        'value': 2000, // Full daily goal for guest
        'completed': 0, // No calories consumed
        'target': 2000,
      },
      'secondary_cards': [
        {
          'icon': 'lightning',
          'color': 'red',
          'text': 'Protein',
          'value': 0, // No protein consumed
          'completed': 0,
          'target': 100,
        },
        {
          'icon': 'wheat',
          'color': 'brown',
          'text': 'Carbs',
          'value': 0, // No carbs consumed
          'completed': 0,
          'target': 150,
        },
        {
          'icon': 'water',
          'color': 'blue',
          'text': 'Fats',
          'value': 0, // No fats consumed
          'completed': 0,
          'target': 75,
        },
      ],
    };
  }

  static Map<String, dynamic> _getGuestLoggedWidgetData() {
    return {
      'title': "Today's Logs",
      'subtitle': "Login to start tracking your meals",
      'logs': [], // Empty logs for guest
      'zero_state': {
        'image': "", // Could add a guest-specific illustration
        'text': "No meals logged yet. Login to start tracking!",
      },
    };
  }

  static List<FooterItemData> _getFooterData() {
    return [
      FooterItemData(
        active: true,
        icon: "home",
        title: "Home",
        action: "navigate_home",
      ),
    //   FooterItemData(
    //     active: false,
    //     icon: "progress",
    //     title: "Progress",
    //     action: "navigate_progress",
    //   ),
    //   FooterItemData(
    //     active: false,
    //     icon: "settings",
    //     title: "Settings",
    //     action: "navigate_settings",
    //   ),
    ];
  }
}

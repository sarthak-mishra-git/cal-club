import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class MealTiming extends Equatable {
  final String label;
  final String time; // HH:mm format
  final bool enabled;

  const MealTiming({
    required this.label,
    required this.time,
    required this.enabled,
  });

  MealTiming copyWith({
    String? label,
    String? time,
    bool? enabled,
  }) {
    return MealTiming(
      label: label ?? this.label,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [label, time, enabled];
}

class MealTimingWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const MealTimingWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<MealTimingWidget> createState() => _MealTimingWidgetState();
}

class _MealTimingWidgetState extends State<MealTimingWidget> {
  List<MealTiming> _mealTimings = [];
  static const int maxTimings = 5;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  void _loadInitialValues() {
    // First try to load from saved answer
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        _mealTimings = _parseAnswer(widget.currentAnswer!.first);
        if (_mealTimings.isNotEmpty) return;
      } catch (e) {
        // Continue to load from options
      }
    }

    // If no saved answer, load from question options
    if (widget.question.options.isNotEmpty) {
      _mealTimings = widget.question.options.map((option) {
        // Parse from option text or subtext
        // Format could be "Morning:08:00" or "Morning\n08:00"
        final parts = option.text.split(':');
        if (parts.length >= 2) {
          // Convert 24-hour time to TimeOfDay format (12-hour)
          final time24h = parts[1].trim();
          final timeParts = time24h.split(':');
          final hour24 = int.tryParse(timeParts[0]) ?? 8;
          final minute =
              timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;

          // Convert to 12-hour format for storage (using TimeOfDay format)
          final timeOfDay = TimeOfDay(hour: hour24, minute: minute);
          final time12h = _formatTimeForStorage(timeOfDay);

          return MealTiming(
            label: parts[0].trim(),
            time: time12h,
            enabled: false, // Default to off
          );
        }
        // Fallback: use text as label, try to get time from subtext
        final timeFromSubtext = option.subtext?.split(':') ?? [];
        final defaultTime = TimeOfDay(hour: 8, minute: 0);
        return MealTiming(
          label: option.text,
          time: timeFromSubtext.length >= 2
              ? _formatTimeForStorage(TimeOfDay(
                  hour: int.tryParse(timeFromSubtext[0]) ?? 8,
                  minute: int.tryParse(timeFromSubtext[1]) ?? 0,
                ))
              : _formatTimeForStorage(defaultTime),
          enabled: false,
        );
      }).toList();
    } else {
      // Default timings if none provided
      _mealTimings = [
        MealTiming(
            label: 'Meal 1',
            time: _formatTimeForStorage(const TimeOfDay(hour: 8, minute: 0)),
            enabled: true),
        MealTiming(
            label: 'Meal 2',
            time: _formatTimeForStorage(const TimeOfDay(hour: 13, minute: 0)),
            enabled: true),
        MealTiming(
            label: 'Meal 3',
            time: _formatTimeForStorage(const TimeOfDay(hour: 19, minute: 0)),
            enabled: true),
      ];
    }

    _saveAnswer();
  }

  List<MealTiming> _parseAnswer(String answer) {
    // Format: "Morning:8:00 AM:true,Lunch:1:00 PM:false"
    final List<MealTiming> timings = [];
    final parts = answer.split(',');

    for (final part in parts) {
      // Handle format: "Label:Time:Enabled" where Time might be "8:00 AM" or "1:00 PM"
      // Need to handle colons in time (e.g., "8:00 AM")
      final colonIndex = part.indexOf(':');
      if (colonIndex == -1) continue;

      final label = part.substring(0, colonIndex);
      final rest = part.substring(colonIndex + 1);

      // Find the last colon for the enabled flag
      final lastColonIndex = rest.lastIndexOf(':');
      if (lastColonIndex == -1) continue;

      final timeStr = rest.substring(0, lastColonIndex);
      final enabledStr = rest.substring(lastColonIndex + 1);

      timings.add(MealTiming(
        label: label.trim(),
        time: timeStr.trim(),
        enabled: enabledStr.trim() == 'true',
      ));
    }

    return timings;
  }

  String _formatAnswer() {
    // Format: "Morning:8:00 AM:true,Lunch:1:00 PM:false"
    return _mealTimings.map((timing) {
      return '${timing.label}:${timing.time}:${timing.enabled}';
    }).join(',');
  }

  // Format TimeOfDay to storage format (12-hour with AM/PM)
  String _formatTimeForStorage(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour;
    final minute = timeOfDay.minute;
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final hourStr = hour12.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  void _saveAnswer() {
    widget.onAnswerChanged([_formatAnswer()]);
  }

  void _onToggleChanged(int index, bool value) {
    setState(() {
      _mealTimings[index] = _mealTimings[index].copyWith(enabled: value);
      _saveAnswer();
    });
  }

  void _onTimeChanged(int index, TimeOfDay newTime) {
    setState(() {
      final timeString = _formatTimeForStorage(newTime);
      _mealTimings[index] = _mealTimings[index].copyWith(time: timeString);
      _saveAnswer();
    });
  }

  void _onDelete(int index) {
    setState(() {
      _mealTimings.removeAt(index);
      _renumberMealLabels();
      _saveAnswer();
    });
  }

  void _renumberMealLabels() {
    // Renumber all "Meal X" labels sequentially
    int mealNumber = 1;
    for (int i = 0; i < _mealTimings.length; i++) {
      if (_mealTimings[i].label.startsWith('Meal ')) {
        _mealTimings[i] = _mealTimings[i].copyWith(label: 'Meal $mealNumber');
        mealNumber++;
      }
    }
  }

  void _onAddNew() {
    if (_mealTimings.length >= maxTimings) return;

    setState(() {
      // Find the highest meal number
      int maxMealNumber = 0;
      for (final timing in _mealTimings) {
        if (timing.label.startsWith('Meal ')) {
          final match = RegExp(r'Meal (\d+)').firstMatch(timing.label);
          if (match != null) {
            final num = int.tryParse(match.group(1)!);
            if (num != null && num > maxMealNumber) {
              maxMealNumber = num;
            }
          }
        }
      }

      final newLabel = 'Meal ${maxMealNumber + 1}';
      _mealTimings.add(MealTiming(
        label: newLabel,
        time: _formatTimeForStorage(const TimeOfDay(hour: 8, minute: 0)),
        enabled: false,
      ));
      _saveAnswer();
    });
  }

  TimeOfDay _parseTimeFromStorage(String timeStr) {
    // Parse "8 AM", "8:00 AM", "1 PM", "1:00 PM" format
    final trimmed = timeStr.trim();

    // Extract AM/PM
    final isPM = trimmed.toUpperCase().contains('PM');
    final isAM = trimmed.toUpperCase().contains('AM');

    // Remove AM/PM
    final timeWithoutPeriod =
        trimmed.replaceAll(RegExp(r'\s*[AaPp][Mm]\s*'), '').trim();

    final parts = timeWithoutPeriod.split(':');
    var hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    // Convert 12-hour to 24-hour
    if (isPM && hour != 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _showTimePicker(int index) async {
    final timing = _mealTimings[index];
    final timeOfDay = _parseTimeFromStorage(timing.time);

    // Use a list to hold the selected DateTime so it persists across rebuilds
    final selectedDateTimeHolder = [
      DateTime(2000, 1, 1, timeOfDay.hour, timeOfDay.minute)
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(modalContext),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final selectedTime = TimeOfDay(
                              hour: selectedDateTimeHolder[0].hour,
                              minute: selectedDateTimeHolder[0].minute,
                            );
                            _onTimeChanged(index, selectedTime);
                            Navigator.pop(modalContext);
                          },
                          child: Text(
                            'Done',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time picker
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: selectedDateTimeHolder[0],
                      use24hFormat: false,
                      onDateTimeChanged: (DateTime newDateTime) {
                        selectedDateTimeHolder[0] = newDateTime;
                        setModalState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            widget.question.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),

          // Subtext (optional)
          if (widget.question.subtext != null &&
              widget.question.subtext!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.subtext!,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Meal timing list
          ...List.generate(_mealTimings.length, (index) {
            return _buildMealTimingItem(index);
          }),

          // Add new timing button
          if (_mealTimings.length < maxTimings) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _onAddNew,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                  backgroundColor: Colors.white,
                ),
                icon: Icon(Icons.add, color: Colors.grey[700], size: 20),
                label: Text(
                  'Add new timing',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealTimingItem(int index) {
    final timing = _mealTimings[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left side: Label and time
          Expanded(
            child: GestureDetector(
              onTap: () => _showTimePicker(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timing.label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timing.time),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: Delete icon and toggle
          Row(
            children: [
              Switch(
                inactiveTrackColor: Colors.white,
                inactiveThumbColor: Colors.grey[500],
                value: timing.enabled,
                onChanged: (value) => _onToggleChanged(index, value),
                activeColor: Colors.white,
                activeTrackColor: Colors.black,
                // trackOutlineColor: MaterialStateProperty.all(Colors.black),
                trackOutlineWidth: MaterialStateProperty.resolveWith<double?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return 0;
                  }
                  return 0; // Use the default width.
                }),
              ),
              const SizedBox(width: 8),
              Container(
                // color: Colors.red,
                child: IconButton(
                  onPressed: () => _onDelete(index),
                  icon: Icon(
                    CupertinoIcons.delete,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    // Time is already stored in 12-hour format (e.g., "8 AM" or "8:00 AM")
    // Just return it as is, or format consistently
    // If minutes are 00, show just hour (e.g., "8 AM"), otherwise show full time (e.g., "8:00 AM")
    final trimmed = time.trim();

    // Check if it already has AM/PM
    if (trimmed.toUpperCase().contains('AM') ||
        trimmed.toUpperCase().contains('PM')) {
      // Parse and reformat for consistency
      final timeOfDay = _parseTimeFromStorage(trimmed);
      return _formatTimeForStorage(timeOfDay);
    }

    // Fallback: treat as 24-hour and convert
    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return _formatTimeForStorage(timeOfDay);
  }
}

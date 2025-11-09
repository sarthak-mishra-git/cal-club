import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class DateWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const DateWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  late DateTime _selectedDate;
  final DateTime _today = DateTime.now();
  final DateTime _minDate = DateTime(1950, 1, 1);

  @override
  void initState() {
    super.initState();
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        final parsedDate = DateTime.parse(widget.currentAnswer!.first);
        _selectedDate = _clampDate(parsedDate);
      } catch (e) {
        _selectedDate = _clampDate(DateTime(2000, 6, 15));
      }
    } else {
      _selectedDate = _clampDate(DateTime(2000, 6, 15));
      // Emit default date if no current answer exists
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAnswerChanged([_selectedDate.toIso8601String().split('T')[0]]);
      });
    }
  }

  @override
  void didUpdateWidget(DateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        final parsedDate = DateTime.parse(widget.currentAnswer!.first);
        _selectedDate = _clampDate(parsedDate);
      } catch (e) {
        _selectedDate = _clampDate(DateTime.now());
      }
    } else {
      _selectedDate = _clampDate(DateTime.now());
    }
  }

  /// Clamps the date to valid range (minDate to today) and adjusts day if invalid for month
  DateTime _clampDate(DateTime date) {
    // First, ensure day is valid for the given month/year
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final validDay = date.day > daysInMonth ? daysInMonth : date.day;
    var clampedDate = DateTime(date.year, date.month, validDay);
    
    // Clamp to valid range (minDate to today)
    if (clampedDate.isAfter(_today)) {
      clampedDate = _today;
    } else if (clampedDate.isBefore(_minDate)) {
      clampedDate = _minDate;
    }
    
    return clampedDate;
  }

  /// Gets a valid date with the given year/month/day, adjusting day if needed
  DateTime _getValidDate(int year, int month, int day) {
    // Ensure month is valid (1-12)
    final validMonth = month.clamp(1, 12);
    
    // Get days in the month
    final daysInMonth = DateTime(year, validMonth + 1, 0).day;
    
    // Clamp day to valid range for the month
    final validDay = day.clamp(1, daysInMonth);
    
    // Create the date
    var date = DateTime(year, validMonth, validDay);
    
    // Clamp to valid range (minDate to today)
    if (date.isAfter(_today)) {
      date = _today;
    } else if (date.isBefore(_minDate)) {
      date = _minDate;
    }
    
    return date;
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
          if (widget.question.subtext != null && widget.question.subtext!.isNotEmpty) ...[
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
          
          const SizedBox(height: 80),
          
          // Cupertino Date Picker
          Container(
            height: 300,
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(6),
            //   border: Border.all(color: Colors.grey[200]!, width: 1),
            // ),
            child: Row(
              children: [
                // Month picker
                Expanded(
                  child: _buildMonthPicker(),
                ),
                // Day picker
                Expanded(
                  child: _buildDayPicker(),
                ),
                // Year picker
                Expanded(
                  child: _buildYearPicker(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    // If selected year is today's year, limit months to today's month
    final isCurrentYear = _selectedDate.year == _today.year;
    final maxMonth = isCurrentYear ? _today.month : 12;
    final availableMonths = months.sublist(0, maxMonth);
    
    // Ensure selected month is within valid range
    final selectedMonthIndex = (_selectedDate.month - 1).clamp(0, maxMonth - 1);
    
    return CupertinoPicker(
      itemExtent: 50,
      scrollController: FixedExtentScrollController(
        initialItem: selectedMonthIndex,
      ),
      onSelectedItemChanged: (int index) {
        setState(() {
          // Use _getValidDate to adjust day if invalid for new month
          _selectedDate = _getValidDate(
            _selectedDate.year,
            index + 1,
            _selectedDate.day,
          );
        });
        widget.onAnswerChanged([_selectedDate.toIso8601String().split('T')[0]]);
      },
      children: availableMonths.map((month) => Center(
        child: Text(
          month,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDayPicker() {
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    
    // If selected month/year is today's month/year, limit days to today
    final isCurrentMonthAndYear = _selectedDate.year == _today.year && 
                                   _selectedDate.month == _today.month;
    final maxDay = isCurrentMonthAndYear ? _today.day : daysInMonth;
    
    final days = List.generate(maxDay, (index) => (index + 1).toString());
    
    // Ensure selected day is within valid range (in case it was clamped)
    final selectedDayIndex = (_selectedDate.day - 1).clamp(0, maxDay - 1);
    
    return CupertinoPicker(
      itemExtent: 50,
      scrollController: FixedExtentScrollController(
        initialItem: selectedDayIndex,
      ),
      onSelectedItemChanged: (int index) {
        setState(() {
          _selectedDate = _getValidDate(
            _selectedDate.year,
            _selectedDate.month,
            index + 1,
          );
        });
        widget.onAnswerChanged([_selectedDate.toIso8601String().split('T')[0]]);
      },
      children: days.map((day) => Center(
        child: Text(
          day,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildYearPicker() {
    // Generate years from 1950 to current year
    final yearCount = _today.year - 1950 + 1;
    final years = List.generate(yearCount, (index) => (1950 + index).toString());
    
    // Ensure selected year is within valid range
    final selectedYearIndex = (_selectedDate.year - 1950).clamp(0, yearCount - 1);
    
    return CupertinoPicker(
      itemExtent: 50,
      scrollController: FixedExtentScrollController(
        initialItem: selectedYearIndex,
      ),
      onSelectedItemChanged: (int index) {
        setState(() {
          final selectedYear = 1950 + index;
          // Use _getValidDate to adjust day/month if needed (e.g., leap year, month length)
          _selectedDate = _getValidDate(
            selectedYear,
            _selectedDate.month,
            _selectedDate.day,
          );
        });
        widget.onAnswerChanged([_selectedDate.toIso8601String().split('T')[0]]);
      },
      children: years.map((year) => Center(
        child: Text(
          year,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

}
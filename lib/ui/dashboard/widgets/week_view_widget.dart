import 'package:flutter/material.dart';
import '../../../models/widgets/week_view_data.dart';

class WeekViewWidget extends StatelessWidget {
  final WeekViewData weekViewData;
  final Function(int)? onDayTap;

  const WeekViewWidget({
    super.key,
    required this.weekViewData,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekViewData.days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          
          return GestureDetector(
            onTap: () => onDayTap?.call(index),
            child: Container(
              width: 40,
              height: 65,
              decoration: BoxDecoration(
                color: day.isSelected ? Colors.grey[700] : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
                border: day.isSelected 
                    ? Border.all(color: Colors.grey[400]!, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.dayLetter,
                    style: TextStyle(
                      color: day.isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.date.toString(),
                    style: TextStyle(
                      color: day.isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 
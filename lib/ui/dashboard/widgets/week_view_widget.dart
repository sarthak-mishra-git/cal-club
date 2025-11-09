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
      padding: const EdgeInsets.only(left: 4, right: 4, top: 6, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekViewData.days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          
          return GestureDetector(
            onTap: () => onDayTap?.call(index),
            child: Container(
              width: day.isSelected ? 45 : 40,
              height: 80,
              decoration: BoxDecoration(
                color: day.isSelected ? Color(0xFFF6F7F9) : Colors.transparent,
                borderRadius: day.isSelected ? BorderRadius.circular(22.5) : BorderRadius.circular(20),
                border: day.isSelected
                    ? Border.all(color: Colors.grey[400]!, width: 1)
                    : null,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    day.dayLetter,
                    style: TextStyle(
                      color: day.isSelected ? Colors.black : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.isSelected ? Colors.white : Colors.transparent,
                      boxShadow: day.isSelected
                          ? [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                      // border: day.isSelected
                      //     ? Border.all(color: Colors.grey[400]!, width: 1)
                      //     : null,
                    ),
                    child: Text(
                      day.date.toString(),
                      style: TextStyle(
                        color: day.isSelected ? Colors.black : Colors.grey[400],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
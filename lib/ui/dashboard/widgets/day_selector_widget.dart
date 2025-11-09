import 'package:flutter/material.dart';
import '../../../models/widgets/day_selector_data.dart';

class DaySelectorWidget extends StatelessWidget {
  final DaySelectorData daySelectorData;
  final Function()? onPrevTap;
  final Function()? onNextTap;

  const DaySelectorWidget({
    super.key,
    required this.daySelectorData,
    this.onPrevTap,
    this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          GestureDetector(
            onTap: daySelectorData.prev ? onPrevTap : null,
            child: Container(
              // color: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.chevron_left,
                color: daySelectorData.prev ? Colors.white : Colors.grey[800],
                size: 30,
              )
            ),
          ),
          // const SizedBox(width: 8),
          // Day text
          Container(
            alignment: Alignment.center,
            // color: Colors.blue,
            width: 100,
            child: Text(
              daySelectorData.dayText.toUpperCase(),
              // "07 NOV",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              // align: TextAlign.center
            ),
          ),
          // const SizedBox(width: 8),
          // Next button
          GestureDetector(
            onTap: daySelectorData.next ? onNextTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.chevron_right,
                color: daySelectorData.next ? Colors.white : Colors.grey[800],
                size: 30,
              )
            ),
          ),
        ],
      ),
    );
  }
}


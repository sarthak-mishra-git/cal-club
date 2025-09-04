import 'package:flutter/material.dart';
import '../../../models/widgets/metric_card_data.dart';
import '../../../constants.dart';

class MetricCard extends StatelessWidget {
  final MetricCardData card;
  const MetricCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final double value = card.value;
    final String title = card.title;
    final double? goal = card.goal;
    final String? unit = card.unit;
    return Container(
      margin: const EdgeInsets.all(kCardMargin),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: kCardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(_iconForTitle(title), size: 32, color: kPrimaryColor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (goal != null)
                  Text('Goal: $goal', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            const Spacer(),
            Text(
              value.toString() + (unit != null ? ' $unit' : ''),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'steps':
        return Icons.directions_walk;
      case 'exercise':
        return Icons.fitness_center;
      case 'calories':
        return Icons.local_fire_department;
      default:
        return Icons.analytics;
    }
  }
}

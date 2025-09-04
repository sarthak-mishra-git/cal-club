import 'package:flutter/material.dart';
import '../../../constants.dart';

class SummaryCarouselCard extends StatelessWidget {
  final int remaining;
  final int goal;
  final int food;
  final int exercise;
  const SummaryCarouselCard({
    super.key,
    required this.remaining,
    required this.goal,
    required this.food,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = goal > 0 ? (remaining / goal).clamp(0.0, 1.0) : 0.0;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      remaining.toString(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      kLabelRemaining,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      const Text('Goal', style: TextStyle(fontSize: 13, color: Colors.black87)),
                      const Spacer(),
                      Text(
                        goal.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 18, color: kPrimaryColor),
                      const SizedBox(width: 6),
                      const Text('Food', style: TextStyle(fontSize: 13, color: Colors.black87)),
                      const Spacer(),
                      Text(
                        food.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: kPrimaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 18, color: kAccentColor),
                      const SizedBox(width: 6),
                      const Text('Exercise', style: TextStyle(fontSize: 13, color: Colors.black87)),
                      const Spacer(),
                      Text(
                        exercise.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: kAccentColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

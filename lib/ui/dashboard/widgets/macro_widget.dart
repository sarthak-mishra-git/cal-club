import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/widgets/macro_widget_data.dart';
import '../../../models/widgets/macro_card_data.dart';
import 'dart:math';

class MacroWidget extends StatelessWidget {
  final MacroWidgetData macroData;
  final VoidCallback? onCalorieTap;
  final Map<String, dynamic>? healthData;

  const MacroWidget({
    super.key,
    required this.macroData,
    this.onCalorieTap,
    this.healthData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Card - New Circular Gauge Design
          _buildPrimaryCard(
              macroData.primaryCard, onCalorieTap, healthData, context),
          const SizedBox(height: 12),
          // Secondary Cards - New Vertical Layout with Circular Gauges
          _buildSecondaryCards(macroData.secondaryCards),
        ],
      ),
    );
  }

  Widget _buildPrimaryCard(MacroCardData card, VoidCallback? onCalorieTap,
      Map<String, dynamic>? healthData, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Center Section - Large Semi-circular Gauge (Background)
          // Large White Circle with Integrated Semi-circle
          Positioned(
            top: 34,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 124,
                width: 124,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Drop shadow for elevation
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                    // Inner shadow for embossed effect
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Semi-circular Progress Ring
          Positioned(
            top: -86, // Adjusted to center the semi-circle
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                size: const Size(180, 180),
                painter: IntegratedSemiCircularPainter(
                  progress: calculateProgress(card.completed, card.target),
                  strokeWidth: 20,
                ),
              ),
            ),
          ),
          // Flame pointer positioned at end of progress
          Positioned(
            top: _getFlamePosition(calculateProgress(card.completed, card.target), context).dy - 14, // Adjusted for main Stack
            left: _getFlamePosition(calculateProgress(card.completed, card.target), context).dx - 14,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: Image.asset(
                    'assets/images/black_flame.png',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // Text content
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 34,
                    ),
                    Text(
                      '${card.value.toInt()}',
                      style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 0.9),
                    ),
                    Text(
                      '${card.text}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Left Section - Kcal Eaten (Positioned over/behind center)
          Positioned(
            left: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card.completed.toInt()}',
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 0.9),
                  ),
                  const Text(
                    'Food Intake',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Section - Kcal Burned (Positioned over/behind center)
          if (healthData != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                // onTap: onCalorieTap,
                onTap: null,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getActiveCaloriesBurned(healthData),
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade400,
                            height: 0.9),
                      ),
                      const Text(
                        'Exercise Burn',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCards(List<MacroCardData> cards) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cards.take(3).map((card) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _buildSecondaryCard(card),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSecondaryCard(MacroCardData card) {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large Circular Gauge with Icon
          SizedBox(
            width: 85,
            height: 85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring Background
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 8,
                    ),
                  ),
                ),
                // Progress Ring with Vibrant Color
                CustomPaint(
                  size: const Size(85, 85),
                  painter: CircularProgressPainter(
                    progress: calculateProgress(card.completed, card.target), // ~60% progress
                    strokeWidth: 8,
                    color: _getVibrantColor(card.icon),
                  ),
                ),
                // White Inner Circle with Enhanced Shadow
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F7F9)!,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _getIconData(card.icon) is String
                      ? Center(
                          child: Image.asset(
                            _getIconData(card.icon),
                            width: 24,
                            height: 24,
                            color: _getVibrantColor(card.icon),
                          ),
                        )
                      : Icon(
                          _getIconData(card.icon),
                          color: _getVibrantColor(card.icon),
                          size: 28,
                        ),
                ),
              ],
            ),
          ),
          // Text content with current/total format
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${card.value.toInt()}g',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                '/',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                '${card.target.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            '${card.text} left',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  dynamic _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'fire':
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'lightning':
        return Icons.bolt;
      case 'wheat':
        return 'assets/images/fibre_icon.png';
      case 'water':
      case 'drop':
        return Icons.water_drop_outlined;
      case 'protein':
        return Icons.fitness_center;
      case 'carbs':
        return 'assets/images/fibre_icon.png';
      case 'fats':
        return Icons.water_drop;
      default:
        return Icons.circle;
    }
  }

  Color _getVibrantColor(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'fire':
      case 'flame':
        return Colors.orange;
      case 'lightning':
        return Colors.orange;
      case 'protein':
        return Colors.orange;
      case 'wheat':
        return Colors.pink[400]!;
      case 'carbs':
        return Colors.pink[400]!;
      case 'water':
      case 'drop':
        return Colors.blue;
      case 'fats':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}

// Custom Painter for Integrated Semi-circular Gauge
class IntegratedSemiCircularPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  IntegratedSemiCircularPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc (light gray)
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14, // Start from top (π)
      3.14, // Half circle
      false,
      backgroundPaint,
    );

    // Progress arc with gradient (dark to light gray)
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Create gradient from dark gray to light gray
    final gradient = LinearGradient(
      colors: [Colors.grey[800]!, Colors.grey[300]!],
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    progressPaint.shader = gradient.createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14, // Start from top
      3.14 * progress, // Progress amount (~33%)
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Custom Painter for Circular Progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start from top
      3.14 * progress, // Progress amount
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Helper method to get calories burned from health data
String _getCaloriesBurned(Map<String, dynamic>? healthData) {
  if (healthData != null && healthData!['totalCalories'] != null) {
    return healthData!['totalCalories'].toString();
  }

  return '';
}

String _getActiveCaloriesBurned(Map<String, dynamic>? healthData) {
  if (healthData != null && healthData!['activeCalories'] != null) {
    return (healthData!['activeCalories'] as double).toInt().toString();
  }

  return '';
}



// Helper method to calculate flame position on progress bar
Offset _getFlamePosition(double progress, BuildContext context) {
  // Semi-circle center is at (90, 90) with radius 70
  // Progress goes from 0 to 1 (0% to 100%)
  // Start angle is π (top), end angle is 0 (right)
  final angle = (3.14 * progress); // Convert progress to angle
  final radius = 80.0; // Distance from center to progress bar
  final centerX = MediaQuery.of(context).size.width / 2 - 24 - 24;
  final centerY = 94.0;

  // Calculate position on the arc using proper trigonometry
  final x = centerX - radius * cos(angle);
  final y = centerY - radius * sin(angle);

  return Offset(x, y);
  // return Offset(centerX, centerY);
}

double calculateProgress(double completed, double target) {
  if (target == 0) return 0.0;
  return (completed / target).clamp(0.0, 1.0);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';
import '../../../models/onboarding/option_model.dart';

class MultiSelectWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const MultiSelectWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  @override
  void didUpdateWidget(MultiSelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force rebuild when answer changes
    if (oldWidget.currentAnswer != widget.currentAnswer) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedValues = widget.currentAnswer ?? [];

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
          
          const SizedBox(height: 32),
          
          // Options container with minimum height for centering
          Container(
            constraints: const BoxConstraints(minHeight: 500),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.question.options.map((option) => _buildOption(
                  context,
                  option,
                  selectedValues.contains(option.text),
                  () {
                    final newValues = List<String>.from(selectedValues);
                    if (newValues.contains(option.text)) {
                      newValues.remove(option.text);
                    } else {
                      newValues.add(option.text);
                    }
                    widget.onAnswerChanged(newValues);
                  },
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, Option option, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isSelected ? Colors.black : Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 2 : 0,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.black,
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // Icon
                if (option.icon != null) ...[
                  Container(
                    width: 24,
                    height: 24,
                    child: Icon(
                      _getIconData(option.icon!),
                      size: 20,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Option content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main text
                      Text(
                        option.text,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      
                      // Subtext (if available)
                      if (option.subtext != null && option.subtext!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          option.subtext!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isSelected ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      case 'other':
        return Icons.transgender;
      case 'yes':
        return Icons.check_circle;
      case 'no':
        return Icons.cancel;
      case 'sometimes':
        return Icons.help_outline;
      case 'often':
        return Icons.trending_up;
      case 'rarely':
        return Icons.trending_down;
      case 'never':
        return Icons.block;
      case 'always':
        return Icons.all_inclusive;
      case 'light':
        return Icons.wb_sunny;
      case 'moderate':
        return Icons.wb_cloudy;
      case 'heavy':
        return Icons.fitness_center;
      case 'sedentary':
        return Icons.chair;
      case 'active':
        return Icons.directions_run;
      case 'very_active':
        return Icons.sports_tennis;
      case 'lose':
        return Icons.trending_down;
      case 'maintain':
        return Icons.trending_flat;
      case 'gain':
        return Icons.trending_up;
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle;
      case 'facebook':
        return Icons.facebook;
      case 'vegetarian':
        return Icons.eco;
      case 'vegan':
        return Icons.park;
      case 'eggitarian':
        return Icons.egg;
      case 'consistency':
        return Icons.schedule;
      case 'habits':
        return Icons.restaurant;
      case 'support':
        return Icons.group;
      case 'schedule':
        return Icons.access_time;
      case 'inspiration':
        return Icons.lightbulb;
      case 'health':
        return Icons.health_and_safety;
      case 'energy':
        return Icons.battery_charging_full;
      case 'motivation':
        return Icons.psychology;
      case 'confidence':
        return Icons.self_improvement;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}

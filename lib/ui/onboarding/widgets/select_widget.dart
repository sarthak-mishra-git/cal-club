import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';
import '../../../models/onboarding/option_model.dart';

class SelectWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const SelectWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<SelectWidget> createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {
  @override
  void didUpdateWidget(SelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force rebuild when answer changes
    if (oldWidget.currentAnswer != widget.currentAnswer) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = widget.currentAnswer?.isNotEmpty == true ? widget.currentAnswer!.first : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            widget.question.text,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
            // style: GoogleFonts.poppins(
            //   fontSize: 24,
            //   fontWeight: FontWeight.bold,
            //   color: Colors.black87,
            //   height: 1.2,
            // ),
          ),
          
          // Subtext (optional)
          if (widget.question.subtext != null && widget.question.subtext!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.subtext!,
              // style: GoogleFonts.poppins(
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ],

          if (widget.question.image != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.question.image!.paddingHorizontal ?? 0,
                  vertical: widget.question.image!.paddingVertical ?? 0,
                ),
                child: Image.network(
                  widget.question.image!.url,
                  height: widget.question.image!.height ?? 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails to load
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF6F7F9),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Options container with minimum height for centering
          Container(
            // color: Colors.red,
            constraints: const BoxConstraints(minHeight: 500),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.question.options.map((option) => _buildOption(
                  context,
                  option,
                  selectedValue == option.text,
                  () => widget.onAnswerChanged([option.text]),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, Option option, bool isSelected, VoidCallback onTap) {
    print('Building option: ${option}, isSelected: $isSelected');
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Icon
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main text
                    Text(
                      option.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      // style: GoogleFonts.poppins(
                      //   fontSize: 16,
                      //   fontWeight: FontWeight.w600,
                      //   color: isSelected ? Colors.white : Colors.black87,
                      // ),
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
        return CupertinoIcons.camera;
      case 'youtube':
        return CupertinoIcons.play_rectangle;
      case 'facebook':
        return Icons.facebook;
      case 'thumbs_up':
        return Icons.thumb_up;
      case 'thumbs_down':
        return Icons.thumb_down;
      case 'bar_graph':
        return Icons.bar_chart;
      case 'burger':
        return Icons.fastfood;
      case 'hand_shake':
        return Icons.handshake;
      case 'calendar':
        return Icons.calendar_today;
      case 'light_bulb_slash':
        return CupertinoIcons.lightbulb_slash;
        case 'meat':
        return Icons.set_meal_sharp;
      case 'vegetarian':
        return Icons.eco;
      case 'vegan':
        return Icons.park;
      case 'eggitarian':
        return Icons.egg_outlined;
        case 'desk_job':
        return CupertinoIcons.device_desktop;
      case 'car':
        return Icons.directions_car;
      case 'shoe':
        return Icons.directions_walk;
      case 'running':
        return Icons.directions_run;
      case 'cycle':
        return Icons.directions_bike;
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

//
// "options": [
// {
// "text": "Sedentary (Desk Job)",
// "subtext": "Less than 3k steps per day",
// "icon": "desk_job"
// },
// {
// "text": "Light (Occasional Activity)",
// "subtext": "Between 3k - 7k steps daily",
// "icon": "car"
// },
// {
// "text": "Active (Regular Dxercise)",
// "subtext": "Between 7k - 10k steps daily",
// "icon": "shoe"
// },
// {
// "text": "Very Active (Intense Physical Activity)",
// "subtext": "More than 10k steps per day",
// "icon": "running"
// },
// {
// "text": "Dynamic (Varied Intensity Movement)",
// "subtext": "Varies daily, anything between 5k - 20k+",
// "icon": "cycle"
// }
// ],
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class SliderWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const SliderWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  static const double minValue = 0.2;
  static const double maxValue = 0.9;
  static const double recommendedValue = 0.5;
  
  late double currentValue;

  @override
  void initState() {
    super.initState();
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        currentValue = double.parse(widget.currentAnswer!.first);
      } catch (e) {
        currentValue = recommendedValue;
      }
    } else {
      currentValue = recommendedValue;
    }
  }

  @override
  void didUpdateWidget(SliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        final newValue = double.parse(widget.currentAnswer!.first);
        if (currentValue != newValue) {
          setState(() {
            currentValue = newValue;
          });
        }
      } catch (e) {
        // Keep current value
      }
    }
  }

  void _updateValue(double value) {
    setState(() {
      currentValue = value;
    });
    widget.onAnswerChanged([value.toStringAsFixed(1)]);
  }

  void _setRecommended() {
    _updateValue(recommendedValue);
  }

  String _getSpeedLabel() {
    if (widget.question.text.toLowerCase().contains('gain')) {
      return 'Gain weight speed per week';
    } else if (widget.question.text.toLowerCase().contains('lose') || 
               widget.question.text.toLowerCase().contains('loss')) {
      return 'Lose weight speed per week';
    } else {
      return 'Change weight speed per week';
    }
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
              fontSize: 28,
              fontWeight: FontWeight.w600,
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
          
          const SizedBox(height: 48),
          
          // Current value display
          Container(
            constraints: const BoxConstraints(minHeight: 450),
            // color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        _getSpeedLabel(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currentValue.toStringAsFixed(1)} kg',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Snail icon (slow)
                    Text(
                      '🐌',
                      style: TextStyle(
                        fontSize: 26,
                        color: currentValue <= 0.3 ? Colors.black : Colors.grey[400],
                      ),
                    ),
                    // Rabbit icon (medium)
                    Text(
                      '🐇',
                      style: TextStyle(
                        fontSize: 26,
                        color: currentValue > 0.3 && currentValue <= 1.0
                            ? Colors.black
                            : Colors.grey[400],
                      ),
                    ),
                    // Horse icon (fast)
                    Text(
                      '🐎',
                      style: TextStyle(
                        fontSize: 26,
                        color: currentValue > 1.0 ? Colors.black : Colors.grey[400],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 4,
                    ),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: currentValue,
                    min: minValue,
                    max: maxValue,
                    // divisions: 28, // 0.1 to 1.5 with 0.05 steps = 28 divisions
                    onChanged: _updateValue,
                  ),
                ),

                const SizedBox(height: 8),

                // Min and Max labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${minValue.toStringAsFixed(1)} kg',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((minValue + maxValue) / 2).toStringAsFixed(1)} kg',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${maxValue.toStringAsFixed(1)} kg',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Recommended button
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: 350,
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        _getRecommendedText(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecommendedText() {
    if(currentValue <= recommendedValue - 0.2) {
      return 'A bit cautious, aren\'t we?';
    } else if (currentValue >= recommendedValue + 0.2) {
      return 'Love the ambition!';
    }
    return 'Right on track with the recommendation';
  }
}




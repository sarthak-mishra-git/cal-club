import 'package:flutter/material.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class RatingWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const RatingWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        _rating = int.parse(widget.currentAnswer!.first);
      } catch (e) {
        _rating = 0;
      }
    }
  }

  @override
  void didUpdateWidget(RatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always sync with current answer when widget updates
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        _rating = int.parse(widget.currentAnswer!.first);
      } catch (e) {
        _rating = 0;
      }
    } else {
      _rating = 0;
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
            style: const TextStyle(
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Star rating
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                    widget.onAnswerChanged([_rating.toString()]);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 48,
                      color: index < _rating ? Colors.amber : Colors.grey[400],
                    ),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Rating text
          Center(
            child: Text(
              _getRatingText(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class NoInputWidget extends StatelessWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;

  const NoInputWidget({
    super.key,
    required this.question,
    this.currentAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      constraints: const BoxConstraints(
        minHeight: 650, // Set the minimum height
      ),
      // color: Colors.red,
      // padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Display image if provided
          if (question.image != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: question.image!.paddingHorizontal ?? 0,
                vertical: question.image!.paddingVertical ?? 0,
              ),
              child: question.image!.height != null
                  ? Image.network(
                question.image!.url,
                height: question.image!.height, // Use explicit height if given
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _fallbackImage();
                },
              )
                  : LayoutBuilder(
                builder: (context, constraints) {
                  return Image.network(
                    question.image!.url,
                    width: constraints.maxWidth, // take all available width
                    fit: BoxFit.contain, // adjust height automatically
                    errorBuilder: (context, error, stackTrace) {
                      return _fallbackImage();
                    },
                  );
                },
              ),
            ),
          // Fallback to default illustration for welcome/thank you screens
          // else if (question.sequence == 1 || question.sequence == 19)
          //   Container(
          //     width: 120,
          //     height: 120,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       gradient: LinearGradient(
          //         colors: [
          //           Colors.purple.withOpacity(0.1),
          //           Colors.pink.withOpacity(0.1),
          //         ],
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //       ),
          //     ),
          //     child: Icon(
          //       question.sequence == 1 ? Icons.waving_hand : Icons.favorite,
          //       size: 48,
          //       color: Colors.purple.withOpacity(0.7),
          //     ),
          //   ),
          
          //const SizedBox(height: 24),
          
          // Main text
          Column(
            children: [
              Text(
                  question.text,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.2),
                  textAlign: TextAlign.center,
              ),

              // Subtext (optional)
              if (question.subtext != null && question.subtext!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  question.subtext!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              //const SizedBox(height: 16),
            ],
          ),
          

        ],
      ),
    );
  }
}

Widget _fallbackImage() {
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
}

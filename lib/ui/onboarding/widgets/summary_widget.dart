import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';
import '../../../blocs/onboarding/onboarding_state.dart';

class SummaryWidget extends StatelessWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;
  final OnboardingLoaded state;

  const SummaryWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
    required this.state,
  });

  // Use values directly from state (extracted in bloc, similar to userName)
  String? get _userName => state.userName;
  int? get _age => state.age;
  String? get _gender => state.gender;
  double? get _height => state.height;
  double? get _weight => state.weight;

  // Calculate BMI
  double? get _bmi {
    if (_height == null || _weight == null) return null;
    // Height is in cm, convert to meters
    final heightInMeters = _height! / 100;
    return _weight! / (heightInMeters * heightInMeters);
  }

  // Calculate BMR using Mifflin-St Jeor Equation
  double? get _bmr {
    if (_height == null || _weight == null || _age == null || _gender == null) {
      return null;
    }
    
    final genderLower = _gender!.toLowerCase();
    final isMale = genderLower == 'male';
    final isFemale = genderLower == 'female';
    final isOther = genderLower == 'other';
    
    // Mifflin-St Jeor Equation
    // Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
    // Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161
    final baseBMR = (10 * _weight!) + (6.25 * _height!) - (5 * _age!);
    
    if (isMale) {
      return baseBMR + 5;
    } else if (isFemale) {
      return baseBMR - 161;
    } else if (isOther) {
      // For "Other", use average of male and female BMR
      final maleBMR = baseBMR + 5;
      final femaleBMR = baseBMR - 161;
      return (maleBMR + femaleBMR) / 2;
    }
    
    // Fallback: treat as female if gender doesn't match expected values
    return baseBMR - 161;
  }

  // Convert height from cm to feet and inches
  String _formatHeight(double heightInCm) {
    final totalInches = heightInCm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

  @override
  Widget build(BuildContext context) {
    // Auto-save calculated values when widget builds
    if (_bmi != null && _bmr != null) {
      final summaryData = 'BMI:${_bmi!.toStringAsFixed(1)},BMR:${_bmr!.toStringAsFixed(0)}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onAnswerChanged([summaryData]);
      });
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          
          // Subtext (optional)
          // if (question.subtext != null && question.subtext!.isNotEmpty) ...[
          //   const SizedBox(height: 8),
          //   Text(
          //     question.subtext!,
          //     style: GoogleFonts.poppins(
          //       fontSize: 16,
          //       color: Colors.grey[600],
          //       height: 1.4,
          //     ),
          //   ),
          // ],
          
          const SizedBox(height: 32),
          
          // Top section: Name, Age, BMI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    CupertinoIcons.person_alt,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and age
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName ?? 'User',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (_age != null) ...[
                        // const SizedBox(height: 4),
                        Text(
                          '$_age years',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // BMI
                if (_bmi != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'BMI: ',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_bmi!.toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Height and Weight cards
          Row(
            children: [
              // Height card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.straighten,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _height != null ? _formatHeight(_height!) : '--',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Height',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Weight card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.monitor_weight_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _weight != null ? '${_weight!.toStringAsFixed(0)} Kg' : '--',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Weight',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // BMR card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  // color: Colors.white,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Image.asset(
                      'assets/images/calorie_icon.png',
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                // BMR value
                Text(
                  _bmr != null ? '${_bmr!.toStringAsFixed(0)} Calories' : '-- Calories',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    // fontWeight: FontWeight.bold,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // BMR label
                Text(
                  'Basal Metabolic Rate',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // BMR description
                Text(
                  'Your BMR is the calories your body burns just to keep you alive. Its based on your height, weight, age and biological sex.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 20),
                // Flame icon

              ],
            ),
          ),
        ],
      ),
    );
  }
}

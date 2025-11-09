import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class PickerWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const PickerWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<PickerWidget> createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  final double itemHeight = 50.0;
  bool _isImperial = false; // false = metric (cm), true = imperial (ft-inch)

  // Conversion helpers
  // Convert cm to feet and inches
  Map<String, int> _cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return {'feet': feet, 'inches': inches};
  }

  // Convert feet and inches to cm
  double _feetInchesToCm(int feet, int inches) {
    return (feet * 12 + inches) * 2.54;
  }

  double get _heightValue {
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        final answer = widget.currentAnswer!.first;
        if (widget.question.text.toLowerCase().contains('height and weight')) {
          // Parse format: "height_170.0&weight_70.0"
          final heightMatch = RegExp(r'height_([\d.]+)').firstMatch(answer);
          if (heightMatch != null) {
            return double.parse(heightMatch.group(1)!);
          }
          // Fallback to old format for backward compatibility
          final parts = answer.split(',');
          if (parts.length == 2) {
            return double.parse(parts[0]);
          }
        }
      } catch (e) {
        // Fall through to default
      }
    }
    return 170.0; // Default height
  }

  double get _weightValue {
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        final answer = widget.currentAnswer!.first;
        if (widget.question.text.toLowerCase().contains('height and weight')) {
          // Parse format: "height_170.0&weight_70.0"
          final weightMatch = RegExp(r'weight_([\d.]+)').firstMatch(answer);
          if (weightMatch != null) {
            return double.parse(weightMatch.group(1)!);
          }
          // Fallback to old format for backward compatibility
          final parts = answer.split(',');
          if (parts.length == 2) {
            return double.parse(parts[1]);
          }
        } else {
          // Parse format: "weight_70.0" or fallback to old format
          final weightMatch = RegExp(r'weight_([\d.]+)').firstMatch(answer);
          if (weightMatch != null) {
            return double.parse(weightMatch.group(1)!);
          }
          // Fallback to old format
          return double.parse(answer);
        }
      } catch (e) {
        // Fall through to default
      }
    }
    return 70.0; // Default weight
  }

  @override
  void initState() {
    super.initState();
    // Emit default values if no current answer exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentAnswer == null || widget.currentAnswer!.isEmpty) {
        if (widget.question.text.toLowerCase().contains('height and weight')) {
          widget.onAnswerChanged(['height_${_heightValue.toStringAsFixed(1)}&weight_${_weightValue.toStringAsFixed(1)}']);
        } else if (widget.question.text.toLowerCase().contains('target weight')) {
          widget.onAnswerChanged(['weight_${_weightValue.toStringAsFixed(1)}']);
        }
      }
    });
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
          
          // const SizedBox(height: 16),
          
          // Picker container with centering
          Container(
            // color: Colors.grey[200],
            constraints: const BoxConstraints(minHeight: 500),
            child: Center(
              child: Container(
                // color: Colors.red,
                height: 400,
                child: _buildPickerContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerContent() {
    // Check if this is the combined height and weight question
    if (widget.question.text.toLowerCase().contains('height')  && widget.question.text.toLowerCase().contains('weight')) {
      return Row(
        children: [
          // Height picker
          Expanded(
            child: _buildHeightPicker(),
          ),
          // Weight picker
          Expanded(
            child: _buildWeightPicker(),
          ),
        ],
      );
    } else {
      // Single weight picker for target weight
      return _buildWeightPicker();
    }
  }

  Widget _buildHeightPicker() {
    // Generate height values based on unit system
    List<Map<String, dynamic>> heightOptions;
    int initialIndex;
    
    if (_isImperial) {
      // Imperial: 3'0" to 8'0" (36 to 96 inches)
      heightOptions = List.generate(61, (index) {
        final totalInches = 36 + index; // 3'0" to 8'0"
        final feet = totalInches ~/ 12;
        final inches = totalInches % 12;
        final cm = _feetInchesToCm(feet, inches);
        return {
          'display': '$feet\'$inches"',
          'cm': cm,
          'feet': feet,
          'inches': inches,
        };
      });
      
      // Find initial index based on current height in cm
      final currentFeetInches = _cmToFeetInches(_heightValue);
      final currentTotalInches = currentFeetInches['feet']! * 12 + currentFeetInches['inches']!;
      // Find closest match in the options
      final targetTotalInches = currentTotalInches.clamp(36, 96);
      initialIndex = (targetTotalInches - 36).clamp(0, 60);
    } else {
      // Metric: 91.5-244 cm in 0.5 cm increments (matches 3'0" to 8'0")
      // 3'0" = 91.44 cm, 8'0" = 243.84 cm, so we use 91.5-244 cm
      final heights = List.generate(306, (index) => 91.5 + index * 0.5);
      heightOptions = heights.map((cm) => <String, dynamic>{
        'display': cm % 1 == 0 ? '${cm.toInt()}' : '${cm.toStringAsFixed(1)}',
        'cm': cm,
      }).toList();
      
      // Find closest height value
      final clampedHeight = _heightValue.clamp(91.5, 244.0);
      final closestIndex = heights.indexWhere((h) => (h - clampedHeight).abs() < 0.25);
      initialIndex = closestIndex >= 0 ? closestIndex : 157; // Default to ~170 cm if not found
    }
    
    return Column(
      children: [
        // Toggle for metric/imperial
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isImperial = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: !_isImperial ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'cm',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: !_isImperial ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isImperial = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isImperial ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'ft/in',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isImperial ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Height label
        Text(
          _isImperial ? 'Height (ft/in)' : 'Height (cm)',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        // Height picker
        Expanded(
          child: Container(
            key: ValueKey(_isImperial), // Force rebuild when unit changes
            child: CupertinoPicker(
              squeeze: 1.15,
              diameterRatio: 1.3,
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              onSelectedItemChanged: (int index) {
                final selectedOption = heightOptions[index];
                // Always store in cm
                _updateAnswerWithHeight(selectedOption['cm'] as double);
              },
              children: heightOptions.map((option) => Center(
                child: Text(
                  option['display'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightPicker() {
    final weights = List.generate(341, (index) => 30.0 + index * 0.5); // 30-100 kg
    
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        // Weight label
        Text(
          'Weight (kg)',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        //const SizedBox(height: 16),
        // Weight picker
        Expanded(
          child: CupertinoPicker(
            squeeze: 1.15,
            diameterRatio: 1.3,
            itemExtent: 50,
            scrollController: FixedExtentScrollController(
              initialItem: weights.indexOf(_weightValue.clamp(30.0, 200.0)),
            ),
            onSelectedItemChanged: (int index) {
              final newWeight = weights[index];
              _updateAnswerWithWeight(newWeight);
            },
            children: weights.map((weight) => Center(
              child: Text(
                weight % 1 == 0
                    ? '${weight.toInt()}'
                    : '${weight.toStringAsFixed(1)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _updateAnswerWithHeight(double newHeight) {
    if (widget.question.text.toLowerCase().contains('height and weight')) {
      // Combined height and weight answer in format: "height_170.0&weight_70.0"
      widget.onAnswerChanged(['height_${newHeight.toStringAsFixed(1)}&weight_${_weightValue.toStringAsFixed(1)}']);
    }
  }

  void _updateAnswerWithWeight(double newWeight) {
    if (widget.question.text.toLowerCase().contains('height and weight')) {
      // Combined height and weight answer in format: "height_170.0&weight_70.0"
      widget.onAnswerChanged(['height_${_heightValue.toStringAsFixed(1)}&weight_${newWeight.toStringAsFixed(1)}']);
    } else {
      // Single weight answer in format: "weight_70.0"
      widget.onAnswerChanged(['weight_${newWeight.toStringAsFixed(1)}']);
    }
  }
}
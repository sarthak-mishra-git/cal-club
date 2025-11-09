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
          
          const SizedBox(height: 32),
          
          // Picker container with centering
          Container(
            constraints: const BoxConstraints(minHeight: 500),
            child: Center(
              child: SizedBox(
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
    if (widget.question.text.toLowerCase().contains('height and weight')) {
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
    final heights = List.generate(241, (index) => 100.0 + index * 0.5); // 100-175.5 cm
    
    return Column(
      children: [
        // Height label
        Text(
          'Height (cm)',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        //const SizedBox(height: 16),
        // Height picker
        Expanded(
          child: Container(
            child: CupertinoPicker(
              squeeze: 1.15,
              diameterRatio: 1.3,
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: heights.indexOf(_heightValue.clamp(100.0, 220.0)),
              ),
              onSelectedItemChanged: (int index) {
                final newHeight = heights[index];
                _updateAnswerWithHeight(newHeight);
              },
              children: heights.map((height) => Center(
                child: Text(
                  height % 1 == 0
                      ? '${height.toInt()}'
                      : '${height.toStringAsFixed(1)}',
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
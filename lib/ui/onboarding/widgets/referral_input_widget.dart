import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/onboarding/onboarding_question_model.dart';

class ReferralInputWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const ReferralInputWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<ReferralInputWidget> createState() => _ReferralInputWidgetState();
}

class _ReferralInputWidgetState extends State<ReferralInputWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = (widget.currentAnswer?.isNotEmpty == true)
        ? widget.currentAnswer!.first
        : '';
    _controller = TextEditingController(text: initial.toUpperCase());
  }

  @override
  void didUpdateWidget(covariant ReferralInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newVal = (widget.currentAnswer?.isNotEmpty == true)
        ? widget.currentAnswer!.first
        : '';
    if (newVal.toUpperCase() != _controller.text) {
      _controller.value = TextEditingValue(
        text: newVal.toUpperCase(),
        selection: TextSelection.collapsed(offset: newVal.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFullLength = _controller.text.trim().length == 10;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
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

          // Input + Submit button container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFF6F7F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                      _UpperCaseTextFormatter(),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Referral code',
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      final upper = value.toUpperCase();
                      if (upper != value) {
                        // keep caret at end when forcing uppercase
                        _controller.value = TextEditingValue(
                          text: upper,
                          selection: TextSelection.collapsed(offset: upper.length),
                        );
                      }
                      setState(() {}); // update submit button color
                      // Only emit answer if not empty (empty strings will be filtered out anyway)
                      if (upper.trim().isNotEmpty) {
                        widget.onAnswerChanged([upper]);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isFullLength ? Colors.black : Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isFullLength
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final upper = newValue.text.toUpperCase();
    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}



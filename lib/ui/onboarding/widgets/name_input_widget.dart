import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class NameInputWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const NameInputWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<NameInputWidget> createState() => _NameInputWidgetState();
}

class _NameInputWidgetState extends State<NameInputWidget> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentAnswer?.isNotEmpty == true ? widget.currentAnswer!.first : '',
    );
  }

  @override
  void didUpdateWidget(NameInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.currentAnswer?.isNotEmpty == true ? widget.currentAnswer!.first : '';
    if (_controller.text != newText) {
      final cursorPosition = _controller.selection.baseOffset;
      _controller.text = newText;
      if (cursorPosition <= newText.length) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPosition),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
          
          const SizedBox(height: 32),

          // Name input field
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF6F7F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  widget.onAnswerChanged([value]);
                } else {
                  widget.onAnswerChanged([]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}




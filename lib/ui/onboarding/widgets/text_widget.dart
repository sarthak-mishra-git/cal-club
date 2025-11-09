import 'package:flutter/material.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class TextWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const TextWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
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
  void didUpdateWidget(TextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the answer actually changed and preserve cursor position
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

          // Text input field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: _getHintText(),
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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

  String _getHintText() {
    if (widget.question.text.toLowerCase().contains('referral')) {
      return 'Enter referral code';
    }
    return 'Enter your answer';
  }
}

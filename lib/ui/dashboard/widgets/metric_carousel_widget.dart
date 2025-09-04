import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'summary_carousel_card.dart';

class MetricCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>> cards;
  const MetricCarouselWidget({super.key, required this.cards});

  @override
  State<MetricCarouselWidget> createState() => _MetricCarouselWidgetState();
}

class _MetricCarouselWidgetState extends State<MetricCarouselWidget> {
  int _carouselIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cards = widget.cards;
    if (cards.isEmpty) return const SizedBox.shrink();
    if (cards.length == 1) {
      final card = cards[0];
      return SummaryCarouselCard(
        remaining: card['remaining'] ?? 0,
        goal: card['goal'] ?? 0,
        food: card['food'] ?? 0,
        exercise: card['exercise'] ?? 0,
      );
    }
    final double carouselHeight = MediaQuery.of(context).size.width * 0.7;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            onPageChanged: (i) => setState(() => _carouselIndex = i),
            itemBuilder: (context, i) {
              final card = cards[i];
              return SummaryCarouselCard(
                remaining: card['remaining'] ?? 0,
                goal: card['goal'] ?? 0,
                food: card['food'] ?? 0,
                exercise: card['exercise'] ?? 0,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            cards.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _carouselIndex ? kPrimaryColor : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

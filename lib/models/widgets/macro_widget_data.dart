import 'macro_card_data.dart';

class MacroWidgetData {
  final MacroCardData primaryCard;
  final List<MacroCardData> secondaryCards;

  MacroWidgetData({
    required this.primaryCard,
    required this.secondaryCards,
  });

  factory MacroWidgetData.fromJson(Map<String, dynamic> json) => MacroWidgetData(
        primaryCard: MacroCardData.fromJson(json['primary_card'] ?? {}),
        secondaryCards: (json['secondary_cards'] as List<dynamic>?)
                ?.map((card) => MacroCardData.fromJson(card as Map<String, dynamic>))
                .toList() ??
            [],
      );
} 
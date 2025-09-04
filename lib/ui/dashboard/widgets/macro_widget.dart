import 'package:flutter/material.dart';
import '../../../models/widgets/macro_widget_data.dart';
import '../../../models/widgets/macro_card_data.dart';

class MacroWidget extends StatelessWidget {
  final MacroWidgetData macroData;

  const MacroWidget({
    super.key,
    required this.macroData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Card
          _buildPrimaryCard(macroData.primaryCard),
          const SizedBox(height: 16),
          // Secondary Cards
          _buildSecondaryCards(macroData.secondaryCards),
        ],
      ),
    );
  }

  Widget _buildPrimaryCard(MacroCardData card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[400]!.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Progress Circle with Icon
          SizedBox(
            width: 75,
            height: 75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 75,
                  height: 75,
                  child: CircularProgressIndicator(
                    value: card.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(card.colorValue),
                    strokeWidth: 8,
                  ),
                ),
                // Icon
                Icon(
                  _getIconData(card.icon),
                  color: card.colorValue,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatPrimaryValue(card.value),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  card.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCards(List<MacroCardData> cards) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      // height: 120,
      child: cards.length > 3
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < cards.length - 1 ? 10 : 0,
                    left: index > 0 ? 10 : 0,
                  ),
                  child: _buildSecondaryCard(cards[index]),
                );
              },
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: cards.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                return _buildSecondaryCard(card);
              }).toList(),
            ),
    );
  }

  Widget _buildSecondaryCard(MacroCardData card) {
    return Container(
      width: 100,
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.grey[400]!.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Circle with Icon
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: card.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(card.colorValue),
                    strokeWidth: 6,
                  ),
                ),
                // Icon
                Icon(
                  _getIconData(card.icon),
                  color: card.colorValue,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Text content
          Text(
            _formatMacroValue(card.value),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '${card.text} left',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'fire':
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'lightning':
        return Icons.bolt;
      case 'wheat':
        return Icons.grain;
      case 'water':
      case 'drop':
        return Icons.water_drop_outlined;
      case 'protein':
        return Icons.fitness_center;
      case 'carbs':
        return Icons.grain;
      case 'fats':
        return Icons.water_drop;
      default:
        return Icons.circle;
    }
  }
  
  String _formatMacroValue(double value) {
    if (value == value.toInt()) {
      return '${value.toInt()}g';
    } else {
      return '${value.toStringAsFixed(1)}g';
    }
  }
  
  String _formatPrimaryValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }
} 
import 'package:flutter/material.dart';
import '../../../services/health_service.dart';

class HealthStatusIndicator extends StatelessWidget {
  final HealthConnectionStatus status;
  final HealthData? healthData;
  final VoidCallback? onTap;

  const HealthStatusIndicator({
    super.key,
    required this.status,
    this.healthData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getBorderColor()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              color: _getIconColor(),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              _getText(),
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case HealthConnectionStatus.connected:
        return healthData?.hasData == true 
            ? Colors.green[100]! 
            : Colors.orange[100]!;
      case HealthConnectionStatus.notConnected:
        return Colors.orange[100]!;
      case HealthConnectionStatus.notAvailable:
        return Color(0xFFF6F7F9)!;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case HealthConnectionStatus.connected:
        return healthData?.hasData == true 
            ? Colors.green[300]! 
            : Colors.orange[300]!;
      case HealthConnectionStatus.notConnected:
        return Colors.orange[300]!;
      case HealthConnectionStatus.notAvailable:
        return Colors.grey[300]!;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case HealthConnectionStatus.connected:
        return healthData?.hasData == true 
            ? Icons.health_and_safety 
            : Icons.health_and_safety_outlined;
      case HealthConnectionStatus.notConnected:
        return Icons.health_and_safety_outlined;
      case HealthConnectionStatus.notAvailable:
        return Icons.health_and_safety_outlined;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case HealthConnectionStatus.connected:
        return healthData?.hasData == true 
            ? Colors.green[700]! 
            : Colors.orange[700]!;
      case HealthConnectionStatus.notConnected:
        return Colors.orange[700]!;
      case HealthConnectionStatus.notAvailable:
        return Colors.grey[600]!;
    }
  }

  String _getText() {
    switch (status) {
      case HealthConnectionStatus.connected:
        if (healthData?.hasData == true) {
          return '${healthData!.totalCalories.toStringAsFixed(0)}';
        } else {
          return 'No Data';
        }
      case HealthConnectionStatus.notConnected:
        return 'Connect';
      case HealthConnectionStatus.notAvailable:
        return 'N/A';
    }
  }

  Color _getTextColor() {
    switch (status) {
      case HealthConnectionStatus.connected:
        return healthData?.hasData == true 
            ? Colors.green[700]! 
            : Colors.orange[700]!;
      case HealthConnectionStatus.notConnected:
        return Colors.orange[700]!;
      case HealthConnectionStatus.notAvailable:
        return Colors.grey[600]!;
    }
  }
}

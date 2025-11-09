import 'package:health/health.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class HealthService {
  static final Health _health = Health();
  static const _hasRequestedKey = 'has_requested_health_permission';
  
  // Check if HealthKit is available (iOS only)
  static Future<bool> isHealthAvailable() async {
    if (!Platform.isIOS) return false;
    
    // For now, we'll assume HealthKit is available on iOS
    // The real check will happen when we try to get permissions
    return true;
  }
  
  // Request health permissions
  static Future<void> requestHealthPermissions() async {
    if (!Platform.isIOS) return;
    
    final types = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED,
    ];
    
    await _health.requestAuthorization(
      types,
      permissions: [HealthDataAccess.READ, HealthDataAccess.READ],
    );
    
    // Mark that user has seen the permission dialog
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRequestedKey, true);
  }
  
  // Get daily calories data for a specific date
  static Future<HealthData?> getDailyCaloriesData(DateTime date) async {
    if (!Platform.isIOS) return null;
    
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Try to fetch data - if no permissions, this will return empty
      final activeEnergyData = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: endOfDay,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      
      final basalEnergyData = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: endOfDay,
        types: [HealthDataType.BASAL_ENERGY_BURNED],
      );
      
      double activeCalories = 0.0;
      double basalCalories = 0.0;
      
      for (var sample in activeEnergyData) {
        if (sample.value is NumericHealthValue) {
          activeCalories += (sample.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      
      for (var sample in basalEnergyData) {
        if (sample.value is NumericHealthValue) {
          basalCalories += (sample.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      
      return HealthData(
        activeCalories: activeCalories,
        basalCalories: basalCalories,
        totalCalories: activeCalories + basalCalories,
        date: date,
        hasData: activeCalories > 0 || basalCalories > 0,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Get health connection status
  static Future<HealthConnectionStatus> getConnectionStatus() async {
    if (!Platform.isIOS) return HealthConnectionStatus.notAvailable;
    
    // Simple: Has user tapped "Connect" before?
    final prefs = await SharedPreferences.getInstance();
    final hasRequested = prefs.getBool(_hasRequestedKey) ?? false;
    
    if (hasRequested) {
      // User has tapped connect - show as connected (even if 0 data)
      return HealthConnectionStatus.connected;
    } else {
      // Fresh user - show connect button
      return HealthConnectionStatus.notConnected;
    }
  }
}

// Health data model
class HealthData {
  final double activeCalories;
  final double basalCalories;
  final double totalCalories;
  final DateTime date;
  final bool hasData;
  
  HealthData({
    required this.activeCalories,
    required this.basalCalories,
    required this.totalCalories,
    required this.date,
    required this.hasData,
  });
  
  @override
  String toString() {
    return 'HealthData(active: ${activeCalories.toStringAsFixed(1)}, basal: ${basalCalories.toStringAsFixed(1)}, total: ${totalCalories.toStringAsFixed(1)})';
  }
}

// Health connection status enum
enum HealthConnectionStatus {
  notAvailable,
  notConnected,
  connected,
}

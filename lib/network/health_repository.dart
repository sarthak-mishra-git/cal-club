import '../services/health_service.dart';

class HealthRepository {
  // Get health data for a specific date
  Future<HealthData?> fetchHealthData(DateTime date) async {
    try {
      return await HealthService.getDailyCaloriesData(date);
    } catch (e) {
      print('Error in HealthRepository.fetchHealthData: $e');
      return null;
    }
  }
  
  // Check health connection status
  Future<HealthConnectionStatus> getConnectionStatus() async {
    try {
      return await HealthService.getConnectionStatus();
    } catch (e) {
      print('Error in HealthRepository.getConnectionStatus: $e');
      return HealthConnectionStatus.notAvailable;
    }
  }
  
  // Request health permissions
  Future<void> requestHealthPermissions() async {
    try {
      await HealthService.requestHealthPermissions();
    } catch (e) {
      print('Error in HealthRepository.requestHealthPermissions: $e');
    }
  }
  
}

import 'package:cal_track/services/navigation_service.dart';

class NavigationUtils {
  static void handleFooterNavigation(String action) {
    // Handle navigation actions
    print('Footer tapped: $action');
    switch (action) {
      case 'navigate_home':
        // Navigate to dashboard (home screen)
        NavigationService.navigateToAndClear('/dashboard');
        break;
      case 'navigate_settings':
        // Navigate to settings screen
        // TODO: Implement settings screen route when available
        NavigationService.navigateToAndClear('/profile');
        break;
        print('Settings navigation not yet implemented');
        break;
      case 'navigate_progress':
        // Navigate to progress screen
        NavigationService.navigateToAndClear('/progress');
        break;
      default:
        print('Unknown action: $action');
    }
  }
}

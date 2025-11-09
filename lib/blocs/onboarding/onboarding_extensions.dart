import 'onboarding_state.dart';

extension OnboardingStateExtensions on OnboardingState {
  /// Helper to get the user's name from the onboarding state
  String? get userName {
    if (this is OnboardingLoaded) {
      return (this as OnboardingLoaded).userName;
    }
    return null;
  }
  
  /// Helper to check if the user has entered their name
  bool get hasUserName {
    final name = userName;
    return name != null && name.isNotEmpty;
  }
}




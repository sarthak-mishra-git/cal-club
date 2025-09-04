import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> navigateToReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigator!.pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
  }

  static Future<T?> navigateToAndClear<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  static void goBack<T extends Object?>([T? result]) {
    return navigator!.pop<T>(result);
  }

  static void navigateToLogin() {
    navigateToAndClear('/login');
  }

  static void navigateToDashboard() {
    navigateToAndClear('/dashboard');
  }
} 
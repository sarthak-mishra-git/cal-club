import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'network/dashboard_repository.dart';
import 'ui/dashboard/screens/dashboard_screen.dart';
import 'ui/auth/screens/login_screen.dart';
import 'services/navigation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc()..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (_) => DashboardBloc(repository: DashboardRepository()),
        ),
      ],
              child: MaterialApp(
          title: 'Cal Club',
          navigatorKey: NavigationService.navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5F5DC), // Light beige
          brightness: Brightness.light,
        ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const DashboardScreen();
        } else if (state is OtpSent) {
          // This will be handled by the login screen navigation
          return const LoginScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

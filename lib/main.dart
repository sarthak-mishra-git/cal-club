import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/onboarding/onboarding_bloc.dart';
import 'blocs/subscription/subscription_bloc.dart';
import 'blocs/progress/progress_bloc.dart';
import 'network/dashboard_repository.dart';
import 'network/health_repository.dart';
import 'network/onboarding_repository.dart';
import 'network/subscription_repository.dart';
import 'network/progress_repository.dart';
import 'ui/dashboard/screens/dashboard_screen.dart';
import 'ui/dashboard/screens/profile_screen.dart';
import 'ui/auth/screens/login_screen.dart';
import 'ui/auth/screens/welcome_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/subscription/screens/subscription_plans_screen.dart';
import 'ui/progress/screens/progress_screen.dart';
import 'services/navigation_service.dart';
import 'services/payment_service.dart';

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
          create: (_) => DashboardBloc(
            repository: DashboardRepository(),
            healthRepository: HealthRepository(),
          ),
        ),
        BlocProvider(
          create: (_) => OnboardingBloc(repository: OnboardingRepository()),
        ),
        BlocProvider(
          create: (_) => SubscriptionBloc(
            repository: SubscriptionRepository(),
            paymentService: PaymentService()..init(),
          ),
        ),
        BlocProvider(
          create: (_) => ProgressBloc(repository: ProgressRepository()),
        ),
      ],
              child: MaterialApp(
          title: 'Cal Club',
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
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
          '/welcome': (context) => const WelcomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/subscriptions': (context) => const SubscriptionPlansScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/profile': (context) => const ProfileScreen(),
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
        } else if (state is GuestAuthenticated) {
          return const DashboardScreen();
        } else if (state is OtpSent) {
          // This will be handled by the login screen navigation
          return const LoginScreen();
        } else {
          // Show welcome screen on app launch when logged out
          return const WelcomeScreen();
        }
      },
    );
  }
}

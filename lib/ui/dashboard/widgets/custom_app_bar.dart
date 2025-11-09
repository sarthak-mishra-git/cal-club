import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/widgets/app_bar_data.dart';
import '../../../blocs/dashboard/dashboard_bloc.dart';
import '../../../blocs/dashboard/dashboard_state.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import 'health_status_indicator.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarData? appBarData;
  final VoidCallback? onStreakTap;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    this.appBarData,
    this.onStreakTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // scrolledUnderElevation: 1,
      backgroundColor: Colors.black, // Light beige
      // elevation: 1,
      title: Row(
        children: [
          // App logo/name
          Row(
            children: [
              // const SizedBox(width: 4),
              Image.asset(
                'assets/images/dashboard_icon.png',
                width: 36,
                height: 36,
              ),
              const SizedBox(width: 8),
              Text(
                appBarData?.title ?? 'Cal Club',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Calories display - Show health data if available, otherwise show backend data
          if (appBarData != null && onStreakTap != null)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is GuestAuthenticated) {
                  // Guest mode - show backend data only
                  return GestureDetector(
                    onTap: onStreakTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        // color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/calorie_icon.png',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${appBarData!.streak}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Authenticated users - show health data if available
                return BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, dashboardState) {

                    if (dashboardState is DashboardLoaded && appBarData?.streak != null) {
                      // Show health data
                    //   return HealthStatusIndicator(
                    //     status: dashboardState.healthConnectionStatus,
                    //     healthData: dashboardState.healthData,
                    //     onTap: onCaloriesTap,
                    //   );
                    // } else {
                      // Fallback to backend data
                      return GestureDetector(
                        onTap: onStreakTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            // color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/calorie_icon.png',
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${appBarData!.streak}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          
          const SizedBox(width: 12),
          
          // Profile button COMMENTED FOR NOW MIGHT ENABLE LATER
          if (onProfileTap != null)
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(20),
                  // border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 
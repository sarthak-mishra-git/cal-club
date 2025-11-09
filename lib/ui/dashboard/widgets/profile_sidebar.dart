import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/dashboard/dashboard_bloc.dart';
import '../../../blocs/dashboard/dashboard_event.dart';
import '../../../blocs/dashboard/dashboard_state.dart';
import '../../../constants.dart';
import '../../../network/token_storage.dart';
import '../../../services/health_service.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AccountDeleted) {
          // Show success dialog after navigation to login screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Account Deleted'),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          });
        } else if (state is AuthError) {
          // Show error dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355), // Dark beige
            ),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: const Color(0xFF8B7355), // Dark beige
                  ),
                ),
                const SizedBox(height: 16),
                
                // User Info
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      return Column(
                        children: [
                          Text(
                            'Profile',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.user.phoneNumber ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    } else if (state is GuestAuthenticated) {
                      return const Column(
                        children: [
                          Text(
                            'Guest User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Limited Access',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Column(
                        children: [
                          Text(
                            'User Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Divider(),
                
                // Complete Onboarding - HIDDEN
                ListTile(
                  leading: const Icon(Icons.quiz, color: Color(0xFF8B7355)),
                  title: const Text('Complete Onboarding'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/onboarding');
                  },
                ),
                
                // Progress
                ListTile(
                  leading: const Icon(Icons.trending_up, color: Color(0xFF8B7355)),
                  title: const Text('Progress'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/progress');
                  },
                ),
                
                // Privacy Policy
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Color(0xFF8B7355)),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    Navigator.pop(context);
                    _launchUrl(kPrivacyPolicyUrl);
                  },
                ),
                
                // Terms of Service
                ListTile(
                  leading: const Icon(Icons.description, color: Color(0xFF8B7355)),
                  title: const Text('Terms of Service'),
                  onTap: () {
                    Navigator.pop(context);
                    _launchUrl(kTermsOfServiceUrl);
                  },
                ),
                
                // Apple Health Integration - Only for authenticated users
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is GuestAuthenticated) {
                      return const SizedBox.shrink(); // Hide in guest mode
                    }
                    
                    return BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, dashboardState) {
                        return ListTile(
                          leading: Icon(
                            Icons.health_and_safety,
                            color: _getHealthIconColor(dashboardState),
                          ),
                          title: Text(
                            'Apple Health',
                            style: TextStyle(
                              color: _getHealthTextColor(dashboardState),
                            ),
                          ),
                          subtitle: Text(
                            _getHealthSubtitle(dashboardState),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getHealthSubtitleColor(dashboardState),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _handleAppleHealthTap(context, dashboardState);
                          },
                        );
                      },
                    );
                  },
                ),
                
                const Divider(),
                
                // Subscriptions
                ListTile(
                  leading: const Icon(Icons.subscriptions, color: Colors.blue),
                  title: const Text('Subscriptions'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscriptions');
                  },
                ),
                
                const Divider(),
                
                // Conditional menu items based on auth state
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is GuestAuthenticated) {
                      // Guest mode - show exit guest mode option
                      return ListTile(
                        leading: const Icon(Icons.exit_to_app, color: Colors.red),
                        title: const Text(
                          'Exit Guest Mode',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showExitGuestDialog(context);
                        },
                      );
                    } else if (state is Authenticated) {
                      // Authenticated user - show delete account and logout
                      return Column(
                        children: [
                          // Delete Account
                          ListTile(
                            leading: const Icon(Icons.delete_forever, color: Colors.red),
                            title: const Text(
                              'Delete Account',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showDeleteAccountDialog(context);
                            },
                          ),
                          const Divider(),
                          // Logout
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showLogoutDialog(context);
                            },
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
          
          // App Version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Cal Club v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                
                // Get the phone number from current auth state
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated && authState.user.phoneNumber != null) {
                  context.read<AuthBloc>().add(DeleteAccountRequested(phoneNumber: authState.user.phoneNumber!));
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExitGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Guest Mode'),
          content: const Text('Are you sure you want to exit guest mode? You will be taken to the login screen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(ExitGuestMode());
              },
              child: const Text(
                'Exit Guest Mode',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Apple Health helper methods
  Color _getHealthIconColor(DashboardState state) {
    if (state is DashboardLoaded) {
      switch (state.healthConnectionStatus) {
        case HealthConnectionStatus.connected:
          return Colors.green;
        case HealthConnectionStatus.notConnected:
          return Colors.orange;
        case HealthConnectionStatus.notAvailable:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  Color _getHealthTextColor(DashboardState state) {
    if (state is DashboardLoaded) {
      switch (state.healthConnectionStatus) {
        case HealthConnectionStatus.connected:
          return Colors.green[700]!;
        case HealthConnectionStatus.notConnected:
          return Colors.orange[700]!;
        case HealthConnectionStatus.notAvailable:
          return Colors.grey[600]!;
      }
    }
    return Colors.grey[600]!;
  }

  String _getHealthSubtitle(DashboardState state) {
    if (state is DashboardLoaded) {
      switch (state.healthConnectionStatus) {
        case HealthConnectionStatus.connected:
          return 'Connected - Tap to refresh';
        case HealthConnectionStatus.notConnected:
          return 'Tap to connect';
        case HealthConnectionStatus.notAvailable:
          return 'Not available on this device';
      }
    }
    return 'Loading...';
  }

  Color _getHealthSubtitleColor(DashboardState state) {
    if (state is DashboardLoaded) {
      switch (state.healthConnectionStatus) {
        case HealthConnectionStatus.connected:
          return Colors.green[600]!;
        case HealthConnectionStatus.notConnected:
          return Colors.orange[600]!;
        case HealthConnectionStatus.notAvailable:
          return Colors.grey[500]!;
      }
    }
    return Colors.grey[500]!;
  }

  void _handleAppleHealthTap(BuildContext context, DashboardState state) {
    if (state is DashboardLoaded) {
      switch (state.healthConnectionStatus) {
        case HealthConnectionStatus.connected:
          // Show connected status and refresh option
          _showHealthConnectedDialog(context);
          break;
        case HealthConnectionStatus.notConnected:
          // Request permissions
          print('Tapping Apple Health - requesting permissions...');
          context.read<DashboardBloc>().add(const ConnectToAppleHealth());
          // Show a snackbar to provide user feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Requesting Apple Health permissions...'),
              duration: Duration(seconds: 2),
            ),
          );
          break;
        case HealthConnectionStatus.notAvailable:
          // Show not available message
          _showHealthNotAvailableDialog(context);
          break;
      }
    }
  }

  void _showHealthConnectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Apple Health Connected'),
              ),
            ],
          ),
          content: const Text(
            'Your app is connected to Apple Health. You can see your daily calories burned from your Apple Watch in the dashboard.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Refresh health data
                final now = DateTime.now();
                final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                context.read<DashboardBloc>().add(FetchHealthData(date: dateString));
              },
              child: const Text('Refresh Data'),
            ),
          ],
        );
      },
    );
  }

  void _showHealthNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Apple Health Not Available'),
              ),
            ],
          ),
          content: const Text(
            'Apple Health is only available on iOS devices. This feature is not supported on your current device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
} 
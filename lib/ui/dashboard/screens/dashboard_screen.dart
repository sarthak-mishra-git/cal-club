import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cal_track/blocs/dashboard/dashboard_bloc.dart';
import 'package:cal_track/blocs/dashboard/dashboard_event.dart';
import 'package:cal_track/blocs/dashboard/dashboard_state.dart';
import 'package:cal_track/ui/dashboard/dashboard_widget_builder.dart';
import 'package:cal_track/ui/dashboard/widgets/custom_app_bar.dart';
import 'package:cal_track/ui/dashboard/widgets/week_view_widget.dart';
import 'package:cal_track/ui/dashboard/widgets/footer_widget.dart';
import 'package:cal_track/ui/dashboard/widgets/calories_popup.dart';
import 'package:cal_track/ui/dashboard/widgets/day_selector_widget.dart';
import 'package:cal_track/ui/dashboard/screens/camera_screen.dart';
import 'package:cal_track/models/widgets/day_selector_data.dart';
import 'package:cal_track/services/image_service.dart';
import 'package:cal_track/services/image_upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cal_track/utils/utils.dart';
import 'package:cal_track/blocs/food_analysis/food_analysis_bloc.dart';
import 'package:cal_track/blocs/food_analysis/food_analysis_event.dart';
import 'package:cal_track/blocs/auth/auth_bloc.dart';
import 'package:cal_track/blocs/auth/auth_state.dart';
import 'package:cal_track/blocs/auth/auth_event.dart';
import 'package:cal_track/services/mock_data_service.dart';
import 'package:cal_track/models/screens/dashboard_screen_model.dart';
import 'package:cal_track/models/widgets/app_bar_data.dart';
import 'package:cal_track/models/widgets/week_view_data.dart';
import 'package:cal_track/models/widgets/footer_data.dart';
import 'package:cal_track/network/food_analysis_repository.dart';
import 'package:cal_track/network/token_storage.dart';
import 'package:cal_track/ui/meal_details/screens/meal_details_screen.dart';
import 'package:cal_track/models/meal_details/meal_details_model.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedDate; // Track selected date for guest mode

  @override
  void initState() {
    super.initState();
    // Initialize selected date to today
    final now = DateTime.now();
    _selectedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    context.read<DashboardBloc>().add(FetchDashboardData());
  }

  void _handleDayTap(int dayIndex) {
    print('Day $dayIndex tapped');

    // Check if user is in guest mode
    final authState = context.read<AuthBloc>().state;
    final selectedDate = _getDateForDayIndex(dayIndex);
    
    if (authState is GuestAuthenticated) {
      // In guest mode, update the selected date and rebuild
      print('Guest mode: Day selection updated for date $selectedDate');
      setState(() {
        _selectedDate = selectedDate;
      });
      return;
    }

    // For authenticated users, get the selected date and fetch data for that date
    setState(() {
      _selectedDate = selectedDate;
    });
    context.read<DashboardBloc>().add(FetchDashboardData(date: selectedDate));
  }

  void _handlePrevDay() {
    // Get the current day selector data from state
    final dashboardState = context.read<DashboardBloc>().state;
    if (dashboardState is! DashboardLoaded) return;
    
    final currentDate = DateTime.parse(dashboardState.daySelectorData.date);
    final prevDate = currentDate.subtract(const Duration(days: 1));
    final prevDateString = '${prevDate.year}-${prevDate.month.toString().padLeft(2, '0')}-${prevDate.day.toString().padLeft(2, '0')}';
    
    // Check if user is in guest mode
    final authState = context.read<AuthBloc>().state;
    if (authState is GuestAuthenticated) {
      setState(() {
        _selectedDate = prevDateString;
      });
      return;
    }
    
    setState(() {
      _selectedDate = prevDateString;
    });
    context.read<DashboardBloc>().add(FetchDashboardData(date: prevDateString));
  }

  void _handleNextDay() {
    // Get the current day selector data from state
    final dashboardState = context.read<DashboardBloc>().state;
    if (dashboardState is! DashboardLoaded) return;
    
    final currentDate = DateTime.parse(dashboardState.daySelectorData.date);
    final nextDate = currentDate.add(const Duration(days: 1));
    final nextDateString = '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';
    
    // Check if user is in guest mode
    final authState = context.read<AuthBloc>().state;
    if (authState is GuestAuthenticated) {
      setState(() {
        _selectedDate = nextDateString;
      });
      return;
    }
    
    setState(() {
      _selectedDate = nextDateString;
    });
    context.read<DashboardBloc>().add(FetchDashboardData(date: nextDateString));
  }

  String _getDateForDayIndex(int dayIndex) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final selectedDate = startOfWeek.add(Duration(days: dayIndex));
    return '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
  }

  void _handleCaloriesTap() {
    print('Calories tapped');
    // Check if user is in guest mode
    final authState = context.read<AuthBloc>().state;
    if (authState is GuestAuthenticated) {
      _showGuestModeDialog();
      return;
    }

    _showCaloriesPopup();
  }

  void _handleStreakTap() {
    print('streak tapped');

    // Check if user is in guest mode
    final authState = context.read<AuthBloc>().state;
    if (authState is GuestAuthenticated) {
      _showGuestModeDialog();
      return;
    }
  }

  void _showGuestModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guest Mode'),
        content: const Text(
          'Apple Health integration is not available in guest mode. Please create an account to access your health data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCaloriesPopup() {
    final dashboardState = context.read<DashboardBloc>().state;
    if (dashboardState is DashboardLoaded) {
      final selectedDate = _selectedDate != null
          ? DateTime.parse(_selectedDate!)
          : DateTime.now();

      showDialog(
        context: context,
        builder: (context) => CaloriesPopup(
          healthData: dashboardState.healthData,
          selectedDate: selectedDate,
          onConnectHealth: () {
            Navigator.of(context).pop();
            context.read<DashboardBloc>().add(const ConnectToAppleHealth());
          },
          onRefresh: () {
            Navigator.of(context).pop();
            final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
            context.read<DashboardBloc>().add(FetchHealthData(date: dateString));
          },
        ),
      );
    }
  }

  void _showProfileSidebar(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  // Mock method removed - we'll use real API data instead

  Future<void> _showImageSourceDialog(BuildContext context) async {
    // Check if user is in guest mode
    final authState = context.read<AuthBloc>().state;
    if (authState is GuestAuthenticated) {
      _showLoginRequiredDialog(context);
      return;
    }

    // Check camera permission before navigating to camera screen
    final hasPermission = await CameraScreen.hasCameraPermission();
    if (!hasPermission) {
      final granted = await CameraScreen.requestCameraPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Navigate to camera screen
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );

    if (result != null && mounted) {
      await _processImageResult(result);
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to continue'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(ExitGuestMode());
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _processImageResult(Map<String, dynamic> result) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String? imageUrl;

      // Handle different result types
      if (result['imagePath'] != null) {
        // File path from gallery
        final imageFile = File(result['imagePath']);
        imageUrl = await ImageUploadService.uploadImage(imageFile);
      } else if (result['imageBytes'] != null) {
        // Bytes from camera
        imageUrl = await ImageUploadService.uploadImageBytes(result['imageBytes']);
      }

      // Close loading dialog
      Navigator.of(context).pop();

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Navigate to meal details screen - FoodAnalysisBloc will handle the data
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => FoodAnalysisBloc(
                repository: FoodAnalysisRepository(),
              )..add(AnalyzeFoodImage(imageUrl: imageUrl!)),
              child: const MealDetailsScreen(), // No mealDetails needed - will get from bloc
            ),
          ),
        );

        // Refresh dashboard data if returning from meal details
        if (result == 'refresh') {
          context.read<DashboardBloc>().add(FetchDashboardData());
        }
      } else {
        // Show error if upload failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is Unauthenticated) {
            // User has been logged out, navigate to login
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
            body: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
            // Check if user is in guest mode and use mock data
            if (authState is GuestAuthenticated) {
              final mockData = MockDataService.getGuestDashboardData(date: _selectedDate);
              return _buildDashboardContent(
                mockData.appBarData,
                mockData.weekViewData,
                mockData.daySelectorData,
                mockData.widgets,
                mockData.footerData,
                mockData.showFloatingActionButton,
                null, // No health data for guest mode
              );
            }

            // For authenticated users, use the normal dashboard bloc
            return BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DashboardLoaded) {
                  return _buildDashboardContent(
                    state.appBarData,
                    state.weekViewData,
                    state.daySelectorData,
                    state.widgets,
                    state.footerData,
                    state.showFloatingActionButton,
                    state.healthData != null ? {
                      'totalCalories': state.healthData!.totalCalories,
                      'activeCalories': state.healthData!.activeCalories,
                      'basalCalories': state.healthData!.basalCalories,
                    } : null,
                  );
                } else if (state is DashboardError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            );
                        },
                      )
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    AppBarData appBarData,
    WeekViewData weekViewData,
    DaySelectorData daySelectorData,
    List<DashboardWidgetConfig> widgets,
    List<FooterItemData> footerData,
    bool showFloatingActionButton,
    Map<String, dynamic>? healthData,
  ) {
    return Stack(
      children: [
        Column(
          children: [
            // Fixed header with app bar and week view
            CustomAppBar(
              appBarData: appBarData,
              onStreakTap: _handleStreakTap,
              onProfileTap: () => _showProfileSidebar(context),
            ),
            // WeekViewWidget(
            //   weekViewData: weekViewData,
            //   onDayTap: _handleDayTap,
            // ),
            DaySelectorWidget(
              daySelectorData: daySelectorData,
              onPrevTap: _handlePrevDay,
              onNextTap: _handleNextDay,
            ),
            // Scrollable content below
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: widgets.length,
                  itemBuilder: (context, index) {
                    final widgetConfig = widgets[index];
                    return DashboardWidgetBuilder(
                      widgetType: widgetConfig.widgetType,
                      widgetData: widgetConfig.widgetData,
                      healthData: healthData,
                      onCalorieTap: _handleCaloriesTap
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        // Footer positioned above the content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: FooterWidget(
            footerItems: footerData,
            onTap: NavigationUtils.handleFooterNavigation,
          ),
        ),
        // Floating Action Button positioned above footer
        if (showFloatingActionButton)
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                print('FAB tapped - Upload picture');
                await _showImageSourceDialog(context);
              },
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cal_track/blocs/dashboard/dashboard_bloc.dart';
import 'package:cal_track/blocs/dashboard/dashboard_event.dart';
import 'package:cal_track/blocs/dashboard/dashboard_state.dart';
import 'package:cal_track/ui/dashboard/dashboard_widget_builder.dart';
import 'package:cal_track/ui/dashboard/widgets/custom_app_bar.dart';
import 'package:cal_track/ui/dashboard/widgets/week_view_widget.dart';
import 'package:cal_track/ui/dashboard/widgets/footer_widget.dart';
import 'package:cal_track/ui/dashboard/widgets/image_source_dialog.dart';
import 'package:cal_track/ui/dashboard/widgets/profile_sidebar.dart';
import 'package:cal_track/ui/dashboard/screens/camera_screen.dart';
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
import 'package:cal_track/network/food_analysis_repository.dart';
import 'package:cal_track/network/token_storage.dart';
import 'package:cal_track/ui/meal_details/screens/meal_details_screen.dart';
import 'package:cal_track/models/meal_details/meal_details_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchDashboardData());
  }

  void _handleDayTap(int dayIndex) {
    print('Day $dayIndex tapped');
    
    // Get the selected date and fetch data for that date
    final selectedDate = _getDateForDayIndex(dayIndex);
    context.read<DashboardBloc>().add(FetchDashboardData(date: selectedDate));
  }
  
  String _getDateForDayIndex(int dayIndex) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final selectedDate = startOfWeek.add(Duration(days: dayIndex));
    return '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
  }

  void _handleCaloriesTap() {
    print('Calories tapped');
    // TODO: Handle calories tap
  }

  void _showProfileSidebar(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: double.infinity,
            color: Colors.transparent,
            child: const ProfileSidebar(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }
  
  // Mock method removed - we'll use real API data instead

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const ImageSourceDialog();
      },
    );

    if (result != null && mounted) {
      await _handleImageSourceSelection(result);
    }
  }

  Future<void> _handleImageSourceSelection(String source) async {
    try {
      if (source == 'camera') {
        // Navigate to camera screen for photo capture
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CameraScreen(),
          ),
        );

        if (result != null && mounted) {
          _processImageResult(result);
        }
      } else if (source == 'gallery') {
        // Handle gallery selection
        final result = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (result != null && mounted) {
          _processImageResult({'imagePath': result.path});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          // drawer: const ProfileSidebar(),
          body: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DashboardLoaded) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        // Fixed header with app bar and week view
                        CustomAppBar(
                          appBarData: state.appBarData,
                          onCaloriesTap: _handleCaloriesTap,
                          onProfileTap: () => _showProfileSidebar(context),
                        ),
                        WeekViewWidget(
                          weekViewData: state.weekViewData,
                          onDayTap: _handleDayTap,
                        ),
                        // Scrollable content below
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: state.widgets.length,
                              itemBuilder: (context, index) {
                                final widgetConfig = state.widgets[index];
                                return DashboardWidgetBuilder(
                                  widgetType: widgetConfig.widgetType,
                                  widgetData: widgetConfig.widgetData,
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
                        footerItems: state.footerData,
                        onTap: NavigationUtils.handleFooterNavigation,
                      ),
                    ),
                    // Floating Action Button positioned above footer
                    if (state.showFloatingActionButton)
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
              } else if (state is DashboardError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

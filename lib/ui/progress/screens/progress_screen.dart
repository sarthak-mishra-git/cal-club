import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../blocs/progress/progress_bloc.dart';
import '../../../blocs/progress/progress_event.dart';
import '../../../blocs/progress/progress_state.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../dashboard/widgets/footer_widget.dart';
import '../../../utils/utils.dart';
import '../../../models/screens/progress_screen_model.dart';
import '../../../models/progress/weight_progress_model.dart';
import '../../../models/progress/daily_goal_model.dart';
import '../../../network/onboarding_repository.dart';
import '../../../network/progress_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isAdjustingGoals = false;
  bool _isUpdatingGoals = false;
  double _caloriesSlider = 0.0;
  double _proteinSlider = 0.0;
  double _carbsSlider = 0.0;
  double _fatsSlider = 0.0;
  final OnboardingRepository _onboardingRepository = OnboardingRepository();
  final ProgressRepository _progressRepository = ProgressRepository();

  @override
  void initState() {
    super.initState();
    context.read<ProgressBloc>().add(const FetchProgressData());
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
          // appBar: AppBar(
          //   toolbarHeight: 70,
          //   backgroundColor: Colors.black,
          //   elevation: 0,
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          //     onPressed: () => Navigator.of(context).pop(),
          //   ),
          //   title: Text(
          //     'Your Progress',
          //     style: GoogleFonts.poppins(
          //       fontWeight: FontWeight.w600,
          //       color: Colors.white,
          //       fontSize: 22,
          //     ),
          //   ),
          //   centerTitle: false,
          // ),
          body: BlocConsumer<ProgressBloc, ProgressState>(
            listener: (context, state) {
              if (state is ProgressError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProgressLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is ProgressLoaded) {
                return _buildProgressContent(state.progressScreenModel);
              }

              if (state is ProgressError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProgressBloc>().add(const FetchProgressData());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(
                child: Text('Something went wrong'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressContent(ProgressScreenModel progressScreenModel) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.only(
          //   topLeft: Radius.circular(24),
          //   topRight: Radius.circular(24),
          // ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  if (progressScreenModel.header != null)
                    Text(
                      "Goal: " + progressScreenModel.header!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  if (progressScreenModel.header != null) const SizedBox(height: 32),

                  // Weight Progress Section
                  if (progressScreenModel.weightProgress != null)
                    _buildWeightProgressSection(progressScreenModel.weightProgress!),
                  if (progressScreenModel.weightProgress != null) const SizedBox(height: 20),

                  _buildCheckInSection(
                    progressScreenModel.lastCheckedIn ?? '',
                    progressScreenModel.nextCheckIn ?? '',
                  ),

                  // Daily Goal Section
                  if (progressScreenModel.dailyGoal != null) const SizedBox(height: 20),
                  if (progressScreenModel.dailyGoal != null)
                    _buildDailyGoalSection(progressScreenModel.dailyGoal!),

                  // Check-in Dates Section

                  const SizedBox(height: 100), // Space for footer
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FooterWidget(
                footerItems: progressScreenModel.footerData,
                onTap: NavigationUtils.handleFooterNavigation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightProgressSection(WeightProgress weightProgress) {
    // Handle null values
    final startWeight = weightProgress.startWeight ?? 0.0;
    final currentWeight = weightProgress.currentWeight ?? 0.0;
    final targetWeight = weightProgress.targetWeight ?? 0.0;
    final weightChangePerWeek = weightProgress.weightChangePerWeek ?? 0.0;
    
    // Calculate progress percentage
    // Handle all cases: gain weight (target > start), lose weight (target < start)
    // And negative progress cases (current moved opposite to target)
    final progress = _calculateProgress(
      startWeight,
      currentWeight,
      targetWeight,
    );

    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 20, right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weight change per week
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${weightChangePerWeek > 0 ? '+' : ''}${weightChangePerWeek.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kg/week',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          _buildProgressBar(progress),
          const SizedBox(height: 16),
          
          // Weight labels (Start, Current, Target)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeightInfo('Start', startWeight.toStringAsFixed(1)),
              _buildWeightInfo('Current', currentWeight.toStringAsFixed(1)),
              _buildWeightInfo('Target', targetWeight.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Add weight button
          Container(
            // color: Colors.red,
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showWeightPickerBottomSheet(currentWeight),
              icon: const Icon(Icons.add, size: 14, color: Colors.black87),
              label: const Text('Add Weight', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF6F7F9),
                foregroundColor: Color(0xFFF6F7F9),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                shadowColor: Colors.transparent,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(12),
                  // side: const BorderSide(color: Colors.black87),
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress(double start, double current, double target) {
    final targetRange = target - start;
    
    // If target range is 0, return 0 (no progress possible)
    if (targetRange == 0) return 0.0;
    
    // Calculate progress: (current - start) / (target - start)
    final progress = (current - start) / targetRange;
    
    // Clamp between 0 and 1 for normal progress
    // Allow negative values for negative progress cases
    if (target > start) {
      // Want to gain weight
      // If current < start, progress is negative (lost weight when trying to gain)
      // If current > target, progress > 1 (gained more than target)
      return progress.clamp(0, 1.0);
    } else {
      // Want to lose weight
      // If current > start, progress is negative (gained weight when trying to lose)
      // If current < target, progress > 1 (lost more than target)
      return progress.clamp(0, 1.0);
    }
  }

  Widget _buildProgressBar(double progress) {
    // Clamp progress for display (0 to 1)
    final displayProgress = progress.clamp(0.0, 1.0);
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: displayProgress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInfo(String label, String value) {
    return Column(
      children: [
        Text(
          '$value kg',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showWeightPickerBottomSheet(double currentWeight) {
    // Get scaffold messenger from parent context before showing bottom sheet
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final progressBloc = context.read<ProgressBloc>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        // Generate weight options (30 to 200 kg, 0.5 increments)
        final weights = List.generate(341, (index) => 30.0 + index * 0.5);
        // Find closest weight to current weight
        int initialIndex = 0;
        double minDiff = double.infinity;
        for (int i = 0; i < weights.length; i++) {
          final diff = (weights[i] - currentWeight).abs();
          if (diff < minDiff) {
            minDiff = diff;
            initialIndex = i;
          }
        }
        
        double selectedWeight = weights[initialIndex];
        
        return StatefulBuilder(
          builder: (BuildContext bottomSheetContext, StateSetter setState) {
            return Container(
              height: MediaQuery.of(bottomSheetContext).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        const Text(
                          'Select Weight',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Close bottom sheet first
                            Navigator.of(bottomSheetContext).pop();
                            
                            try {
                              // Call API to add weight
                              await _progressRepository.addWeight(
                                value: selectedWeight,
                                unit: 'kg',
                              );

                              // Refresh progress data
                              if (mounted) {
                                progressBloc.add(const FetchProgressData());
                              }

                              // Show success message
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Weight updated successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Show error message
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update weight: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Picker
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50,
                      scrollController: FixedExtentScrollController(
                        initialItem: initialIndex,
                      ),
                      onSelectedItemChanged: (int index) {
                        selectedWeight = weights[index];
                      },
                      children: weights.map((weight) {
                        return Center(
                          child: Text(
                            weight % 1 == 0
                                ? '${weight.toInt()} kg'
                                : '${weight.toStringAsFixed(1)} kg',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDailyGoalSection(DailyGoal dailyGoal) {
    // Handle null values
    final calorie = dailyGoal.calorie ?? 0.0;
    final protein = dailyGoal.protein ?? 0.0;
    final carbs = dailyGoal.carbs ?? 0.0;
    final fats = dailyGoal.fats ?? 0.0;
    
    // Initialize sliders when not adjusting
    if (!_isAdjustingGoals) {
      _caloriesSlider = calorie;
      _proteinSlider = protein;
      _carbsSlider = carbs;
      _fatsSlider = fats;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isAdjustingGoals
          ? _buildAdjustGoalsView()
          : _buildGoalsDisplayView(calorie, protein, carbs, fats),
    );
  }

  Widget _buildGoalsDisplayView(double calorie, double protein, double carbs, double fats) {
    return Column(
      children: [
        // Calories
        Column(
          children: [
            Text(
              '${calorie.round()}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'daily calorie goal',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          height: 1.5,
          color: Colors.grey[300],
        ),

        const SizedBox(height: 16),

        // Macros
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildMacroItem(
                'Protein',
                protein.round(),
                Colors.orange,
                Icons.bolt,
              ),
            ),
            Expanded(
              child: _buildMacroItem(
                'Fat',
                fats.round(),
                Colors.blue,
                Icons.water_drop,
              ),
            ),
            Expanded(
              child: _buildMacroItem(
                'Carbs',
                carbs.round(),
                Colors.brown,
                Icons.grain,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Adjust Goals button
        // SizedBox(
        //   width: 170,
        //   child: OutlinedButton(
        //     onPressed: () {
        //       setState(() {
        //         _isAdjustingGoals = true;
        //       });
        //     },
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 8),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       side: const BorderSide(color: Colors.grey),
        //       backgroundColor: const Color(0xFFF6F7F9),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text(
        //           'Adjust macros',
        //           style: GoogleFonts.poppins(
        //             fontSize: 15,
        //             fontWeight: FontWeight.w600,
        //             color: Colors.black87,
        //           ),
        //         ),
        //         const SizedBox(width: 6),
        //         const Icon(Icons.tune, color: Colors.black87, size: 18),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildMacroItem(String label, int value, Color color, IconData icon) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${value}g',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$label (g)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustGoalsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Note
        Text(
          'NOTE - Set your own macro intakes based on your preferences.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 24),

        // // Calories slider - DISABLED (not allowed to change)
        // Opacity(
        //   opacity: 0.5,
        //   child: _buildGoalSlider(
        //     'Calories',
        //     _caloriesSlider,
        //     Colors.black,
        //     (value) {
        //       // Calories cannot be changed - do nothing
        //     },
        //     0.0,
        //     5000.0,
        //     enabled: false,
        //   ),
        // ),
        //
        // const SizedBox(height: 22),

        // Protein slider
        _buildGoalSlider(
          'Protein',
          _proteinSlider,
          Colors.orange,
          (value) {
            setState(() {
              _proteinSlider = value;
            });
          },
          0.0,
          300.0,
        ),

        const SizedBox(height: 22),

        // Fat slider
        _buildGoalSlider(
          'Fat',
          _fatsSlider,
          Colors.blue,
          (value) {
            setState(() {
              _fatsSlider = value;
            });
          },
          0.0,
          300.0,
        ),

        const SizedBox(height: 22),

        // Carbs slider
        _buildGoalSlider(
          'Carbs',
          _carbsSlider,
          Colors.brown,
          (value) {
            setState(() {
              _carbsSlider = value;
            });
          },
          0.0,
          500.0,
        ),

        const SizedBox(height: 32),

        // Done button
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: _isUpdatingGoals ? null : () async {
              // Set updating flag
              setState(() {
                _isUpdatingGoals = true;
              });

              try {
                // Call API to update profile goals (without calories)
                await _onboardingRepository.updateProfileGoals(
                  dailyProtein: _proteinSlider,
                  dailyCarbs: _carbsSlider,
                  dailyFats: _fatsSlider,
                );

                // Update local state
                setState(() {
                  _isAdjustingGoals = false;
                  _isUpdatingGoals = false;
                });

                // Refresh progress data
                context.read<ProgressBloc>().add(const FetchProgressData());

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goals updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Reset updating flag on error
                setState(() {
                  _isUpdatingGoals = false;
                });

                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update goals: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF6F7F9),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.grey),
              elevation: 0,
            ),
            child: _isUpdatingGoals
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSlider(
    String label,
    double value,
    Color color,
    Function(double) onChanged,
    double minValue,
    double maxValue, {
    bool enabled = true,
  }) {
    final displayValue = label == 'Calories' 
        ? '${value.round()} kcal'
        : '${value.round()}g';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayValue,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: enabled ? color : Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.clamp(minValue, maxValue),
            min: minValue,
            max: maxValue,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInSection(String lastCheckedIn, String nextCheckIn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Check-in',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastCheckedIn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Next Check-in',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextCheckIn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


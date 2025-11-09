import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/onboarding/onboarding_question_model.dart';
import '../../../blocs/onboarding/onboarding_state.dart';
import '../../../blocs/onboarding/onboarding_bloc.dart';
import '../../../blocs/onboarding/onboarding_event.dart';

class PlanSummaryWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;
  final OnboardingLoaded state;

  const PlanSummaryWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
    required this.state,
  });

  @override
  State<PlanSummaryWidget> createState() => _PlanSummaryWidgetState();
}

class _PlanSummaryWidgetState extends State<PlanSummaryWidget> {
  bool _isAdjusting = false;
  bool _isUpdatingGoals = false;
  
  // Macro values - will be loaded from question data or saved answer
  double _calories = 1695;
  double _protein = 126.0; // in grams
  double _fat = 126.0; // in grams
  double _carbs = 126.0; // in grams
  
  // Slider values (for adjusting)
  double _proteinSlider = 126.0;
  double _fatSlider = 126.0;
  double _carbsSlider = 126.0;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  void _loadInitialValues() {
    // First try to load from saved answer
    if (widget.currentAnswer?.isNotEmpty == true) {
      try {
        final answer = widget.currentAnswer!.first;
        // Format: "calories:1695,protein:126,fat:126,carbs:126"
        final parts = answer.split(',');
        for (final part in parts) {
          final kv = part.split(':');
          if (kv.length == 2) {
            final key = kv[0].trim();
            final value = double.parse(kv[1].trim());
            switch (key) {
              case 'calories':
                _calories = value;
                break;
              case 'protein':
                _protein = value;
                _proteinSlider = value;
                break;
              case 'fat':
                _fat = value;
                _fatSlider = value;
                break;
              case 'carbs':
                _carbs = value;
                _carbsSlider = value;
                break;
            }
          }
        }
        return; // If we loaded from answer, we're done
      } catch (e) {
        // Continue to try loading from question
      }
    }
    
    // If no saved answer, load from calculatedPlanData (from GOAL_CALCULATION API response)
    if (widget.state.calculatedPlanData != null) {
      final planData = widget.state.calculatedPlanData!;
      _calories = planData.calories;
      _protein = planData.protein;
      _proteinSlider = planData.protein;
      _fat = planData.fat;
      _fatSlider = planData.fat;
      _carbs = planData.carbs;
      _carbsSlider = planData.carbs;
    }
    // Fallback to question planData if available
    else if (widget.question.planData != null) {
      final planData = widget.question.planData!;
      _calories = planData.calories;
      _protein = planData.protein;
      _proteinSlider = planData.protein;
      _fat = planData.fat;
      _fatSlider = planData.fat;
      _carbs = planData.carbs;
      _carbsSlider = planData.carbs;
    }
  }

  // Get LBM from planData (provided by backend)
  double? get _lbm => widget.state.calculatedPlanData?.lbm ?? widget.question.planData?.lbm;

  void _saveMacros() {
    final macroString = 'calories:${_calories.round()},protein:${_protein.round()},fat:${_fat.round()},carbs:${_carbs.round()}';
    widget.onAnswerChanged([macroString]);
  }

  void _updateCaloriesFromMacros() {
    // Recalculate calories from macros
    // Protein: 4 cal/g, Fat: 9 cal/g, Carbs: 4 cal/g
    _calories = (_proteinSlider * 4) + (_fatSlider * 9) + (_carbsSlider * 4);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded && !state.isLoading && _isUpdatingGoals) {
          // API call completed successfully
          setState(() {
            _isUpdatingGoals = false;
            _isAdjusting = false;
          });
        } else if (state is OnboardingError && _isUpdatingGoals) {
          // API call failed
          setState(() {
            _isUpdatingGoals = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              widget.question.text,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            
            // Subtext (optional)
            if (widget.question.subtext != null && widget.question.subtext!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.question.subtext!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            if (_isUpdatingGoals || widget.state.isLoading) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
            ] else if (!_isAdjusting) ...[
              _buildPlanView(),
            ] else ...[
              _buildAdjustMacrosView(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanView() {
    
    return Column(
      children: [
        // Goal section
        if ((widget.state.calculatedPlanData?.goal != null && widget.state.calculatedPlanData!.goal!.isNotEmpty) ||
            (widget.question.planData?.goal != null && widget.question.planData!.goal!.isNotEmpty))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.state.calculatedPlanData?.goal ?? widget.question.planData?.goal ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Calorie and Macro card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Calories
              Column(
                children: [
                  Text(
                    '${_calories.round()}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'calories',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                height: 1.5,
                color: Colors.grey[300],
              ),

              const SizedBox(height: 24),
              
              // Macros
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _buildMacroItem('Protein', _protein.round(), Colors.orange, Icons.bolt)),
                  Expanded(child: _buildMacroItem('Fat', _fat.round(), Colors.blue, Icons.water_drop)),
                  Expanded(child: _buildMacroItem('Carbs', _carbs.round(), Colors.brown, Icons.grain)),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Adjust Macros button
        // SizedBox(
        //   width: 170,
        //   child: OutlinedButton(
        //     onPressed: () {
        //       setState(() {
        //         _isAdjusting = true;
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
        //           'Adjust Macros',
        //           style: GoogleFonts.poppins(
        //             fontSize: 15,
        //             fontWeight: FontWeight.w600,
        //             color: Colors.black87,
        //           ),
        //         ),
        //         const SizedBox(width: 6),
        //         Icon(Icons.tune, color: Colors.black87, size: 18),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildMacroItem(String label, int value, Color color, IconData icon) {
    return Container(
      // color: Colors.red,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                  '${value}g',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              )
            ],
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
    );
  }

  Widget _buildAdjustMacrosView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Note
        Text(
          'NOTE - Set your own macro intakes to create a custom plan',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Protein slider
        _buildMacroSlider(
          'Protein',
          _proteinSlider,
          Colors.orange,
          (value) {
            setState(() {
              _proteinSlider = value;
              _protein = value;
              _updateCaloriesFromMacros();
              _saveMacros();
            });
          },
        ),
        
        const SizedBox(height: 24),
        
        // Fat slider
        _buildMacroSlider(
          'Fat',
          _fatSlider,
          Colors.blue,
          (value) {
            setState(() {
              _fatSlider = value;
              _fat = value;
              _updateCaloriesFromMacros();
              _saveMacros();
            });
          },
        ),
        
        const SizedBox(height: 24),
        
        // Carbs slider
        _buildMacroSlider(
          'Carbs',
          _carbsSlider,
          Colors.red[400]!,
          (value) {
            setState(() {
              _carbsSlider = value;
              _carbs = value;
              _updateCaloriesFromMacros();
              _saveMacros();
            });
          },
        ),
        
        const SizedBox(height: 32),
        
        // Done button
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: _isUpdatingGoals ? null : () {
              // Save macros locally first
              _saveMacros();
              
              // Set updating flag
              setState(() {
                _isUpdatingGoals = true;
              });
              
              // Call API to update profile goals
              context.read<OnboardingBloc>().add(UpdateProfileGoals(
                dailyCalories: _calories,
                dailyProtein: _protein,
                dailyCarbs: _carbs,
                dailyFats: _fat,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF6F7F9),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey),
              elevation: 0,
            ),
            child: Text(
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

  Widget _buildMacroSlider(
    String label,
    double value,
    Color color,
    Function(double) onChanged,
  ) {
    final minValue = 0.0;
    final maxValue = 300.0;
    final gPerLbm = _lbm != null && _lbm! > 0 ? (value / _lbm!).toStringAsFixed(1) : '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '$label',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${value.round()}g',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (_lbm != null && _lbm! > 0)
              Text(
                '$gPerLbm/g lbm',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.clamp(minValue, maxValue),
            min: minValue,
            max: maxValue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}


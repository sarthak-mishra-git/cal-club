import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cal_track/blocs/food_analysis/food_analysis_bloc.dart';
import 'package:cal_track/blocs/food_analysis/food_analysis_event.dart';
import 'package:cal_track/blocs/food_analysis/food_analysis_state.dart';
import 'package:cal_track/models/meal_details/meal_details_model.dart';
import 'package:cal_track/ui/meal_details/widgets/nutritional_summary_card.dart';
import 'package:cal_track/ui/meal_details/widgets/ingredient_card.dart';

class MealDetailsScreen extends StatefulWidget {
  final String? mealId;
  
  const MealDetailsScreen({super.key, this.mealId});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen>
    with TickerProviderStateMixin {
  bool isEditing = false;
  MealDetailsModel? editableMealDetails;
  Map<String, Map<String, dynamic>> pendingChanges = {}; // Store ingredient changes (quantity and name)
  
  // Animation controllers for collapsible panel
  late AnimationController _panelController;
  late Animation<double> _panelHeightAnimation;
  late Animation<double> _panelOpacityAnimation;
  
  // Panel state
  bool _isPanelExpanded = true; // Start expanded (60% height)
  double _panelHeight = 0.6; // 60% of screen height initially

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _panelHeightAnimation = Tween<double>(
      begin: 0.6, // 60% height
      end: 0.25, // 25% height
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeInOut,
    ));
    
    _panelOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeInOut,
    ));
    
    _panelHeightAnimation.addListener(() {
      setState(() {
        _panelHeight = _panelHeightAnimation.value;
      });
    });
    
    // Fetch meal details if mealId is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mealId != null) {
        context.read<FoodAnalysisBloc>().add(
          FetchMealDetails(mealId: widget.mealId!),
        );
      }
    });
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    if (_isPanelExpanded) {
      _panelController.forward(); // Collapse to 25%
    } else {
      _panelController.reverse(); // Expand to 60%
    }
    setState(() {
      _isPanelExpanded = !_isPanelExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Light beige background
      body: BlocListener<FoodAnalysisBloc, FoodAnalysisState>(
        listener: (context, state) {
          if (state is FoodAnalysisLoaded) {
            setState(() {
              editableMealDetails = state.mealDetails;
            });
          } else if (state is FoodAnalysisUpdated) {
            setState(() {
              editableMealDetails = state.mealDetails;
              isEditing = false;
              pendingChanges.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meal updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is FoodAnalysisError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<FoodAnalysisBloc, FoodAnalysisState>(
          builder: (context, state) {
            // Show loading for any loading state
            if (state is FoodAnalysisLoading || state is FoodAnalysisUpdating) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is FoodAnalysisError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading meal details',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            if (state is FoodAnalysisLoaded && state.mealDetails != null) {
              return _buildMealDetailsContent(state.mealDetails!);
            }
            
            // Show meal content if we have it (for editing mode)
            if (editableMealDetails != null) {
              return _buildMealDetailsContent(editableMealDetails!);
            }
            
            // Initial state - show loading
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMealDetailsContent(MealDetailsModel mealDetails) {
    return Stack(
      children: [
        // Background image (fixed, behind content)
        _buildBackgroundImage(mealDetails),
        
        // Collapsible content panel
        _buildCollapsiblePanel(mealDetails),
        

      ],
    );
  }

  Widget _buildBackgroundImage(MealDetailsModel mealDetails) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.7, // 70% height
      child: Stack(
        children: [
          // Background image container
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.network(
                mealDetails.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
                cacheWidth: 800,
                cacheHeight: 600,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Meal Image',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Back button positioned on top of image
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsiblePanel(MealDetailsModel mealDetails) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * _panelHeight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DC), // Light beige
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            _buildDragHandle(),
            
            // Content
            Expanded(
              child: _buildPanelContent(mealDetails),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return GestureDetector(
      onTap: _togglePanel,
      child: Container(
        height: 40, // Increased height to prevent overflow
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              _isPanelExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent(MealDetailsModel mealDetails) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          _buildMealHeader(mealDetails),
          const SizedBox(height: 18),
          
          // Balance indicator
          _buildBalanceIndicator(mealDetails),
          const SizedBox(height: 18),
          
          // Nutritional summary
          _buildNutritionalSummary(mealDetails),
          const SizedBox(height: 18),
          
          // Ingredients
          _buildIngredientsSection(mealDetails),
          const SizedBox(height: 20),
          
          // Action buttons
          _buildActionButtons(mealDetails),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMealHeader(MealDetailsModel mealDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal type tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Meal',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Meal name
        Text(
          mealDetails.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceIndicator(MealDetailsModel mealDetails) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mealDetails.isBalanced ? const Color(0xFFE8F5E8) : const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mealDetails.isBalanced ? const Color(0xFF8B7355) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            mealDetails.isBalanced ? Icons.check_circle : Icons.info_outline,
            color: mealDetails.isBalanced ? const Color(0xFF8B7355) : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mealDetails.balanceMessage, // Use real message from API
              style: TextStyle(
                color: mealDetails.isBalanced ? const Color(0xFF8B7355) : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalSummary(MealDetailsModel mealDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutritional Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.25, // Decreased to give more height to each card
          children: [
            NutritionalSummaryCard(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange, // Keep orange flame
              value: '${mealDetails.nutritionalSummary.totalCalories.round()} kcal',
              label: 'Calories',
            ),
            NutritionalSummaryCard(
              icon: Icons.flash_on,
              iconColor: Colors.blue, // Keep blue lightning
              value: '${mealDetails.nutritionalSummary.totalProtein.round()}g',
              label: 'Protein',
            ),
            NutritionalSummaryCard(
              icon: Icons.grain,
              iconColor: Colors.green, // Keep green wheat
              value: '${mealDetails.nutritionalSummary.totalCarbs.round()}g',
              label: 'Carbs',
            ),
            NutritionalSummaryCard(
              icon: Icons.water_drop,
              iconColor: Colors.red, // Keep red water drops
              value: '${mealDetails.nutritionalSummary.totalFat.round()}g',
              label: 'Fat',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(MealDetailsModel mealDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...mealDetails.ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IngredientCard(
              ingredient: ingredient,
              mealId: mealDetails.id,
              isEditing: isEditing,
              onIngredientChanged: isEditing ? (itemId, newQuantity, newName) {
                // Store changes locally without calling API
                print('DEBUG: onIngredientChanged called: itemId=$itemId, quantity=$newQuantity, name=$newName');
                setState(() {
                  pendingChanges[itemId] = {
                    'quantity': newQuantity,
                    'name': newName,
                  };
                });
                print('DEBUG: Updated pendingChanges: $pendingChanges');
              } : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons(MealDetailsModel mealDetails) {
    return Column(
      children: [
        // Edit Meal button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              if (isEditing) {
                // Save changes - call API for all pending changes
                if (pendingChanges.isNotEmpty) {
                  // Call API for each changed ingredient
                  for (final entry in pendingChanges.entries) {
                    final changes = entry.value;
                    final newQuantity = changes['quantity'] as double;
                    final newName = changes['name'] as String;
                    
                    context.read<FoodAnalysisBloc>().add(
                      UpdateIngredientQuantity(
                        mealId: mealDetails.id,
                        itemId: entry.key,
                        newQuantity: newQuantity,
                        newItem: newName,
                      ),
                    );
                  }
                  
                  // The BlocListener will handle the FoodAnalysisUpdated state
                  // and update the screen with new data
                } else {
                  // No changes, just exit editing mode
                  setState(() {
                    isEditing = false;
                  });
                }
              } else {
                // Start editing
                editableMealDetails = mealDetails;
                setState(() {
                  isEditing = true;
                });
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Text(
              isEditing ? 'Save Changes' : 'Edit Meal',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Done button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to dashboard with result to trigger refresh
              Navigator.of(context).pop('refresh');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 
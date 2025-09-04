import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/widgets/logged_widget_data.dart';
import '../../../models/widgets/log_entry_data.dart';
import '../../meal_details/screens/meal_details_screen.dart';
import '../../../blocs/food_analysis/food_analysis_bloc.dart';

class LoggedWidget extends StatelessWidget {
  final LoggedWidgetData loggedData;

  const LoggedWidget({
    super.key,
    required this.loggedData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),
          // Content - either logs or zero state
          loggedData.logs.isEmpty
              ? _buildZeroState()
              : _buildLogsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loggedData.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loggedData.subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildZeroState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: loggedData.zeroState.image.isNotEmpty
                ? ClipOval(
                    child: Image.asset(
                      loggedData.zeroState.image,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.restaurant,
                    size: 75,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            loggedData.zeroState.text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(BuildContext context) {
    return Column(
      children: loggedData.logs.map((log) => _buildLogCard(log, context)).toList(),
    );
  }

  Widget _buildLogCard(LogEntryData log, BuildContext context) {
    return GestureDetector(
      onTap: () => _onMealTap(context, log.mealId),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Dish Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: log.dishImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          log.dishImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish name and time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            log.dishName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          log.time,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Calories
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 18,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${log.calories} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Macronutrients
                    Row(
                      children: [
                        _buildMacroItem(
                          Icons.bolt_outlined,
                          Colors.red,
                          '${log.protein}g',
                        ),
                        const SizedBox(width: 16),
                        _buildMacroItem(
                          Icons.grain,
                          Colors.brown,
                          '${log.carbs}g',
                        ),
                        const SizedBox(width: 16),
                        _buildMacroItem(
                          Icons.water_drop_outlined,
                          Colors.blue,
                          '${log.fat}g',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroItem(IconData icon, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _onMealTap(BuildContext context, String mealId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => FoodAnalysisBloc(),
          child: MealDetailsScreen(mealId: mealId),
        ),
      ),
    );
  }
} 
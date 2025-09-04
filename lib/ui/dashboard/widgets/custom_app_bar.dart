import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/widgets/app_bar_data.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarData? appBarData;
  final VoidCallback? onCaloriesTap;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    this.appBarData,
    this.onCaloriesTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black, // Light beige
      elevation: 1,
      title: Row(
        children: [
          // App logo/name
          Row(
            children: [
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
          
          // Calories display
          if (appBarData != null && onCaloriesTap != null)
            GestureDetector(
              onTap: onCaloriesTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                  // border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/calorie_icon.png', // Replace with the correct path to your asset
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${appBarData!.caloriesBurnt}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(width: 12),
          
          // Profile button
          if (onProfileTap != null)
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                  // border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 
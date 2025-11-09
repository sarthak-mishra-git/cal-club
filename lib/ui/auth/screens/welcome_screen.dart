import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/navigation_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.network(
                    "https://res.cloudinary.com/dfdvmcj2x/image/upload/v1761328755/onboard_intro_lltng0.png",
                    height: 450, // Use explicit height if given
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _fallbackImage();
                    },
                  ),
                ),
              ),
              
              // Text
              Text(
                'Calorie tracking\nmade easy.',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Continue for free button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    NavigationService.navigateTo('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Continue for free',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Already have an account text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationService.navigateTo('/login');
                    },
                    child: Text(
                      'Log in',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}


Widget _fallbackImage() {
  return Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFFF6F7F9),
    ),
    child: Icon(
      Icons.image_not_supported,
      size: 48,
      color: Colors.grey[400],
    ),
  );
}


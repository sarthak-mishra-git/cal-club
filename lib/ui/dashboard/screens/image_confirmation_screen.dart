import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class ImageConfirmationScreen extends StatelessWidget {
  final String imagePath;
  final String source; // 'camera' or 'gallery'

  const ImageConfirmationScreen({
    super.key,
    required this.imagePath,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Confirm Image',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Image preview
              Expanded(
                child: Center(
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Continue button
                    Expanded(
                      // width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop({
                              'imagePath': imagePath,
                              'source': source,
                              'timestamp': DateTime.now().millisecondsSinceEpoch,
                              'confirmed': true,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 12),
                    // Retake/Choose Again button
                    Expanded(
                      // width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop({'retake': true});
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            source == 'camera' ? 'Retake' : 'Choose Again',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
}


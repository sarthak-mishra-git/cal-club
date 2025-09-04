import 'package:flutter/material.dart';

class ImageSourceDialog extends StatelessWidget {
  const ImageSourceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black, // Dark background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Select Image Source',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Camera option
          ListTile(
            leading: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 26,
            ),
            title: const Text(
              'Use Camera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop('camera');
            },
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
            thickness: 0.3,
            indent: 20,
            endIndent: 20,
          ),
          // Gallery option
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: Colors.white,
              size: 26,
            ),
            title: const Text(
              'Choose from Gallery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop('gallery');
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
} 
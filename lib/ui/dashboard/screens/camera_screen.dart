import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'image_confirmation_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isInitializing = true;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndInitialize();
  }

  Future<void> _requestPermissionAndInitialize() async {
    try {
      setState(() {
        _isInitializing = true;
        _initializationError = null;
      });

      // Request camera permission explicitly
      var status = await Permission.camera.status;
      
      // Request permission if not granted
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      
      // If permission granted, initialize camera
      if (status.isGranted) {
        await _setupCamera();
      } else {
        // Permission denied, exit camera screen silently
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
      
    } catch (e) {
      // Check if error is due to permission denial
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('permission') || 
          errorString.contains('denied') ||
          errorString.contains('not authorized') ||
          errorString.contains('camera access')) {
        // Permission was denied, exit camera screen
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        await _handleInitializationError(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      
      // // iOS Simulator workaround: If no cameras available, show simulator message
      // if (_cameras == null || _cameras!.isEmpty) {
      //   if (defaultTargetPlatform == TargetPlatform.iOS && kDebugMode) {
      //     if (mounted) {
      //       setState(() {
      //         _isInitialized = true;
      //         _initializationError = null;
      //       });
      //     }
      //     return; // Skip camera controller setup
      //   } else {
      //     throw Exception('No cameras available on this device');
      //   }
      // }

      // Try to find the best camera (prefer back camera)
      CameraDescription? selectedCamera;
      
      // First try to find a back camera
      for (final camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }
      
      // Fallback to any available camera
      selectedCamera ??= _cameras!.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _initializationError = null;
        });
      }
    } catch (e) {
      throw Exception('Failed to setup camera: $e');
    }
  }

  Future<void> _handleInitializationError(dynamic error) async {
    if (!mounted) return;
    
    setState(() {
      _initializationError = error.toString();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to initialize camera: ${error.toString()}'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            _requestPermissionAndInitialize();
          },
        ),
      ),
    );
    
    // Exit camera screen after showing error
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Add haptic feedback for better UX
      HapticFeedback.lightImpact();
      
      final XFile image = await _controller!.takePicture();
      
      // Add success haptic feedback
      HapticFeedback.mediumImpact();
      
      if (mounted) {
        // Navigate to confirmation screen
        final confirmed = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageConfirmationScreen(
              imagePath: image.path,
              source: 'camera',
            ),
          ),
        );
        
        // If user confirmed, return the image
        if (confirmed != null && confirmed['confirmed'] == true) {
          Navigator.of(context).pop(confirmed);
        } else if (confirmed != null && confirmed['retake'] == true) {
          // User wants to retake, just stay on camera screen
          return;
        } else {
          // User went back, exit camera screen
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Add error haptic feedback
      HapticFeedback.heavyImpact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take picture: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _takePicture();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      // Use image_picker for gallery - it handles permissions automatically
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Navigate to confirmation screen
        final confirmed = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageConfirmationScreen(
              imagePath: image.path,
              source: 'gallery',
            ),
          ),
        );
        
        // If user confirmed, return the image
        if (confirmed != null && confirmed['confirmed'] == true) {
          Navigator.of(context).pop(confirmed);
        } else if (confirmed != null && confirmed['retake'] == true) {
          // User wants to choose again, call gallery selection again
          _selectFromGallery();
        } else {
          // User went back, stay on camera screen
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state during initialization
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initializing camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show error state if initialization failed
    if (_initializationError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Camera Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _initializationError!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializationError = null;
                      _isInitializing = true;
                    });
                    _requestPermissionAndInitialize();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show camera not initialized state
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show iOS Simulator message if no cameras available
    // if (_cameras == null || _cameras!.isEmpty) {
    //   return Scaffold(
    //     backgroundColor: Colors.black,
    //     body: Center(
    //       child: Padding(
    //         padding: const EdgeInsets.all(24),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             const Icon(
    //               Icons.camera_alt_outlined,
    //               color: Colors.white,
    //               size: 64,
    //             ),
    //             const SizedBox(height: 16),
    //             const Text(
    //               'iOS Simulator',
    //               style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 24,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //             const SizedBox(height: 8),
    //             const Text(
    //               'Camera functionality is not available in iOS Simulator.\n\nTo test camera features, please use a real iOS device.',
    //               style: TextStyle(
    //                 color: Colors.white70,
    //                 fontSize: 16,
    //               ),
    //               textAlign: TextAlign.center,
    //             ),
    //             const SizedBox(height: 24),
    //             ElevatedButton(
    //               onPressed: () => Navigator.of(context).pop(),
    //               style: ElevatedButton.styleFrom(
    //                 backgroundColor: Colors.white,
    //                 foregroundColor: Colors.black,
    //               ),
    //               child: const Text('Go Back'),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Center(child: CameraPreview(_controller!)),

          // Top controls
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const Text(
                    'Food Scanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 50), // Balance the layout
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery button
                  GestureDetector(
                    onTap: _selectFromGallery,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Capture button
                  GestureDetector(
                    onTap: _isCapturing ? null : _takePicture,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isCapturing ? 60 : 80,
                      height: _isCapturing ? 60 : 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isCapturing ? Colors.grey : Colors.white,
                          width: _isCapturing ? 2 : 4,
                        ),
                        color: _isCapturing ? Colors.grey.withOpacity(0.3) : Colors.white,
                        boxShadow: _isCapturing ? null : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isCapturing
                          ? const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.black,
                            ),
                    ),
                  ),

                  // Flash toggle button
                  GestureDetector(
                    onTap: () {
                      // Toggle flash functionality would go here
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.flash_off,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Camera status indicators
          Positioned(
            top: 120,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Camera resolution indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.high_quality,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'High Resolution',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Capture instruction overlay
          if (!_isCapturing)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: const Text(
                    'Position your food and tap to capture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ),
            ),
        ],
      ),
    );
  }
}

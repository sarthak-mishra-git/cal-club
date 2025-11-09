import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/onboarding/onboarding_question_model.dart';

class NotificationPermissionWidget extends StatefulWidget {
  final OnboardingQuestion question;
  final List<String>? currentAnswer;
  final Function(List<String>) onAnswerChanged;

  const NotificationPermissionWidget({
    super.key,
    required this.question,
    this.currentAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<NotificationPermissionWidget> createState() => _NotificationPermissionWidgetState();
}

class _NotificationPermissionWidgetState extends State<NotificationPermissionWidget> {
  bool _isRequesting = false;
  bool? _permissionGranted;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    // Check current permission status using permission_handler
    final status = await Permission.notification.status;
    
    if (mounted) {
      setState(() {
        _permissionGranted = status.isGranted;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (_isRequesting) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      bool? granted;
      
      // Request permission using flutter_local_notifications
      // This properly handles iOS and Android and actually shows the native permission dialog
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      if (iosImplementation != null) {
        granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else if (androidImplementation != null) {
        granted = await androidImplementation.requestNotificationsPermission();
      }
      
      // Re-check the actual permission status after request
      final status = await Permission.notification.status;
      final isGranted = status.isGranted;
      
      setState(() {
        _permissionGranted = isGranted;
        _isRequesting = false;
      });

      // Save the answer
      if (isGranted) {
        widget.onAnswerChanged(['allowed']);
      } else if (status.isPermanentlyDenied) {
        widget.onAnswerChanged(['permanently_denied']);
      } else {
        widget.onAnswerChanged(['denied']);
      }

      // Show feedback based on result
      if (mounted) {
        if (isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission granted'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog();
        }
      }
    } catch (e) {
      setState(() {
        _isRequesting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permission: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'Notification permission was denied. You can enable it later in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = widget.currentAnswer?.isNotEmpty == true ? widget.currentAnswer!.first : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            widget.question.text,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          
          // Subtext (optional)
          if (widget.question.subtext != null && widget.question.subtext!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.subtext!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ],

          if (widget.question.image != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.question.image!.paddingHorizontal ?? 0,
                  vertical: widget.question.image!.paddingVertical ?? 0,
                ),
                child: Image.network(
                  widget.question.image!.url,
                  height: widget.question.image!.height ?? 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
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
                  },
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Options container with minimum height for centering
          _buildAllowPermissionOption(),
        ],
      ),
    );
  }

  Widget _buildAllowPermissionOption() {
    
    return Center(
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey.withOpacity(0.6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          // borderRadius: BorderRadius.circular(16),
          shadowColor: Colors.black.withOpacity(0.1),
          child: InkWell(
            onTap: _isRequesting ? null : _requestNotificationPermission,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 24,
                      color:  Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Text content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allow permission',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (_isRequesting) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Requesting...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}


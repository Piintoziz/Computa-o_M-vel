import 'package:flutter/material.dart';
import '../services/shake_service.dart';
import 'help_dialog.dart';

mixin ShakeDetectorMixin<T extends StatefulWidget> on State<T> {
  final ShakeService _shakeService = ShakeService();

  @override
  void initState() {
    super.initState();
    _startShakeDetection();
  }

  @override
  void dispose() {
    _stopShakeDetection();
    super.dispose();
  }

  void _startShakeDetection() {
    _shakeService.startListening(_onShakeDetected);
  }

  void _stopShakeDetection() {
    _shakeService.stopListening();
  }

  void _onShakeDetected() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const HelpDialog();
        },
      );
    }
  }
} 
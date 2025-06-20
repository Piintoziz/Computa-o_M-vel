import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  static final ShakeService _instance = ShakeService._internal();
  factory ShakeService() => _instance;
  ShakeService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final List<double> _accelerometerValues = [];
  final int _bufferSize = 10;
  final double _shakeThreshold = 15.0;
  final Duration _shakeTimeWindow = const Duration(milliseconds: 500);

  DateTime? _lastShakeTime;
  Function? _onShakeDetected;

  void startListening(Function onShakeDetected) {
    _onShakeDetected = onShakeDetected;
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      _processAccelerometerData(event);
    });
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _accelerometerValues.clear();
    _lastShakeTime = null;
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    // Calculate the magnitude of acceleration
    double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    
    // Add to buffer
    _accelerometerValues.add(magnitude);
    if (_accelerometerValues.length > _bufferSize) {
      _accelerometerValues.removeAt(0);
    }

    // Check if we have enough data
    if (_accelerometerValues.length < _bufferSize) return;

    // Calculate variance to detect sudden movements
    double mean = _accelerometerValues.reduce((a, b) => a + b) / _accelerometerValues.length;
    double variance = _accelerometerValues.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / _accelerometerValues.length;
    double standardDeviation = sqrt(variance);

    // Check if shake is detected
    if (standardDeviation > _shakeThreshold) {
      DateTime now = DateTime.now();
      
      // Prevent multiple triggers in a short time window
      if (_lastShakeTime == null || 
          now.difference(_lastShakeTime!) > _shakeTimeWindow) {
        _lastShakeTime = now;
        _onShakeDetected?.call();
      }
    }
  }
} 
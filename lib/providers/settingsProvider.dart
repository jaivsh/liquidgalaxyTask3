import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/texts.dart';

// Connection Settings Providers
final ipProvider = StateProvider<String>((ref) => '');
final usernameProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final portProvider = StateProvider<int>((ref) => 22);
final rigsProvider = StateProvider<int>((ref) => 3);
final leftmostRigProvider = StateProvider<int>((ref) => 3);
final rightmostRigProvider = StateProvider<int>((ref) => 2);

// Loading and Status Providers
final isLoadingProvider = StateProvider<bool>((ref) => false);
final loadingPercentageProvider = StateProvider<double?>((ref) => null);
final isConnectedToLGProvider = StateProvider<bool>((ref) => false);
final isConnectedToInternetProvider = StateProvider<bool>((ref) => false);
final downloadableContentAvailableProvider = StateProvider<bool>((ref) => false);

// Language Provider
final languageProvider = StateProvider<String>((ref) => TextConst.langList.first);

// SSH Client Provider
final sshClient = StateProvider<SSHClient?>((ref) => null);

// Map Position Providers
final currentMapPositionProvider = StateProvider<CameraPosition>((ref) =>
const CameraPosition(
  target: LatLng(20.5937, 78.9629),
  zoom: 2,
)
);

// Gesture Control Providers
final isGestureEnabledProvider = StateProvider<bool>((ref) => true);
final gestureConfigProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'sensitivityLevel': 0.3,  // 0.0 to 1.0
  'movementThreshold': 10.0,  // degrees
  'gestureTimeout': 500,  // milliseconds
  'minZoom': 0.0,
  'maxZoom': 21.0,
  'defaultMovementStep': 10.0,  // degrees
});

final lastGestureProvider = StateProvider<String?>((ref) => null);
final gestureTimeoutProvider = StateProvider<int>((ref) => 500); // milliseconds

// Error Handling Provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Helper Functions
void setRigs(int rig, WidgetRef ref) {
  ref.read(rigsProvider.notifier).state = rig;
  ref.read(leftmostRigProvider.notifier).state = (rig) ~/ 2 + 1;
  ref.read(rightmostRigProvider.notifier).state = (rig) ~/ 2 + 1;
}

// Gesture Control Functions
bool isGestureAllowed(WidgetRef ref) {
  if (!ref.read(isGestureEnabledProvider)) return false;

  final lastGestureTime = ref.read(lastGestureProvider);
  if (lastGestureTime == null) return true;

  final timeout = ref.read(gestureTimeoutProvider);
  final now = DateTime.now().millisecondsSinceEpoch;

  return (now - int.parse(lastGestureTime)) >= timeout;
}

void updateLastGestureTime(WidgetRef ref) {
  ref.read(lastGestureProvider.notifier).state =
      DateTime.now().millisecondsSinceEpoch.toString();
}

void setErrorMessage(WidgetRef ref, String? message) {
  ref.read(errorMessageProvider.notifier).state = message;
}

// Position Validation
bool isValidLatLng(double lat, double lng) {
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

// Movement Validation
bool isValidMovement(WidgetRef ref, double currentLat, double currentLng,
    double newLat, double newLng) {
  if (!isValidLatLng(newLat, newLng)) return false;

  final config = ref.read(gestureConfigProvider);
  final threshold = config['movementThreshold'] as double;

  final latDiff = (newLat - currentLat).abs();
  final lngDiff = (newLng - currentLng).abs();

  return latDiff <= threshold && lngDiff <= threshold;
}

// Zoom Validation
bool isValidZoom(WidgetRef ref, double zoom) {
  final config = ref.read(gestureConfigProvider);
  return zoom >= config['minZoom'] && zoom <= config['maxZoom'];
}
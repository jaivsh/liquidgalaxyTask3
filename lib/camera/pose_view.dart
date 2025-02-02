import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lgtask3/camera/painters/pose_painter.dart';
import 'package:lgtask3/connections/sshConnect.dart';
import 'package:lgtask3/providers/settingsProvider.dart';
import 'package:lgtask3/utils/extensions.dart';

import 'detector_view.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({Key? key}) : super(key: key);

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
  PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  String _lastGesture = 'NONE';
  DateTime _lastGestureTime = DateTime.now();

  late WidgetRef _ref;

  // Gesture detection thresholds
  final double _shoulderThreshold = 0.3;
  final double _wristThreshold = 0.3;
  final int _gestureCooldown = 500;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        _ref = ref;  // Store ref for use in other methods
        return DetectorView(
          title: 'Pose Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        );
      },
    );
  }

  bool isRightHandUp(Pose pose) {
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (rightWrist == null || rightShoulder == null) return false;
    return rightWrist.y < rightShoulder.y;
  }

  bool isRightHandDown(Pose pose) {
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (rightWrist == null || rightShoulder == null) return false;
    return rightWrist.y > rightShoulder.y;
  }

  bool isLeftHandUp(Pose pose) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];

    if (leftWrist == null || leftShoulder == null) return false;
    return leftWrist.y < leftShoulder.y;
  }

  bool isLeftHandDown(Pose pose) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];

    if (leftWrist == null || leftShoulder == null) return false;
    return leftWrist.y > leftShoulder.y;
  }

  String detectGesture(Pose pose) {
    if (isRightHandUp(pose) && isLeftHandUp(pose)) return 'ZOOM_IN';
    if (isRightHandDown(pose) && isLeftHandDown(pose)) return 'ZOOM_OUT';
    if (isRightHandUp(pose)) return 'MOVE_NORTH';
    if (isRightHandDown(pose)) return 'MOVE_SOUTH';
    if (isLeftHandUp(pose)) return 'MOVE_EAST';
    if (isLeftHandDown(pose)) return 'MOVE_WEST';
    return 'NONE';
  }

  Future<void> executeGesture(String gesture) async {
    if (!_ref.read(isConnectedToLGProvider)) {
      setState(() {
        _text = 'Not connected to Liquid Galaxy';
      });
      return;
    }

    CameraPosition currentPosition = _ref.read(currentMapPositionProvider);

    try {
      switch (gesture) {
        case 'MOVE_NORTH':
          await _moveNorth(currentPosition);
          setState(() {
            _text = 'Moving North';
          });
          break;
        case 'MOVE_SOUTH':
          await _moveSouth(currentPosition);
          setState(() {
            _text = 'Moving South';
          });
          break;
        case 'MOVE_EAST':
          await _moveEast(currentPosition);
          setState(() {
            _text = 'Moving East';
          });
          break;
        case 'MOVE_WEST':
          await _moveWest(currentPosition);
          setState(() {
            _text = 'Moving West';
          });
          break;
        case 'ZOOM_IN':
          await _zoomIn(currentPosition);
          setState(() {
            _text = 'Zooming In';
          });
          break;
        case 'ZOOM_OUT':
          await _zoomOut(currentPosition);
          setState(() {
            _text = 'Zooming Out';
          });
          break;
        default:
          setState(() {
            _text = 'Waiting for gesture...';
          });
      }
    } catch (e) {
      setState(() {
        _text = 'Error executing gesture: $e';
      });
    }
  }

  Future<void> _moveNorth(CameraPosition position) async {
    double newLat = position.target.latitude + 10;
    if (newLat > 90) newLat = 90;

    await SSH(ref: _ref).flyTo(
        newLat,
        position.target.longitude,
        position.zoom.zoomLG,
        position.tilt,
        position.bearing
    );

    _ref.read(currentMapPositionProvider.notifier).state = CameraPosition(
      target: LatLng(newLat, position.target.longitude),
      zoom: position.zoom,
      tilt: position.tilt,
      bearing: position.bearing,
    );
  }

  Future<void> _moveSouth(CameraPosition position) async {
    double newLat = position.target.latitude - 10;
    if (newLat < -90) newLat = -90;

    await SSH(ref: _ref).flyTo(
        newLat,
        position.target.longitude,
        position.zoom.zoomLG,
        position.tilt,
        position.bearing
    );

    _ref.read(currentMapPositionProvider.notifier).state = CameraPosition(
      target: LatLng(newLat, position.target.longitude),
      zoom: position.zoom,
      tilt: position.tilt,
      bearing: position.bearing,
    );
  }

  Future<void> _moveEast(CameraPosition position) async {
    double newLng = position.target.longitude + 10;
    if (newLng > 180) newLng = -180 + (newLng - 180);

    await SSH(ref: _ref).flyTo(
        position.target.latitude,
        newLng,
        position.zoom.zoomLG,
        position.tilt,
        position.bearing
    );

    _ref.read(currentMapPositionProvider.notifier).state = CameraPosition(
      target: LatLng(position.target.latitude, newLng),
      zoom: position.zoom,
      tilt: position.tilt,
      bearing: position.bearing,
    );
  }

  Future<void> _moveWest(CameraPosition position) async {
    double newLng = position.target.longitude - 10;
    if (newLng < -180) newLng = 180 - (-180 - newLng);

    await SSH(ref: _ref).flyTo(
        position.target.latitude,
        newLng,
        position.zoom.zoomLG,
        position.tilt,
        position.bearing
    );

    _ref.read(currentMapPositionProvider.notifier).state = CameraPosition(
      target: LatLng(position.target.latitude, newLng),
      zoom: position.zoom,
      tilt: position.tilt,
      bearing: position.bearing,
    );
  }

  Future<void> _zoomIn(CameraPosition position) async {
    double newZoom = position.zoom + 1.0;
    if (newZoom > 21) newZoom = 21;  // Max zoom level

    await SSH(ref: _ref).flyTo(
        position.target.latitude,
        position.target.longitude,
        newZoom.zoomLG,
        position.tilt,
        position.bearing
    );

    _ref.read(currentMapPositionProvider.notifier).state = CameraPosition(
      target: position.target,
      zoom: newZoom,
      tilt: position.tilt,
      bearing: position.bearing,
    );
  }

  Future<void> _zoomOut(CameraPosition position) async {
    double newZoom = position.zoom - 1.0;
    if (newZoom < 0) newZoom = 0;  // Min zoom level

    await SSH(ref: _ref).flyTo(
        position.target.latitude,
        position.target.longitude,
        newZoom.zoomLG,
        position.tilt,
        position.bearing
    );

    _ref.read(currentMapPositionProvider.notifier).state = CameraPosition(
      target: position.target,
      zoom: newZoom,
      tilt: position.tilt,
      bearing: position.bearing,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final gesture = detectGesture(poses.first);

        // Implement gesture debouncing
        if (gesture != 'NONE' &&
            (gesture != _lastGesture ||
                DateTime.now().difference(_lastGestureTime).inMilliseconds > _gestureCooldown)) {
          await executeGesture(gesture);
          _lastGesture = gesture;
          _lastGestureTime = DateTime.now();
        }
      }

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      }
    } catch (e) {
      setState(() {
        _text = 'Error processing image: $e';
      });
    } finally {
      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_view.dart';
import 'gallery_view.dart';

enum DetectorViewMode { liveFeed, gallery }

class DetectorView extends StatefulWidget {
  DetectorView({
    Key? key,
    required this.title,
    required this.onImage,
    this.customPaint,
    this.text,
    this.detectionMode = DetectorViewMode.liveFeed,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final DetectorViewMode detectionMode;
  final Function(InputImage inputImage) onImage;
  final Function()? onCameraFeedReady;
  final Function(DetectorViewMode mode)? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<DetectorView> createState() => _DetectorViewState();
}

class _DetectorViewState extends State<DetectorView> {
  late DetectorViewMode _mode;

  @override
  void initState() {
    _mode = widget.detectionMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _mode == DetectorViewMode.liveFeed
          ? Stack(
        children: [
          CameraView(
            customPaint: widget.customPaint,
            onImage: widget.onImage,
            onCameraFeedReady: widget.onCameraFeedReady,
            onDetectorViewModeChanged: _onDetectorViewModeChanged,
            initialCameraLensDirection: widget.initialCameraLensDirection,
            onCameraLensDirectionChanged: widget.onCameraLensDirectionChanged,
          ),
          if (widget.text != null)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.text!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      )
          : GalleryView(
        title: widget.title,
        text: widget.text,
        onImage: widget.onImage,
        onDetectorViewModeChanged: _onDetectorViewModeChanged,
      ),
    );
  }

  void _onDetectorViewModeChanged() {
    if (_mode == DetectorViewMode.liveFeed) {
      _mode = DetectorViewMode.gallery;
    } else {
      _mode = DetectorViewMode.liveFeed;
    }
    if (widget.onDetectorViewModeChanged != null) {
      widget.onDetectorViewModeChanged!(_mode);
    }
    setState(() {});
  }
}
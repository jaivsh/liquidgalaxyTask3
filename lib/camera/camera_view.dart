import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.back
  }) : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLiveFeed();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    switch (state) {
      case AppLifecycleState.inactive:
        _stopLiveFeed();
        break;
      case AppLifecycleState.resumed:
        _startLiveFeed();
        break;
      default:
        break;
    }
  }

  Future<void> _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      await _startLiveFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Center(
                    child: _changingCameraLens
                        ? const Center(
                      child: Text(
                        'Changing camera lens',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    )
                        : CameraPreview(
                      _controller!,
                      child: widget.customPaint,
                    ),
                  ),
                  _buildControls(),
                ],
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _switchLiveCamera,
              ),
              if (widget.onDetectorViewModeChanged != null)
                IconButton(
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: widget.onDetectorViewModeChanged,
                ),
            ],
          ),
        ),
        if (_controller != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildZoomControl(),
                _buildExposureControl(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildZoomControl() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Slider(
        value: _currentZoomLevel,
        min: _minAvailableZoom,
        max: _maxAvailableZoom,
        activeColor: Colors.white,
        inactiveColor: Colors.white30,
        onChanged: (value) async {
          setState(() {
            _currentZoomLevel = value;
          });
          await _controller?.setZoomLevel(value);
        },
      ),
    );
  }

  Widget _buildExposureControl() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Slider(
        value: _currentExposureOffset,
        min: _minAvailableExposureOffset,
        max: _maxAvailableExposureOffset,
        activeColor: Colors.white,
        inactiveColor: Colors.white30,
        onChanged: (value) async {
          setState(() {
            _currentExposureOffset = value;
          });
          await _controller?.setExposureOffset(value);
        },
      ),
    );
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await Future.wait([
        _controller!.getMinZoomLevel().then((value) {
          _currentZoomLevel = value;
          _minAvailableZoom = value;
        }),
        _controller!.getMaxZoomLevel().then((value) {
          _maxAvailableZoom = value;
        }),
        _controller!.getMinExposureOffset().then((value) {
          _minAvailableExposureOffset = value;
        }),
        _controller!.getMaxExposureOffset().then((value) {
          _maxAvailableExposureOffset = value;
        }),
      ]);

      _currentExposureOffset = 0.0;
      await _controller!.startImageStream(_processCameraImage);
      if (widget.onCameraFeedReady != null) {
        widget.onCameraFeedReady!();
      }
      if (widget.onCameraLensDirectionChanged != null) {
        widget.onCameraLensDirectionChanged!(camera.lensDirection);
      }
    } catch (e) {
      print('Error starting camera feed: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future _stopLiveFeed() async {
    try {
      await _controller?.stopImageStream();
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      print('Error stopping camera feed: $e');
    }
  }

  Future _switchLiveCamera() async {
    if (_cameras.length < 2) return;

    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }
}
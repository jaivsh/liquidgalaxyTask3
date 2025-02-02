import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(
    double x,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection,
    ) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x * canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);

    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          x * canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);

    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
        // For front camera, mirror the coordinates
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
  }
}

double translateY(
    double y,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection,
    ) {
  // First, normalize the y coordinate based on image orientation
  double normalizedY = y;
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      normalizedY = y * canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
      break;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      normalizedY = y * canvasSize.height / imageSize.height;
      break;
  }

  // Apply any additional transformations based on camera direction
  if (cameraLensDirection == CameraLensDirection.front) {
    // For front camera, you might need to adjust the y-coordinate
    // depending on your specific requirements
    return normalizedY;
  }

  return normalizedY;
}

// Helper function to check if coordinates are within valid bounds
bool isValidCoordinate(double x, double y, Size bounds) {
  return x >= 0 && x <= bounds.width && y >= 0 && y <= bounds.height;
}

// Helper function to normalize coordinates to a 0-1 range
double normalizeCoordinate(double value, double max) {
  return value.clamp(0.0, max) / max;
}

// Helper function to get screen position relative to the camera view
Offset getScreenPosition(
    double x,
    double y,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection,
    ) {
  return Offset(
    translateX(x, canvasSize, imageSize, rotation, cameraLensDirection),
    translateY(y, canvasSize, imageSize, rotation, cameraLensDirection),
  );
}
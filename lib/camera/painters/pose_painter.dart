import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../widgets/painters/coordinates_translator.dart';
import 'dart:math';  // For pi constant in arrow drawing

class PosePainter extends CustomPainter {
  PosePainter(
      this.poses,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint jointPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final Paint leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final Paint rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    final Paint gestureZonePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white.withOpacity(0.3);

    for (final pose in poses) {
      // Draw gesture detection zones
      _drawGestureZones(canvas, size, gestureZonePaint);

      // Draw joints
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(
            translateX(landmark.x, size, imageSize, rotation, cameraLensDirection),
            translateY(landmark.y, size, imageSize, rotation, cameraLensDirection),
          ),
          1,
          jointPaint,
        );
      });

      // Draw connecting lines
      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark? joint1 = pose.landmarks[type1];
        final PoseLandmark? joint2 = pose.landmarks[type2];

        if (joint1 != null && joint2 != null) {
          canvas.drawLine(
            Offset(
              translateX(joint1.x, size, imageSize, rotation, cameraLensDirection),
              translateY(joint1.y, size, imageSize, rotation, cameraLensDirection),
            ),
            Offset(
              translateX(joint2.x, size, imageSize, rotation, cameraLensDirection),
              translateY(joint2.y, size, imageSize, rotation, cameraLensDirection),
            ),
            paintType,
          );
        }
      }

      // Draw arms
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      // Draw body
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, jointPaint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, jointPaint);

      // Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);

      // Draw hand movement guides
      _drawHandMovementGuides(canvas, size, pose, gestureZonePaint);
    }
  }

  void _drawGestureZones(Canvas canvas, Size size, Paint paint) {
    // Draw horizontal zones for up/down detection
    double zoneHeight = size.height / 3;

    // Upper zone
    canvas.drawRect(
      Rect.fromPoints(
        Offset(0, 0),
        Offset(size.width, zoneHeight),
      ),
      paint,
    );

    // Lower zone
    canvas.drawRect(
      Rect.fromPoints(
        Offset(0, size.height - zoneHeight),
        Offset(size.width, size.height),
      ),
      paint,
    );

    // Draw vertical midline for left/right detection
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  void _drawHandMovementGuides(Canvas canvas, Size size, Pose pose, Paint paint) {
    // Draw movement arrows or guides based on detected pose
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftWrist != null && rightWrist != null) {
      // Example: Draw guide arrows for hand movement
      final leftX = translateX(leftWrist.x, size, imageSize, rotation, cameraLensDirection);
      final leftY = translateY(leftWrist.y, size, imageSize, rotation, cameraLensDirection);
      final rightX = translateX(rightWrist.x, size, imageSize, rotation, cameraLensDirection);
      final rightY = translateY(rightWrist.y, size, imageSize, rotation, cameraLensDirection);

      // Draw arrows or guides based on current hand positions
      // This can be customized based on your specific gesture requirements
      _drawArrow(canvas, Offset(leftX, leftY), Offset(leftX, leftY - 30), paint);
      _drawArrow(canvas, Offset(rightX, rightY), Offset(rightX, rightY - 30), paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);

    // Draw arrow head
    final double arrowSize = 15;
    final double angle = (end - start).direction;

    final double x1 = end.dx - arrowSize * cos(angle - pi / 6);
    final double y1 = end.dy - arrowSize * sin(angle - pi / 6);
    final double x2 = end.dx - arrowSize * cos(angle + pi / 6);
    final double y2 = end.dy - arrowSize * sin(angle + pi / 6);

    final Path path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(x1, y1)
      ..lineTo(x2, y2)
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.poses != poses ||
        oldDelegate.rotation != rotation ||
        oldDelegate.cameraLensDirection != cameraLensDirection;
  }
}
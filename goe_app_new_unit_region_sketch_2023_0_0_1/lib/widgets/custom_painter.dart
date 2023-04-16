
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:goe_app_new_unit_region_sketch_2023_0_0_1/models/point.dart';

class CustomPainterWidget extends CustomPainter {
  final img.Image image;
  final List<Point<num>> centroids;

  CustomPainterWidget({required this.image, required this.centroids});

  @override
  void paint(Canvas canvas, Size size) {
    // Add your custom painting logic here.
    // Make sure to use the `image` and `centroids` variables in your painting logic.
  }

  @override
  bool shouldRepaint(CustomPainterWidget oldDelegate) {
    return image != oldDelegate.image || centroids != oldDelegate.centroids;
  }
}

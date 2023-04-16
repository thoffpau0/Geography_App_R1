import 'package:flutter/material.dart';
import 'dart:math';

class RegionDefinitionReviewScreen extends StatelessWidget {
  final List<Point> centroids;

  const RegionDefinitionReviewScreen({Key? key, required this.centroids}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Region Definition Review'),
      ),
      body: ListView.builder(
        itemCount: centroids.length,
        itemBuilder: (context, index) {
          final centroid = centroids[index];
          return ListTile(
            title: Text(
              'Region ${index + 1}',
            ),
            subtitle: Text(
              'Centroid: (${centroid.x}, ${centroid.y})',
            ),
          );
        },
      ),
    );
  }
}

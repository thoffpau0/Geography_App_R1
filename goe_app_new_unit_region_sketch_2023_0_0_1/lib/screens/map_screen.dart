// Import the required Flutter packages
import 'package:flutter/material.dart';
// Import your custom image processing utilities
import 'package:goe_app_new_unit_region_sketch_2023_0_0_1/models/point.dart';
import 'dart:io';

// Define a list of country labels
List<String> countryLabels = ['Country 1', 'Country 2', 'Country 3'];
// Define a list of colors for different regions
List<Color> regionColors = [Colors.red, Colors.green, Colors.blue];

// Define the MapScreen widget, a stateful widget as it maintains mutable state
class MapScreen extends StatefulWidget {
  final List<Point<num>> centroids; // Updated type
  final int numberOfRegions;
  final List<List<Point<num>>>
      regionBorders; // If necessary, update this type as well
  final File mapImage;

  const MapScreen({
    Key? key,
    required this.centroids,
    required this.numberOfRegions,
    required this.regionBorders,
    required this.mapImage,
  }) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

// Define the _MapScreenState class, which manages the mutable state of the MapScreen widget
class MapScreenState extends State<MapScreen> {
  // Define a map to store the association between country labels and regions
  Map<String, String> _countryToRegion = {};
  // Define a variable to store the index of the region that's currently being hovered over
  int? _hoveredRegion;

  // Define a map to store the label positions for each country
  Map<String, Offset> countryLabelPositions = {};

  // Define a method to check if a point is inside a region using regionBorders
  bool _isPointInsideRegion(Point<num> point, int regionIndex) {
    // Check if the point is inside the region using the regionBorders list
    return widget.regionBorders[regionIndex].contains(point);
  }

// Update the _buildDraggableCountryLabels method to handle onDragUpdate
  List<Widget> _buildDraggableCountryLabels() {
    List<Widget> draggableCountryLabels = [];

    for (int i = 0; i < countryLabels.length; i++) {
      draggableCountryLabels.add(
        Positioned(
          top: i * 60.0,
          left: 0,
          child: Draggable<String>(
            data: countryLabels[i],
            feedback: Material(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(countryLabels[i]),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(countryLabels[i]),
            ),
            onDragUpdate: (details) {
              // Check which region the point is in and update the _hoveredRegion
              for (int j = 0; j < widget.numberOfRegions; j++) {
                if (_isPointInsideRegion(
                    Point<num>(details.delta.dx, details.delta.dy), j)) {
                  setState(() {
                    _hoveredRegion = j;
                  });
                  break;
                } else {
                  setState(() {
                    _hoveredRegion = null;
                  });
                }
              }
            },
          ),
        ),
      );
    }

    return draggableCountryLabels;
  }

  // Define a method to build drop targets for regions
  List<Widget> _buildRegionDropTargets() {
    List<Widget> regionDropTargets = [];

    for (int i = 0; i < widget.numberOfRegions; i++) {
      regionDropTargets.add(
        Positioned(
          top: 200.0 + (i * 100),
          left: 200,
          child: InkWell(
            onHover: (isHovering) {
              setState(() {
                _hoveredRegion = isHovering ? i : null;
              });
            },
            child: DragTarget<String>(
              builder: (context, accepted, rejected) {
                return Container(
                  width: 100,
                  height: 100,
                  color: _hoveredRegion == i
                      ? regionColors[i].withOpacity(0.5)
                      : regionColors[i].withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _buildRegionCountryLabels(i),
                  ),
                );
              },
              onWillAccept: (value) => true,
              // In the _buildRegionDropTargets method, update the onAccept event
              onAccept: (String value) {
                setState(() {
                  _countryToRegion[value] = 'Region ${_hoveredRegion! + 1}';
                  // Place the country label at the centroid of the region
                  Point centroid = widget.centroids[_hoveredRegion!];
                  // Explicitly cast num to double
                  countryLabelPositions[value] =
                      Offset(centroid.x.toDouble(), centroid.y.toDouble());
                });
              },
            ),
          ),
        ),
      );
    }

    return regionDropTargets;
  }

  // Define a method to build country labels inside regions
  List<Widget> _buildRegionCountryLabels(int regionIndex) {
    List<Widget> regionCountryLabels = [];
    // Iterate through the _countryToRegion map
    _countryToRegion.forEach((country, region) {
      // Check if the current country belongs to the given regionIndex
      if (region == 'Region ${regionIndex + 1}') {
        // Get the position of the country label
        Offset position = countryLabelPositions[country]!;

        // Add the country label to the list of widgets
        regionCountryLabels.add(
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Text(country, style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    });

    // Return the list of country label widgets for the given region
    return regionCountryLabels;
  }

  // Define a method to reset the map state
  void _resetMap() {
    setState(() {
      // Clear the country-to-region associations
      _countryToRegion = {};
    });
  }

  // Define the build method for the _MapScreenState widget
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget containing the map and other UI elements
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geography Sketch Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetMap,
          ),
        ],
      ),
      body: InteractiveViewer(
        child: Stack(
          children: [
            // Add the map image
            Image.file(widget.mapImage), // Use the uploaded image
            // Add draggable country labels and region drop targets
            ..._buildDraggableCountryLabels(),
            ..._buildRegionDropTargets(),
          ],
        ),
      ),
    );
  }
}

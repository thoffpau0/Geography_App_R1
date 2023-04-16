import 'dart:io'; // Import the required package
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:goe_app_new_unit_region_sketch_2023_0_0_1/utils/image_processing.dart'; // Import the updated image_processing.dart
import 'package:goe_app_new_unit_region_sketch_2023_0_0_1/models/point.dart';
import 'package:goe_app_new_unit_region_sketch_2023_0_0_1/widgets/custom_painter.dart';
import 'map_screen.dart'; // Import the MapScreen class
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  img.Image? _image;
  String? _imagePath;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  List<Point<int>> centroids = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      img.Image? tempImg = img.decodeImage(await pickedFile.readAsBytes());
      if (tempImg != null) {
        setState(() {
          _image = tempImg;
          _imagePath = pickedFile.path; // Store the path of the picked file
        });
      }
    }
  }

  void processImage() async {
    if (_image != null && _imagePath != null) {
      try {
        // Send the image to the server and process the contours
        final responseJson =
            await sendImageAndProcessContours(File(_imagePath!));

        if (kDebugMode) {
          print('Response JSON: $responseJson');
        } // Add this line to print the responseJson

        // Deserialize the response JSON
        List<dynamic> contoursData;
        try {
          contoursData = jsonDecode(responseJson);
        } catch (e) {
          if (kDebugMode) {
            print('Error decoding JSON: $e');
          }
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content:
                  Text('Error decoding the server response. Please try again.'),
            ),
          );
          return;
        }

        // Convert the deserialized JSON data into a list of centroids
        centroids = contoursData.map((contourData) {
          List<Point<int>> points = contourData.map((pointData) {
            return Point<int>(pointData[0].toInt(), pointData[1].toInt());
          }).toList();

          return calculateCentroid(points);
        }).toList();

        // Update the state to display the regions and their centroids
        setState(() {});
      } catch (e) {
        if (kDebugMode) {
          print('Error processing image: $e');
        }
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error processing image. Please try again.'),
          ),
        );
      }
    }
  }

  Point<int> calculateCentroid(List<Point<int>> points) {
    int sumX = 0, sumY = 0;

    for (final point in points) {
      sumX += point.x;
      sumY += point.y;
    }

    return Point(sumX ~/ points.length, sumY ~/ points.length);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldMessengerKey, // Add this line
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Geography App'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_image != null)
                  CustomPaint(
                    painter: CustomPainterWidget(
                      image: _image!,
                      centroids: centroids,
                    ),
                    child: Container(),
                  )
                else
                  const Text('No image selected.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_image != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            centroids: centroids, // Updated type
                            numberOfRegions:
                                3, // Set the desired number of regions
                            regionBorders: const [], // Provide region borders list
                            mapImage:
                                File(_imagePath!), // Use the stored image path
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          // Add the missing 'const' keyword
                          content:
                              Text('Please upload an image before proceeding.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Go to Map Screen'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: _getImage,
                      tooltip: 'Pick Image',
                      heroTag: 'pick_image_button',
                      child: const Icon(Icons
                          .add_a_photo), // Unique heroTag for this FloatingActionButton
                    ),
                    FloatingActionButton(
                      onPressed: processImage,
                      tooltip: 'Process Image',
                      heroTag: 'process_image_button',
                      child: const Icon(Icons
                          .sync), // Unique heroTag for this FloatingActionButton
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert'; // Import for base64Encode
import 'package:image/image.dart' as img;
import 'dart:async'; // Import for the TimeoutException
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:goe_app_new_unit_region_sketch_2023_0_0_1/models/point.dart'
    as custom_point;

// Define the IP address of the server
const String serverIpAddress = '192.168.1.247';

// Define a function to process the regions from the binary image
// This function should contain the actual processing logic
List<custom_point.Point> processRegions(img.Image binaryImage) {
  // For now, just return an empty list
  return [];
}

// Define a function to load an image from the provided file path
img.Image loadImage(String path) {
  // Read the image bytes from the file
  final bytes = File(path).readAsBytesSync();
  // Decode the image from the bytes and return it
  return img.decodeImage(bytes)!;
}

// Define a function to convert the source image to grayscale
img.Image convertToGrayscale(img.Image src) {
  // Copy the grayscale version of the source image into a new image and return it
  return img.copyInto(src, img.grayscale(src));
}

// Define a function to convert the source image to a binary image
// using the provided threshold
img.Image convertToBinary(img.Image src, int threshold) {
  // Create a new binary image from the source image
  final binaryImage = img.Image.from(src);
  // Iterate through the image pixels
  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      // Get the red channel value of the pixel (grayscale)
      int pixelValue = img.getRed(src.getPixel(x, y));
      // Set the binary image pixel based on the threshold
      binaryImage.setPixel(
          x, y, pixelValue > threshold ? 0xFFFFFFFF : 0xFF000000);
    }
  }
  // Return the binary image
  return binaryImage;
}

// Define a function to send the image file to the server
// and process the contours using the server's response
Future<String> sendImageAndProcessContours(File imageFile) async {
  // Connect to the server using socket.io
  final socket = io.io('http://$serverIpAddress:5000', <String, dynamic>{
    'transports': ['websocket'],
  });

  // Prepare a Completer to handle the response from the server
  final completer = Completer<String>();

  // Listen for the 'contours_data' event from the server
  socket.on('contours_data', (data) {
    // Check if the received data is a String
    if (data is String) {
      // Resolve the Completer with the received data
      completer.complete(data);
    } else {
      // If the received data is not a String, reject the Completer with an error
      completer.completeError(Exception('Invalid data received from server'));
    }
  });

  // Convert the image file to a base64 string
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);

  // Emit the 'process_image' event to the server with the base64 image data
  socket.emit('process_image', base64Image);

  try {
    // Wait for the response from the server
    final response = await completer.future.timeout(const Duration(minutes: 1));

    // Print the response body if in debug mode
    if (kDebugMode) {
      print('Response body: $response');
    }
    // Returnthe response as a string
    return response;
  } on TimeoutException catch (_) {
// Handle the timeout exception
    throw Exception('Request timeout. Please try again later.');
  } finally {
// Close the socket connection
    socket.close();
  }
}

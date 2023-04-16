// Import the required Flutter packages
import 'package:flutter/material.dart';
// Import your custom MapScreen widget
import 'screens/home_screen.dart'; // Add this import at the top

// Define the entry point of the application
void main() {
  // Run the MyApp widget as the root of the application
  runApp(const MyApp());
}

// Define the MyApp widget, a stateless widget as it does not maintain any mutable state
class MyApp extends StatelessWidget {
  // Constructor for MyApp widget
  const MyApp({Key? key}) : super(key: key);

  // Define the build method which returns a widget tree
  @override
  Widget build(BuildContext context) {
    // MaterialApp is a pre-built widget that provides Material Design visual layout structure
    return MaterialApp(
      // Set the title of the application
      title: 'Geography Sketch Map',
      // Set the theme for the application
      theme: ThemeData(
        // Set the primary color swatch for the theme
        primarySwatch: Colors.blue,
      ),
      // Set the home screen of the application to be an instance of HomeScreen
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spinner_app/wheel.dart';

// App entry point. Initializes the root MyApp widget which displays
// the fortune wheel as the home screen, using Poppins font theming.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner in the corner
      title: 'Rectazone Fortune Wheel', // App title for the OS task switcher
      theme: ThemeData(
        primarySwatch: Colors.blue, // Default color swatch (fallback)
        textTheme: GoogleFonts.poppinsTextTheme(
          // Use Poppins font globally
          ThemeData.dark().textTheme, // Base it on the dark theme text styles
        ),
      ),
      home:
          const Wheel(), // Launch straight into the Wheel screen(first page for now before adding oAuth)
    );
  }
}

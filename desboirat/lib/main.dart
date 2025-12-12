import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart'; // We will create this next

void main() {
  runApp(DesboiratApp());
}

class DesboiratApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Desboira't",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(), // Nice font
      ),
      home: HomeScreen(), // Points to your Dashboard
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/qr_link_screen.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await dotenv.load(fileName: ".env");
  runApp(DesboiratApp());
}

class DesboiratApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Desboira't",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: AuthGate(), // New Entry Point
    );
  }
}

class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // We use this to force a rebuild after linking QR
  Key _key = UniqueKey(); 

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. If not logged in -> Login Screen
        if (!snapshot.hasData) {
          return LoginScreen();
        }

        // 2. If logged in, check if linked to doctor
        return FutureBuilder<bool>(
          key: _key, // Changing this key re-runs the FutureBuilder
          future: DatabaseService().isLinkedToDoctor(),
          builder: (context, linkSnapshot) {
            if (linkSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            bool isLinked = linkSnapshot.data ?? false;

            if (isLinked) {
              return HomeScreen();
            } else {
              return QRLinkScreen(onLinked: () {
                setState(() => _key = UniqueKey()); // Refresh to go to Home
              });
            }
          },
        );
      },
    );
  }
}
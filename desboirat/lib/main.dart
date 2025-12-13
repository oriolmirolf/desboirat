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
import 'services/notification_service.dart'; // <--- ADD THIS IMPORT

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  // --- NOTIFICATION SETUP (NEW) ---
  await NotificationService().init();
  
  // Schedule: 11:00 AM (Games) and 8:00 PM (Subjective)
  NotificationService().scheduleDailyNotification(
    1, "Entrena la teva ment", "Tens els jocs d'avui pendents!", 11, 00
  );
  NotificationService().scheduleDailyNotification(
    2, "Com et sents?", "Recorda anotar els teus problemes cognitius.", 20, 00
  );
  // --------------------------------

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
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Key _key = UniqueKey(); 

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoginScreen();

        return FutureBuilder<bool>(
          key: _key, 
          future: DatabaseService().isLinkedToDoctor(),
          builder: (context, linkSnapshot) {
            if (linkSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            bool isLinked = linkSnapshot.data ?? false;
            return isLinked ? HomeScreen() : QRLinkScreen(onLinked: () => setState(() => _key = UniqueKey()));
          },
        );
      },
    );
  }
}
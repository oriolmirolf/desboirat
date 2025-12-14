import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/qr_link_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  // 1. INITIALIZE NOTIFICATIONS
  await NotificationService().init();
  
  // 2. LISTEN FOR DOCTOR TRIGGER
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        
        if (snapshot.exists && snapshot.data() != null && snapshot.data()!.containsKey('trigger_notification')) {
          var data = snapshot.get('trigger_notification');
          
          if (data['timestamp'] != null) {
             Timestamp ts = data['timestamp'];
             // Only allow recent triggers (last 2 mins)
             if (DateTime.now().difference(ts.toDate()).inSeconds < 120) {
                 print("🔔 TRIGGER RECEIVED: Sending Notification");
                 NotificationService().showInstantNotification(
                   999, 
                   "Com et sents?", 
                   "Recorda anotar els teus problemes cognitius."
                 );
             }
          }
        }
      });
    }
  });

  // 3. SCHEDULE DAILY REMINDERS
  NotificationService().scheduleDailyNotification(
    1, "Entrena la teva ment", "Tens els jocs d'avui pendents!", 11, 00
  );
  NotificationService().scheduleDailyNotification(
    2, "Com et sents?", "Recorda anotar els teus problemes cognitius.", 20, 00
  );

  runApp(DesboiratApp());
}

class DesboiratApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Desboira't",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: AuthGate(), 
    );
  }
}

// 🟢 THE FINAL FIX: STREAM AUTH GATE WITH LOADING GUARDS 🟢
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Auth Loading? -> Spinner
        if (authSnapshot.connectionState == ConnectionState.waiting) {
           return Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));
        }

        // 2. Not Logged In? -> Login
        if (!authSnapshot.hasData) {
          return LoginScreen();
        }

        // 3. Logged In -> Check Database Profile LIVE
        User user = authSnapshot.data!;
        
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, userSnapshot) {
            
            // 🔴 CRITICAL FIX: PREVENT FLASHING & LOOPS 🔴
            
            // If connection is opening, or data hasn't arrived, or doc doesn't exist yet...
            // SHOW SPINNER. Do NOT show QR screen yet.
            if (userSnapshot.connectionState == ConnectionState.waiting || 
                !userSnapshot.hasData || 
                !userSnapshot.data!.exists) {
              return Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));
            }

            // Extract Data
            var userData = userSnapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null) {
              // Still waiting for real data...
              return Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));
            }

            // 🟢 NOW we are 100% sure we have the data. Check logic.
            bool hasDoctor = userData.containsKey('doctorId') && 
                             userData['doctorId'] != null && 
                             userData['doctorId'] != "";

            if (hasDoctor) {
              return HomeScreen();
            } else {
              // Only show QR if we are SURE there is no doctor ID
              return QRLinkScreen(onLinked: () {}); 
            }
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = "";
  bool _isLoading = false;

  // --- SAVE USER DATA ---
  Future<void> _saveUserToFirestore(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@')[0],
        'last_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving to Firestore: $e");
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = ""; });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
    } catch (e) {
      setState(() => _errorMessage = "Error Google: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- EMAIL SIGN IN ---
  Future<void> _submit(bool isRegister) async {
    setState(() { _isLoading = true; _errorMessage = ""; });
    try {
      UserCredential userCredential;
      if (isRegister) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      }
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? "Error desconegut");
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final InputBorder _defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.blueGrey.shade100),
  );
  
  final InputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.teal, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.teal.shade400, Colors.cyan.shade500]),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 15, offset: Offset(0, 8)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                // 🟢 1. YOUR APP ICON (From root assets)
                                child: Image.asset('icon.png', width: 80, height: 80),
                              ),
                            ),
                            
                            SizedBox(height: 20),
                            Text("Desboira't", style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
                            Text("Accés Pacients", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.blueGrey.shade400)),
                            SizedBox(height: 30),

                            TextField(
                              controller: _emailController,
                              style: GoogleFonts.plusJakartaSans(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: "Correu Electrònic",
                                filled: true, fillColor: Colors.white,
                                border: _defaultBorder, enabledBorder: _defaultBorder, focusedBorder: _focusedBorder,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _passController,
                              obscureText: true,
                              style: GoogleFonts.plusJakartaSans(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: "Contrasenya",
                                filled: true, fillColor: Colors.white,
                                border: _defaultBorder, enabledBorder: _defaultBorder, focusedBorder: _focusedBorder,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),

                            SizedBox(height: 24),
                            
                            if (_errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 12)),
                              ),

                            // Loading State
                            if (_isLoading)
                              CircularProgressIndicator(color: Colors.teal),

                            // Buttons
                            if (!_isLoading) ...[
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.teal, Colors.cyan.shade600]),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _submit(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text("INICIAR SESSIÓ", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                              SizedBox(height: 12),
                              
                              OutlinedButton.icon(
                                onPressed: _signInWithGoogle,
                                icon: Image.network(
                                  "https://cdn-icons-png.flaticon.com/512/300/300221.png", 
                                  width: 24, 
                                  height: 24
                                ),
                                label: Text("Entrar amb Google", style: GoogleFonts.plusJakartaSans(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white, side: BorderSide(color: Colors.blueGrey.shade200),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () => _submit(true),
                                child: Text("No tens compte? Registra't", style: GoogleFonts.plusJakartaSans(color: Colors.teal.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Footer
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.blueGrey.shade50))),
                        child: Center(
                          // 🟢 2. YOUR ICO LOGO (From web/icons folder)
                          child: Image.asset(
                            'web/icons/logo.png', 
                            height: 30,
                            errorBuilder: (context, error, stackTrace) => Text("ICO Logo", style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
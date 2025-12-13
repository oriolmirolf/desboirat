import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // --- GOOGLE SIGN IN LOGIC ---
  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = ""; });
    print("Attempting Google Sign In..."); // DEBUG LOG
    
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        print("Google Sign In canceled by user.");
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Google credentials obtained. Signing into Firebase...");
      await _auth.signInWithCredential(credential);
      print("Google Sign In Successful!");
      
    } catch (e) {
      print("Google Error: $e");
      setState(() => _errorMessage = "Error Google: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit(bool isRegister) async {
    setState(() { _isLoading = true; _errorMessage = ""; });
    print("Attempting Email Auth (Register: $isRegister)..."); // DEBUG LOG

    try {
      if (isRegister) {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      }
      print("Email Auth Successful!");
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      setState(() => _errorMessage = e.message ?? "Error desconegut");
    } catch (e) {
      print("General Error: $e");
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Desboira't", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                SizedBox(height: 10),
                Text("Accés Pacients", style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 40),
                
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Correu Electrònic", border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passController,
                  decoration: InputDecoration(labelText: "Contrasenya", border: OutlineInputBorder()),
                  obscureText: true,
                ),
                
                SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage, style: TextStyle(color: Colors.red)),
                  
                if (_isLoading) 
                  CircularProgressIndicator()
                else ...[
                  ElevatedButton(
                    onPressed: () => _submit(false), 
                    child: Container(width: double.infinity, alignment: Alignment.center, child: Text("INICIAR SESSIÓ")),
                  ),
                  SizedBox(height: 10),
                  
                  // --- THE GOOGLE BUTTON ---
                  OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Icon(Icons.login, color: Colors.red), 
                    label: Text("Entrar amb Google"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _submit(true), 
                    child: Text("No tens compte? Registra't"),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
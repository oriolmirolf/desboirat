import 'package:flutter/material.dart';
import 'processing_speed_test.dart'; // Ensure you created this from the previous prompt
import 'fluency_test.dart';
import 'memory_test.dart';
import 'subjective_test.dart';
import 'chatbot_screen.dart'; // Use the chatbot code from the previous prompt

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Desboira't")),
      body: SingleChildScrollView( // Added scroll for smaller screens
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text("DETECTAR", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              SizedBox(height: 10),
              _buildNavButton(context, "Velocitat (Joc)", Colors.orange, ProcessingSpeedTest()),
              _buildNavButton(context, "Fluència (Veu)", Colors.deepOrange, FluencyTestScreen()),
              _buildNavButton(context, "Memòria (Números)", Colors.orangeAccent, MemoryTestScreen()),
              _buildNavButton(context, "Qüestionari (Diari)", Colors.purpleAccent, SubjectiveTestScreen()),
              
              Divider(height: 40, thickness: 2),
              
              Text("REACCIONAR", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              SizedBox(height: 10),
              _buildNavButton(context, "Assistent Virtual", Colors.blue, ChatBotScreen()),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext ctx, String text, Color color, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 250,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
          ),
          onPressed: () {
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
          },
          child: Text(text, style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ),
    );
  }
}
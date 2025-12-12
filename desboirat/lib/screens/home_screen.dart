import 'package:flutter/material.dart';
import 'processing_speed_test.dart';
import 'fluency_test.dart';
import 'memory_test.dart'; // This file now contains the DigitSpanTest class
import 'subjective_test.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Desboira't")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text("DETECTAR", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              SizedBox(height: 10),
              
              // 1. Processing Speed (Velocitat de Processament)
              _buildNavButton(context, "Velocitat (Joc)", Colors.orange, ProcessingSpeedTest()),
              
              // 2. Alternating Verbal Fluency (Fluència Verbal Alternant)
              _buildNavButton(context, "Fluència (Alternant)", Colors.deepOrange, FluencyTestScreen()),
              
              // 3. Attention (Forward Digit Span) - Slide 39
              _buildNavButton(context, "Atenció (Nombres)", Colors.purple, DigitSpanTest(isReverse: false)),
              
              // 4. Working Memory (Reverse Digit Span) - Slide 47
              _buildNavButton(context, "Memòria Treball (Invèrs)", Colors.indigo, DigitSpanTest(isReverse: true)),
              
              // 5. Subjective Assessment (FACT-cog)
              _buildNavButton(context, "Qüestionari (Diari)", Colors.purpleAccent, SubjectiveTestScreen()),
              
              Divider(height: 40, thickness: 2),
              
              Text("REACCIONAR", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              SizedBox(height: 10),
              
              // 6. Psychoeducation & Recommendations
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
        width: 280, // Slightly wider to fit the new text
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
          ),
          onPressed: () {
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
          },
          child: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
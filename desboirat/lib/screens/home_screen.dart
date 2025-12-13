import 'package:flutter/material.dart';
import 'processing_speed_test.dart';
import 'fluency_test.dart';
import 'memory_test.dart';
import 'subjective_test.dart';
import 'chatbot_screen.dart';
import 'package:desboirat/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Extend body behind AppBar so the gradient covers the status bar area
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          "Desboira't", 
          style: TextStyle(
            color: AppColors.deepSlate, 
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent to show gradient
        elevation: 0, // Remove shadow for a flat, modern look
      ),
      body: Container(
        // 2. The Main Background Gradient
        width: double.infinity,
        height: double.infinity, // Ensures gradient fills screen
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
                children: [
                  SizedBox(height: 20),
                  
                  // --- SECTION 1: DETECTAR ---
                  _buildSectionHeader("DETECTAR"),
                  
                  _buildNavButton(
                    context, 
                    "Velocitat", 
                    "Joc de reflexos",
                    Icons.speed, 
                    ProcessingSpeedTest()
                  ),
                  
                  _buildNavButton(
                    context, 
                    "Fluència Verbal", 
                    "Alternança de paraules",
                    Icons.record_voice_over, 
                    FluencyTestScreen()
                  ),
                  
                  _buildNavButton(
                    context, 
                    "Atenció", 
                    "Repetició de nombres",
                    Icons.pin, // 123 icon lookalike
                    DigitSpanTest(isReverse: false)
                  ),
                  
                  _buildNavButton(
                    context, 
                    "Memòria de Treball", 
                    "Nombres inversos",
                    Icons.psychology, 
                    DigitSpanTest(isReverse: true)
                  ),
                  
                  _buildNavButton(
                    context, 
                    "Autoavaluació", 
                    "Qüestionari diari",
                    Icons.assignment_ind, 
                    SubjectiveTestScreen()
                  ),
                  
                  SizedBox(height: 30),
                  
                  // --- SECTION 2: REACCIONAR ---
                  _buildSectionHeader("REACCIONAR"),
                  
                  _buildNavButton(
                    context, 
                    "Assistent Virtual", 
                    "Xat i recomanacions",
                    Icons.smart_toy, // Robot icon
                    ChatBotScreen()
                  ),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Section Headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
      child: Row(
        children: [
          Text(
            title, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: AppColors.deepSlate.withOpacity(0.7), // Slightly transparent
              letterSpacing: 1.5,
            )
          ),
          SizedBox(width: 10),
          Expanded(child: Divider(color: AppColors.deepSlate.withOpacity(0.3))),
        ],
      ),
    );
  }

  // Helper for the Buttons
  Widget _buildNavButton(BuildContext ctx, String title, String subtitle, IconData icon, Widget page) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.deepSlate.withOpacity(0.1), // Soft shadow
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream, // The unified button color
          foregroundColor: AppColors.deepSlate, // Text/Ripple color
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15) // Softer corners
          ),
          elevation: 0, // We used custom shadow in Container, so remove button shadow
        ),
        onPressed: () {
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
        },
        child: Row(
          children: [
            // The Icon Box
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withOpacity(0.2), // Light background for icon
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.deepSlate, size: 24),
            ),
            SizedBox(width: 15),
            
            // The Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontSize: 17, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepSlate
                    )
                  ),
                  Text(
                    subtitle, 
                    style: TextStyle(
                      fontSize: 13, 
                      color: AppColors.deepSlate.withOpacity(0.6)
                    )
                  ),
                ],
              ),
            ),
            
            // Small arrow
            Icon(Icons.chevron_right, color: AppColors.deepSlate.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
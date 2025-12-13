import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
// Import your game files here
import 'processing_speed_test.dart';
import 'fluency_test.dart';
import 'memory_test.dart';

class GamesMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Entrenament Cognitiu", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepSlate),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  
                  _buildSectionHeader("JOCS DISPONIBLES"),

                  // 1. Processing Speed
                  _buildNavButton(
                    context, 
                    "Velocitat", 
                    "Joc de reflexos",
                    Icons.speed, 
                    ProcessingSpeedTest()
                  ),
                  
                  // 2. Fluency
                  _buildNavButton(
                    context, 
                    "Fluència Verbal", 
                    "Alternança de paraules",
                    Icons.record_voice_over, 
                    FluencyTestScreen()
                  ),
                  
                  // 3. Attention
                  _buildNavButton(
                    context, 
                    "Atenció", 
                    "Repetició de nombres",
                    Icons.pin, 
                    DigitSpanTest(isReverse: false)
                  ),
                  
                  // 4. Working Memory
                  _buildNavButton(
                    context, 
                    "Memòria de Treball", 
                    "Nombres inversos",
                    Icons.psychology, 
                    DigitSpanTest(isReverse: true)
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets (Same as before)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepSlate.withOpacity(0.7), letterSpacing: 1.5)),
          SizedBox(width: 10),
          Expanded(child: Divider(color: AppColors.deepSlate.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext ctx, String title, String subtitle, IconData icon, Widget page) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: AppColors.deepSlate.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.deepSlate,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.skyBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.deepSlate, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.deepSlate)),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.deepSlate.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.deepSlate.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
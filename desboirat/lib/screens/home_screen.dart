import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'games_menu_screen.dart';
import 'subjective_test.dart';
import 'chatbot_screen.dart';
import 'help_screen.dart'; // <--- Import the new screen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          "Desboira't", 
          style: TextStyle(
            color: AppColors.deepSlate, 
            fontWeight: FontWeight.bold,
            fontSize: 24
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, 
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView( // Changed to ScrollView to fit 4 buttons safely on small screens
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  // --- BIG ICON ---
                  Icon(Icons.spa, size: 80, color: AppColors.deepSlate.withOpacity(0.5)),
                  SizedBox(height: 10),
                  Text(
                    "Benvingut de nou",
                    style: TextStyle(fontSize: 18, color: AppColors.deepSlate.withOpacity(0.7)),
                  ),
                  SizedBox(height: 40),

                  // --- 1. GAMES MENU BUTTON ---
                  _buildMainButton(
                    context, 
                    "Entrenament Cognitiu", 
                    "Accedeix als 4 jocs mentals",
                    Icons.extension, 
                    GamesMenuScreen(),
                  ),
                  
                  SizedBox(height: 20),

                  // --- 2. AUTO-EVALUATION ---
                  _buildMainButton(
                    context, 
                    "Autoavaluació", 
                    "Registre diari de símptomes",
                    Icons.assignment_ind, 
                    SubjectiveTestScreen(),
                  ),
                  
                  SizedBox(height: 20),

                  // --- 3. HELP & TIPS (NEW) ---
                  _buildMainButton(
                    context, 
                    "Recomanacions", 
                    "Consells i vídeos personalitzats",
                    Icons.tips_and_updates, // Nice bulb/update icon
                    HelpRecommendationsScreen(),
                  ),

                  SizedBox(height: 20),

                  // --- 4. VIRTUAL ASSISTANT ---
                  _buildMainButton(
                    context, 
                    "Assistent Virtual", 
                    "Xat amb Desboira't",
                    Icons.smart_toy, 
                    ChatBotScreen(),
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

  Widget _buildMainButton(BuildContext ctx, String title, String subtitle, IconData icon, Widget page) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.deepSlate.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.deepSlate,
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          elevation: 0, 
        ),
        onPressed: () {
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: AppColors.deepSlate),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontSize: 19, 
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle, 
                    style: TextStyle(
                      fontSize: 14, 
                      color: AppColors.deepSlate.withOpacity(0.6)
                    )
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.deepSlate.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
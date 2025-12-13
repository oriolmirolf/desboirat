import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/daily_tracker.dart'; // <--- Import Tracker
import 'games_menu_screen.dart';
import 'subjective_test.dart';
import 'chatbot_screen.dart';
import 'help_screen.dart'; // <--- Import the new screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _subjectiveDone = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    bool done = await DailyTracker.isDoneToday(DailyTracker.KEY_SUBJECTIVE);
    if (mounted) setState(() => _subjectiveDone = done);
  }

  // Helper to refresh when coming back from a screen
  void _navigateAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          "Desboira't", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold, fontSize: 24)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, 
        decoration: BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: SingleChildScrollView( // Kept ScrollView from HEAD to fit 4 buttons
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
                    false, // Games menu is never 'done' itself
                    () => _navigateAndRefresh(GamesMenuScreen()),
                  ),
                  
                  SizedBox(height: 20),

                  // --- 2. AUTO-EVALUATION ---
                  _buildMainButton(
                    context, 
                    "Autoavaluació", 
                    _subjectiveDone ? "Completat per avui" : "Registre diari de símptomes",
                    Icons.assignment_ind, 
                    _subjectiveDone, // Checks tracker
                    () => _navigateAndRefresh(SubjectiveTestScreen()),
                  ),
                  
                  SizedBox(height: 20),

                  // --- 3. HELP & TIPS (NEW from HEAD) ---
                  _buildMainButton(
                    context, 
                    "Recomanacions", 
                    "Consells i vídeos personalitzats",
                    Icons.tips_and_updates, 
                    false, // Always available
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpRecommendationsScreen())),
                  ),

                  SizedBox(height: 20),

                  // --- 4. VIRTUAL ASSISTANT ---
                  _buildMainButton(
                    context, 
                    "Assistent Virtual", 
                    "Xat amb Desboira't",
                    Icons.smart_toy, 
                    false, // Always available
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatBotScreen())),
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

  Widget _buildMainButton(BuildContext ctx, String title, String subtitle, IconData icon, bool isDone, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: isDone ? [] : [
          BoxShadow(color: AppColors.deepSlate.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // GREY OUT logic from notifications branch
          backgroundColor: isDone ? Colors.grey.shade200 : AppColors.cream,
          foregroundColor: isDone ? Colors.grey : AppColors.deepSlate,
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0, 
        ),
        onPressed: isDone ? null : onTap, // DISABLE if done
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDone ? Colors.grey.shade300 : AppColors.skyBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: isDone ? Colors.grey : AppColors.deepSlate),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null)),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: isDone ? Colors.grey : AppColors.deepSlate.withOpacity(0.6))),
                ],
              ),
            ),
            if (!isDone) Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.deepSlate.withOpacity(0.3)),
            if (isDone) Icon(Icons.check_circle, size: 24, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/daily_tracker.dart'; 
import 'games_menu_screen.dart';
import 'subjective_test.dart';
import 'chatbot_screen.dart';
import 'help_screen.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _subjectiveDone = false;
  bool _allGamesDone = false; 

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    bool sub = await DailyTracker.isDoneToday(DailyTracker.KEY_SUBJECTIVE);
    
    bool f = await DailyTracker.isDoneToday(DailyTracker.KEY_FLUENCY);
    bool s = await DailyTracker.isDoneToday(DailyTracker.KEY_SPEED);
    bool a = await DailyTracker.isDoneToday(DailyTracker.KEY_ATTENTION);
    bool m = await DailyTracker.isDoneToday(DailyTracker.KEY_MEMORY);

    if (mounted) {
      setState(() {
        _subjectiveDone = sub;
        _allGamesDone = f && s && a && m; 
      });
    }
  }

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa, size: 80, color: AppColors.deepSlate.withOpacity(0.5)),
                  SizedBox(height: 10),
                  Text(
                    "Benvingut de nou",
                    style: TextStyle(fontSize: 18, color: AppColors.deepSlate.withOpacity(0.7)),
                  ),
                  SizedBox(height: 40),

                  // 1. GAMES MENU
                  _buildMainButton(
                    context, 
                    "Entrenament Cognitiu", 
                    _allGamesDone ? "Sessió completada!" : "Accedeix als 4 jocs mentals",
                    Icons.extension, 
                    _allGamesDone, 
                    () => _navigateAndRefresh(GamesMenuScreen()),
                  ),
                  
                  SizedBox(height: 20),

                  // 2. AUTO-EVALUATION
                  _buildMainButton(
                    context, 
                    "Autoavaluació", 
                    _subjectiveDone ? "Registrat per avui" : "Registre diari de símptomes",
                    Icons.assignment_ind, 
                    _subjectiveDone, 
                    () => _navigateAndRefresh(SubjectiveTestScreen()),
                  ),
                  
                  SizedBox(height: 20),

                  // 3. HELP & TIPS
                  _buildMainButton(
                    context, 
                    "Recomanacions", 
                    "Consells i vídeos personalitzats",
                    Icons.tips_and_updates, 
                    false, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpRecommendationsScreen())),
                  ),

                  SizedBox(height: 20),

                  // 4. VIRTUAL ASSISTANT
                  _buildMainButton(
                    context, 
                    "Assistent Virtual", 
                    "Xat amb Desboira't",
                    Icons.smart_toy, 
                    false, 
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
    // DARKER SHADING FOR COMPLETED STATE
    // Background: Stronger Green (Green-200 equivalent)
    final bgColor = isDone ? const Color(0xFFBBF7D0) : AppColors.cream; 
    // Text: Dark Green
    final textColor = isDone ? const Color(0xFF14532D) : AppColors.deepSlate; 
    // Icon Circle: Medium Green
    final iconBgColor = isDone ? const Color(0xFF86EFAC) : AppColors.skyBlue.withOpacity(0.2);
    // Icon: Dark Green
    final iconColor = isDone ? const Color(0xFF14532D) : AppColors.deepSlate;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.deepSlate.withOpacity(isDone ? 0.05 : 0.1), 
            blurRadius: 15, 
            offset: Offset(0, 5)
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          disabledBackgroundColor: bgColor, 
          disabledForegroundColor: textColor,
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0, 
        ),
        onPressed: isDone ? null : onTap, 
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isDone ? Icons.check : icon, size: 30, color: iconColor),
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
                      // If done, text is darker green to match theme, else slate
                      color: isDone ? textColor.withOpacity(0.9) : textColor.withOpacity(0.6)
                    )
                  ),
                ],
              ),
            ),
            if (!isDone) 
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.deepSlate.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
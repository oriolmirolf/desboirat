import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/daily_tracker.dart'; // <--- Added Logic Import

// Import your game files here
import 'processing_speed_test.dart';
import 'fluency_test.dart';
import 'memory_test.dart';

class GamesMenuScreen extends StatefulWidget {
  @override
  _GamesMenuScreenState createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends State<GamesMenuScreen> {
  // State variables to track completion
  bool _fluencyDone = false;
  bool _speedDone = false;
  bool _attentionDone = false;
  bool _memoryDone = false;

  @override
  void initState() {
    super.initState();
    _checkGames();
  }

  // Check SharedPreferences to see what is done today
  void _checkGames() async {
    final f = await DailyTracker.isDoneToday(DailyTracker.KEY_FLUENCY);
    final s = await DailyTracker.isDoneToday(DailyTracker.KEY_SPEED);
    final a = await DailyTracker.isDoneToday(DailyTracker.KEY_ATTENTION);
    final m = await DailyTracker.isDoneToday(DailyTracker.KEY_MEMORY);

    if (mounted) {
      setState(() {
        _fluencyDone = f;
        _speedDone = s;
        _attentionDone = a;
        _memoryDone = m;
      });
    }
  }

  // Helper to go to game and refresh status upon return
  void _goToGame(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _checkGames(); // Refresh the grey-out status instantly when back
  }

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
                    _speedDone, // Pass status
                    () => _goToGame(ProcessingSpeedTest())
                  ),
                  
                  // 2. Fluency
                  _buildNavButton(
                    context, 
                    "Fluència Verbal", 
                    "Alternança de paraules",
                    Icons.record_voice_over, 
                    _fluencyDone, // Pass status
                    () => _goToGame(FluencyTestScreen())
                  ),
                  
                  // 3. Attention
                  _buildNavButton(
                    context, 
                    "Atenció", 
                    "Repetició de nombres",
                    Icons.pin, 
                    _attentionDone, // Pass status
                    () => _goToGame(DigitSpanTest(isReverse: false))
                  ),
                  
                  // 4. Working Memory
                  _buildNavButton(
                    context, 
                    "Memòria de Treball", 
                    "Nombres inversos",
                    Icons.psychology, 
                    _memoryDone, // Pass status
                    () => _goToGame(DigitSpanTest(isReverse: true))
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

  // --- HELPER WIDGETS (Modified slightly for Logic, but kept Style) ---

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

  Widget _buildNavButton(BuildContext ctx, String title, String subtitle, IconData icon, bool isDone, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        // Remove shadow if done to look "flat" and disabled
        boxShadow: isDone ? [] : [BoxShadow(color: AppColors.deepSlate.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // Grey if done, Cream if active
          backgroundColor: isDone ? Colors.grey[200] : AppColors.cream,
          foregroundColor: isDone ? Colors.grey : AppColors.deepSlate,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        // Disable click if done
        onPressed: isDone ? null : onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Grey box if done, SkyBlue if active
                color: isDone ? Colors.grey[300] : AppColors.skyBlue.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(10)
              ),
              // Show Checkmark if done
              child: Icon(
                isDone ? Icons.check : icon, 
                color: isDone ? Colors.grey[600] : AppColors.deepSlate, 
                size: 24
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontSize: 17, 
                      fontWeight: FontWeight.bold, 
                      color: isDone ? Colors.grey : AppColors.deepSlate,
                      decoration: isDone ? TextDecoration.lineThrough : null // Strikethrough text
                    )
                  ),
                  Text(
                    isDone ? "Completat per avui" : subtitle, // Change subtitle feedback
                    style: TextStyle(
                      fontSize: 13, 
                      color: isDone ? Colors.grey : AppColors.deepSlate.withOpacity(0.6)
                    )
                  ),
                ],
              ),
            ),
            if (!isDone)
              Icon(Icons.chevron_right, color: AppColors.deepSlate.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
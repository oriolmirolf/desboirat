import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/daily_tracker.dart'; 

import 'processing_speed_test.dart';
import 'fluency_test.dart';
import 'memory_test.dart';

class GamesMenuScreen extends StatefulWidget {
  @override
  _GamesMenuScreenState createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends State<GamesMenuScreen> {
  bool _fluencyDone = false;
  bool _speedDone = false;
  bool _attentionDone = false;
  bool _memoryDone = false;

  @override
  void initState() {
    super.initState();
    _checkGames();
  }

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

  void _goToGame(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _checkGames(); 
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
        decoration: BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  
                  _buildSectionHeader("JOCS DISPONIBLES"),

                  _buildNavButton(context, "Velocitat", "Joc de reflexos", Icons.speed, _speedDone, () => _goToGame(ProcessingSpeedTest())),
                  _buildNavButton(context, "Fluència Verbal", "Alternança de paraules", Icons.record_voice_over, _fluencyDone, () => _goToGame(FluencyTestScreen())),
                  _buildNavButton(context, "Atenció", "Repetició de nombres", Icons.pin, _attentionDone, () => _goToGame(DigitSpanTest(isReverse: false))),
                  _buildNavButton(context, "Memòria de Treball", "Nombres inversos", Icons.psychology, _memoryDone, () => _goToGame(DigitSpanTest(isReverse: true))),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
    // DARKER SHADING FOR COMPLETED STATE (Matching Home Screen)
    final bgColor = isDone ? const Color(0xFFBBF7D0) : AppColors.cream; 
    final textColor = isDone ? const Color(0xFF14532D) : AppColors.deepSlate; 
    final iconBgColor = isDone ? const Color(0xFF86EFAC) : AppColors.skyBlue.withOpacity(0.2);
    final iconColor = isDone ? const Color(0xFF14532D) : AppColors.deepSlate;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.deepSlate.withOpacity(isDone ? 0.05 : 0.1), 
            blurRadius: 10, 
            offset: Offset(0, 4)
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          disabledBackgroundColor: bgColor,
          disabledForegroundColor: textColor,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: isDone ? null : onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(isDone ? Icons.check : icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    isDone ? "Completat" : subtitle, 
                    style: TextStyle(
                      fontSize: 13, 
                      color: textColor.withOpacity(0.9)
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
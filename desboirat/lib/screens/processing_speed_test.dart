// TODO: add more things to dictionary

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Ensure this path is correct

class ProcessingSpeedTest extends StatefulWidget {
  @override
  _ProcessingSpeedTestState createState() => _ProcessingSpeedTestState();
}

class _ProcessingSpeedTestState extends State<ProcessingSpeedTest> {
  // Generate numbers 1 to 16
  List<int> numbers = List.generate(16, (index) => index + 1);
  int currentTarget = 1;
  Stopwatch stopwatch = Stopwatch();
  bool isGameActive = false;
  
  // Track visual feedback (red flash on error)
  int? _errorIndex; 
  Timer? _timer; // To update the UI every second

  @override
  void initState() {
    super.initState();
    // Randomize the grid positions
    numbers.shuffle(); 
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      currentTarget = 1;
      isGameActive = true;
      stopwatch.reset();
      stopwatch.start();
      
      // Update clock
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {}); 
      });
    });
  }

  void handleTap(int index, int number) {
    if (!isGameActive) return;

    if (number == currentTarget) {
      setState(() {
        currentTarget++;
        // Clear any previous error
        _errorIndex = null;
      });

      // Win Condition: All numbers pressed
      if (currentTarget > numbers.length) {
        stopwatch.stop();
        _timer?.cancel(); // Stop UI updates
        _showResult();
      }
    } else {
      // Logic for wrong tap: Flash red
      setState(() {
        _errorIndex = index;
      });
      // Reset the error color after 200ms
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) setState(() => _errorIndex = null);
      });
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream, // THEME
        title: Text(
          "Test Completat!", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 50, color: AppColors.deepSlate),
            SizedBox(height: 10),
            Text(
              "Temps: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepSlate)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to Home
            },
            child: Text("Tornar", style: TextStyle(color: AppColors.deepSlate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.skyBlue,
              foregroundColor: AppColors.cream,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                numbers.shuffle();
                startGame();
              });
            },
            child: Text("Repetir"),
          )
        ],
      ),
    );
  }

  // --- INFO BOX WIDGET ---
  Widget _buildInfoBox() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream, // THEME: Cream background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.deepSlate.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: AppColors.deepSlate),
              SizedBox(width: 10),
              Text(
                "Com jugar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "1. Busca el número 1 i prem-lo.\n2. Continua en ordre (2, 3, 4...) fins al 16.\n3. Fes-ho tan ràpid com puguis!",
            style: TextStyle(fontSize: 16, color: AppColors.deepSlate),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // THEME: Gradient behind AppBar
      appBar: AppBar(
        title: Text(
          "Velocitat", 
          style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepSlate),
      ),
      body: Container(
        // THEME: Main Gradient
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Box
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cream.withOpacity(0.5), // Semi-transparent cream
                  borderRadius: BorderRadius.circular(20),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      isGameActive ? "Busca el número: $currentTarget" : "Preparat?",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepSlate),
                    ),
                    if (isGameActive)
                       Text(
                         "Temps: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s",
                         style: TextStyle(fontSize: 18, color: AppColors.deepSlate),
                       ),
                  ],
                ),
              ),
              
              // --- START SCREEN (Info Box + Button) ---
              if (!isGameActive)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        _buildInfoBox(),
                        SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cream, // THEME: Button Color
                            foregroundColor: AppColors.deepSlate, // THEME: Text Color
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                          ),
                          child: Text("COMENÇAR TEST", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
    
              // --- GAME SCREEN (Grid) ---
              if (isGameActive)
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, 
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: numbers.length,
                    itemBuilder: (context, index) {
                      int number = numbers[index];
                      
                      // Hide numbers explicitly if they are already clicked
                      if (number < currentTarget) return SizedBox.shrink();
    
                      return GestureDetector(
                        onTap: () => handleTap(index, number),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          decoration: BoxDecoration(
                            // THEME: Cream by default, Red on error
                            color: _errorIndex == index ? Colors.redAccent : AppColors.cream,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepSlate.withOpacity(0.2), 
                                blurRadius: 4, 
                                offset: Offset(2, 2)
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "$number",
                              style: TextStyle(
                                color: _errorIndex == index ? Colors.white : AppColors.deepSlate, 
                                fontSize: 24, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
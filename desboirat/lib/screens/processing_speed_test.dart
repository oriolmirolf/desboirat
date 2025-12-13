import 'dart:async';
import 'package:flutter/material.dart';

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
      
      // OPTIONAL: This timer updates the clock text while playing
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
        title: Text("Test Completat!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              "Temps: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to Home
            },
            child: Text("Tornar"),
          ),
          ElevatedButton(
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
        color: Colors.blue.shade50, // Light blue background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
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
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                "Com jugar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            // UPDATED TEXT FOR THIS GAME
            "1. Busca el número 1 i prem-lo.\n2. Continua en ordre (2, 3, 4...) fins al 16.\n3. Fes-ho tan ràpid com puguis!",
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Velocitat de Processament")),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.blue[50],
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  isGameActive ? "Busca el número: $currentTarget" : "Preparat?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (isGameActive)
                   Text(
                     "Temps: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s",
                     style: TextStyle(fontSize: 18),
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
                    _buildInfoBox(), // <--- BOX ADDED HERE
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: startGame,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                      child: Text("COMENÇAR TEST", style: TextStyle(fontSize: 20)),
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
                        color: _errorIndex == index ? Colors.red : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "$number",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}